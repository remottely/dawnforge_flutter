import 'dart:convert';

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/render/ground_chunk_renderer.dart';
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
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/systems/world/procedural_world_manager.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

/// The Flame shell (FP3.1): boots content from the generated assets, drives
/// the fixed-step simulation, and binds hosts to renderers. Since FP3.4 the
/// world is procedural and chunked: the generator decides terrain, the
/// streaming materializes it around the player, and [GroundChunkRenderer]
/// bakes it to the screen.
///
/// Rule 30 lives here structurally: nothing ever calls a pause — a surface
/// that must hold the player pushes a GameInputManager blocker and this loop
/// keeps running.
final class DawnforgeGame extends FlameGame with KeyboardEvents {
  DawnforgeGame({this.locale = 'pt_BR', this.worldSeed = 0});

  final String locale;

  /// The seed this world is built from; 0 resolves through
  /// [ProceduralWorldManager.resolveNewWorldSeed] (debug pin or fresh roll).
  /// Tests pass a fixed one.
  final int worldSeed;

  /// Every simulated host, ticked on the fixed step.
  final List<WorldObject> simObjects = <WorldObject>[];

  late final IActor player;

  /// The endless sea: water is never painted per tile — the background IS
  /// the water, exactly as the Godot renderer treats it. The color is the
  /// biome water base (`BiomeData.water_color_base`).
  static const _waterBase = Color(0xFF2B75A1);

  @override
  Color backgroundColor() => _waterBase;

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

    // The biome manifest (pipeline step 11) routes through the same loader.
    final biomesRoot = ContentPaths.worldBiomesRoot(game);
    final biomeManifest = await _loadJson('$biomesRoot/manifest.json');
    final biomeEntries = <String, Map<String, Object?>>{};
    for (final raw
        in (biomeManifest['entries']! as List).cast<Map<String, Object?>>()) {
      final path = raw['path']! as String;
      biomeEntries[path] = await _loadJson('$biomesRoot/$path');
    }
    const AlmanacLoader()
        .loadFromManifest(biomeManifest, (path) => biomeEntries[path]!);

    locator<LocalizationSystem>().loadLocale(
      locale,
      await _loadJson('${ContentPaths.localesRoot(game)}/$locale.json'),
    );

    // The procedural world (FP3.4): seed → generator → spawn → streaming.
    // The renderer mounts BEFORE streaming initializes so no chunkLoaded is
    // missed (it also seeds from loadedChunks — belt and braces).
    locator<ProceduralWorldManager>()
        .initialize(ProceduralWorldManager.resolveNewWorldSeed(worldSeed));
    final spawnTile = locator<ProceduralWorldManager>().findSpawnTile();
    await world.add(GroundChunkRenderer());
    locator<ChunkStreamingSystem>().initialize(spawnTile);

    // A handful of hand-placed props around the spawn — sim-object dressing
    // until procedural population (FP7) spawns the real thing.
    await _spawnProp('t1_prop_crop_tree_palm', _offsetFrom(spawnTile, 2, 1));
    await _spawnProp('t1_prop_rock_moss', _offsetFrom(spawnTile, -2, 2));
    await _spawnProp('t1_prop_grass_wild', _offsetFrom(spawnTile, 1, 3));
    await _spawnProp(
      't1_prop_crop_bush_clover',
      _offsetFrom(spawnTile, -1, -2),
    );
    await _spawnProp('t1_prop_vein_copper', _offsetFrom(spawnTile, 3, -1));

    player = ActorFactory.create(
      't1_actor_creature_boar',
      locator<GridManager>().gridToWorld(spawnTile),
    );
    final playerRenderer = ActorRenderer(player);
    simObjects.add(player);
    await world.add(playerRenderer);

    camera.viewfinder.zoom = 4;
    camera.follow(playerRenderer, snap: true);
  }

  static GridPos _offsetFrom(GridPos origin, int dx, int dy) =>
      GridPos(origin.x + dx, origin.y + dy);

  Future<void> _spawnProp(String id, GridPos gridPos) async {
    final prop = PropFactory.create(
      id,
      locator<GridManager>().gridToWorld(gridPos),
    );
    simObjects.add(prop);
    // Renderers go into `world`, never added to the game root directly — the
    // CameraComponent only renders `world`'s subtree (Flame 1.32's default
    // FlameGame wiring: camera.world = world; both are children of the game
    // root, but only `world`'s content passes through the camera's viewport
    // transform). Adding here instead left the world empty and rendered
    // nothing but the background color.
    await world.add(WorldObjectRenderer(prop));
  }

  @override
  void update(double dt) {
    // Fixed-step simulation under a variable render loop (study risk #5).
    final dropped = locator<SimClock>().advance(dt, _simTick);
    assert(dropped == 0 || dt > 1, 'SimClock dropped $dropped steps');

    // Streaming runs on the RENDER frame, not the fixed step — what this
    // machine materializes is a view-side concern (mirror of the Godot
    // `_process` placement). The camera's visible rect widens the window
    // when zoomed out.
    final visible = camera.visibleWorldRect;
    locator<ChunkStreamingSystem>().update(
      playerTile: locator<GridManager>().worldToGrid(player.position),
      visibleWorldWidth: visible.width,
      visibleWorldHeight: visible.height,
    );
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
