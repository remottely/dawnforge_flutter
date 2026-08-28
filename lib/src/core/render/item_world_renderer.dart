import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/render/animation_creator.dart';
import 'package:dawnforge/src/core/render/sprite_loader.dart';
import 'package:flame/components.dart';

/// The render binding of one pickup — the `ItemWorld` half of
/// `item_world.gd` that is view, not sim: the scaled sprite and the idle
/// bob. Mirrors the host every frame and removes itself when the host
/// reports collected.
final class ItemWorldRenderer extends PositionComponent {
  ItemWorldRenderer(this.host) {
    anchor = Anchor.center;
    size = Vector2(
          host.itemData.frameWidth.toDouble(),
          host.itemData.frameHeight.toDouble(),
        ) *
        host.itemData.spriteScale;
    priority = host.position.y.round();
  }

  /// Same feel constants as the spec's `ItemWorld`.
  static const double bobAmplitude = 1;
  static const double bobSpeed = 2;

  final ItemWorld host;

  double _bobTime = 0;
  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    final data = host.itemData;
    assert(
      data.spritesheetPath.isNotEmpty,
      '[ItemWorldRenderer] ${data.id} has no spritesheet — step 03 '
      'guarantees one for every authored entry',
    );
    final sheet = await SpriteLoader.loadSheet(data.spritesheetPath);
    _sprite = SpriteComponent(
      sprite: AnimationCreator.createStill(data, sheet),
      size: size,
    );
    await add(_sprite!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (host.collected) {
      removeFromParent();
      return;
    }
    _bobTime += dt;
    position.setValues(host.position.x, host.position.y);
    _sprite?.position.y = sin(_bobTime * bobSpeed) * bobAmplitude;
    priority = host.position.y.round();
  }
}
