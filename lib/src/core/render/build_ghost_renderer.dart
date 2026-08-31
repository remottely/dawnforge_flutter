import 'dart:async' show unawaited;

import 'package:dawnforge/src/core/base/world_objects/actors/player/actor_player.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand_buildable.dart';
import 'package:dawnforge/src/core/render/animation_creator.dart';
import 'package:dawnforge/src/core/render/sprite_loader.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show BlendMode, Color, ColorFilter;

/// The blueprint under the cursor, drawn where it would land and coloured by
/// whether it may — the port of `item_hand_buildable.gd`'s preview half.
///
/// It is the SAME question the press asks, asked every time the cursor crosses
/// into a new tile and answered in colour instead of in a refusal. It cannot
/// drift from the press because it does not compute anything: both read
/// `ItemHandBuildable.previewAt`. Until FP5.1 gives a refusal its sentence, red
/// is the only thing that tells a player why nothing happened, which is what
/// makes this the piece that turns a working verb into a usable one.
///
/// PORT DELTA — where it lives. In the spec the preview is a `Sprite2D` the
/// hand itself creates, because a hand there IS a node in the scene. The sim
/// never draws in this port, so the hand answers and this component paints, and
/// the frame cache that guards the per-frame cost came here with the frame.
final class BuildGhostRenderer extends PositionComponent with HasVisibility {
  BuildGhostRenderer(this.player)
      : super(priority: _ghostPriority, anchor: Anchor.center) {
    isVisible = false;
  }

  /// Above every world object (which sort by their own `y`) and below nothing
  /// in the world layer — a preview that a tree can hide is a preview that
  /// lies about where you are about to build.
  static const int _ghostPriority = 1 << 29;

  /// The spec's `Color(0, 1, 0, 0.5)` / `Color(1, 0, 0, 0.5)`, applied as a
  /// multiply so the blueprint's own art still reads through the tint.
  static const Color _allowedTint = Color(0x8000FF00);
  static const Color _refusedTint = Color(0x80FF0000);

  final ActorPlayer player;

  SpriteComponent? _sprite;

  /// Which blueprint [_sprite] is of, so the sheet is loaded once per hand and
  /// a load that finishes after the hand has moved on is discarded.
  String? _spriteBlueprintId;

  /// The tile the preview was last resolved for. The ghost snaps to a tile, so
  /// nothing about it can change until the cursor crosses into another one —
  /// and everything below is grid queries and a gate, every frame a player
  /// holds a blueprint.
  GridPos? _resolvedTile;

  /// Whether the ghost is currently on screen with something to show — read by
  /// the boot test, which is the only place a real one exists.
  bool get isShowing => isVisible && _sprite != null;

  @override
  void update(double dt) {
    super.update(dt);
    final hand = player.heldItem.hand;
    // Nothing in hand that builds, or a surface holding the player (rule 30 —
    // the world keeps running behind it, but this press would not be the
    // world's, so promising it would be a lie).
    if (hand is! ItemHandBuildable ||
        !locator<GameInputManager>().isGameplayEnabled) {
      _hide();
      return;
    }

    _adoptBlueprintOf(hand);

    // Nothing to draw with yet. Asked BEFORE the tile cache, and that order is
    // the whole of it: the cache means "this tile is already on screen", so
    // recording a tile on a frame that drew nothing leaves the ghost invisible
    // until the cursor happens to cross into another one. Hold a blueprint
    // without moving the mouse — the commonest thing a player does — and the
    // preview never appears at all.
    final sprite = _sprite;
    if (sprite == null) return;

    final tile = locator<GridManager>()
        .worldToGrid(locator<InputHelper>().getCursorWorldPos());
    if (tile == _resolvedTile) return;
    _resolvedTile = tile;

    final preview = hand.previewAt(tile);
    position.setValues(preview.centre.x, preview.centre.y);
    isVisible = true;
    sprite.paint.colorFilter = ColorFilter.mode(
      preview.isAllowed ? _allowedTint : _refusedTint,
      BlendMode.modulate,
    );
  }

  /// Takes the ghost off screen and forces a full revalidation on the frame it
  /// comes back — the world may have changed under a cursor that never moved.
  void _hide() {
    isVisible = false;
    _resolvedTile = null;
  }

  /// Makes sure the sprite on screen is the one [hand] builds.
  void _adoptBlueprintOf(ItemHandBuildable hand) {
    final blueprint = hand.blueprint;
    if (blueprint.id == _spriteBlueprintId) return;
    _spriteBlueprintId = blueprint.id;
    // A different blueprint is a different everything: drop the old sprite and
    // the cached tile, so the next frame re-resolves against the new footprint,
    // and stay hidden until the new sheet is on screen.
    _sprite?.removeFromParent();
    _sprite = null;
    isVisible = false;
    _resolvedTile = null;
    size.setValues(
      blueprint.frameWidth.toDouble(),
      blueprint.frameHeight.toDouble(),
    );
    unawaited(_loadSheetFor(blueprint.id, blueprint.spritesheetPath));
  }

  Future<void> _loadSheetFor(String blueprintId, String path) async {
    final sheet = await SpriteLoader.loadSheet(path);
    // The hotbar can move twice before one sheet decodes; the second move is
    // the one that counts.
    if (blueprintId != _spriteBlueprintId) return;
    final hand = player.heldItem.hand;
    if (hand is! ItemHandBuildable) return;
    final sprite = SpriteComponent(
      sprite: AnimationCreator.createStill(hand.blueprint, sheet),
      size: size.clone(),
    );
    _sprite = sprite;
    await add(sprite);
  }
}
