import 'dart:convert';

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/render/world_object_renderer.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/data/almanac_loader.dart';
import 'package:dawnforge/src/core/systems/input/input_helper.dart';
import 'package:dawnforge/src/core/systems/localization/localization_system.dart';
import 'package:dawnforge/src/core/systems/managers/game_input_manager.dart';
import 'package:dawnforge/src/core/systems/timing/sim_clock.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

/// The Flame shell (FP3.1): boots content from the generated assets, drives
/// the fixed-step simulation, and binds hosts to renderers. The FP3 slice is
/// the plan's walkable-world gate in miniature — a player-controlled actor
/// moving over ground with props around it; chunked terrain replaces the
/// static field in FP3.4.
///
/// Rule 30 lives here structurally: nothing ever calls a pause — a surface
/// that must hold the player pushes a GameInputManager blocker and this loop
/// keeps running.
final class DawnforgeGame extends FlameGame with KeyboardEvents {
  DawnforgeGame({this.locale = 'pt_BR'});

  final String locale;

  /// Every simulated host, ticked on the fixed step.
  final List<WorldObject> simObjects = <WorldObject>[];

  late final IActor player;

  static const _grass = Color(0xFF3A5F3A);

  @override
  Color backgroundColor() => _grass;

  Future<Map<String, Object?>> _loadJson(String assetKey) async =>
      jsonDecode(await rootBundle.loadString(assetKey))!
          as Map<String, Object?>;

  @override
  Future<void> onLoad() async {
    // Sprite keys are full asset paths — no implicit assets/images/ prefix.
    images.prefix = '';

    const game = GameConstants.gameName;

    // Content boot: registries from the manifest, strings for the locale.
    final almanacRoot = ContentPaths.almanacRoot(game);
    final manifest = await _loadJson('$almanacRoot/manifest.json');
    final entries = <String, Map<String, Object?>>{};
    for (final raw
        in (manifest['entries']! as List).cast<Map<String, Object?>>()) {
      final path = raw['path']! as String;
      entries[path] = await _loadJson('$almanacRoot/$path');
    }
    const AlmanacLoader().loadFromManifest(manifest, (path) => entries[path]!);
    locator<LocalizationSystem>().loadLocale(
      locale,
      await _loadJson('${ContentPaths.localesRoot(game)}/$locale.json'),
    );

    // A small authored field to walk in (FP3.4 replaces this with chunks).
    await _spawnProp('t1_prop_crop_tree_palm', const GridPos(2, 1));
    await _spawnProp('t1_prop_rock_moss', const GridPos(-2, 2));
    await _spawnProp('t1_prop_grass_wild', const GridPos(1, 3));
    await _spawnProp('t1_prop_crop_bush_clover', const GridPos(-1, -2));
    await _spawnProp('t1_prop_vein_copper', const GridPos(3, -1));

    player = ActorFactory.create('t1_actor_creature_boar', WorldPos.zero);
    final playerRenderer = ActorRenderer(player);
    simObjects.add(player);
    await add(playerRenderer);

    camera.viewfinder.zoom = 4;
    camera.follow(playerRenderer, snap: true);
  }

  Future<void> _spawnProp(String id, GridPos gridPos) async {
    final prop = PropFactory.create(
      id,
      locator<GridManager>().gridToWorld(gridPos),
    );
    simObjects.add(prop);
    await add(WorldObjectRenderer(prop));
  }

  @override
  void update(double dt) {
    // Fixed-step simulation under a variable render loop (study risk #5).
    final dropped = locator<SimClock>().advance(dt, _simTick);
    assert(dropped == 0 || dt > 1, 'SimClock dropped $dropped steps');
    super.update(dt);
  }

  void _simTick(double stepDt) {
    if (locator<GameInputManager>().isGameplayEnabled) {
      final input = locator<InputHelper>().getMovementVector();
      player.movement.applyMovement(input, stepDt);
    }
    for (final host in simObjects) {
      host.update(stepDt);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    locator<InputHelper>().handleKeyEvent(event);
    return KeyEventResult.handled;
  }
}
