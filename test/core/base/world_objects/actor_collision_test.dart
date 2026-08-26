import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/biome_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/systems/world/procedural_world_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP3.5 end to end over the REAL generated world: an actor driven straight
/// at the sea and at a mountain wall stops at their edge — the boar no
/// longer walks through what the world says is solid.
void main() {
  const chunkSize = GameConstants.proceduralChunkSize;
  const fixedStep = GameConstants.simFixedStep;

  late GridPos spawn;

  setUp(() {
    registerCoreSystems();
    locator<BiomeRegistry>().register(
      'biome_forest_data',
      BiomeData(
        id: 'biome_forest_data',
        tier: 1,
        terrainWaterShare: 0.08,
        terrainWallShare: 0.15,
        terrainWallHeight2Share: 0.25,
        terrainWallHeight3Share: 0.08,
      ),
    );
    <Map<String, Object?>>[
      {'id': 't1_ground_buildable_terrain', 'type': 'ground_buildable_data'},
      {
        'id': 't1_ground_empty_water',
        'type': 'ground_empty_data',
        'is_water': true,
      },
      {'id': 't1_ground_empty_cliff', 'type': 'ground_empty_data'},
    ].forEach(locator<GroundRegistry>().registerJson);
    locator<ActorRegistry>()
        .registerJson(<String, Object?>{'id': 'test_boar'});

    locator<ProceduralWorldManager>().initialize(20260826);
    spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>()..initialize(spawn);
    for (var i = 0; i < 500 && streaming.isStreamingBusy; i++) {
      streaming.update(playerTile: spawn);
    }
  });
  tearDown(resetCoreSystems);

  /// Nearest loaded tile satisfying [matches] with a free orthogonal
  /// neighbor, ring-scanned from the spawn — deterministic under the fixed
  /// seed. Returns (blocker, standTile).
  (GridPos, GridPos) findBlockerWithApproach(bool Function(GridPos) matches) {
    final grid = locator<GridManager>();
    const reach = 2 * EngineConstants.proceduralChunkLoadRadius * chunkSize;
    for (var radius = 1; radius <= reach; radius++) {
      for (var x = -radius; x <= radius; x++) {
        for (var y = -radius; y <= radius; y++) {
          if (x.abs() != radius && y.abs() != radius) continue;
          final tile = GridPos(spawn.x + x, spawn.y + y);
          if (!matches(tile)) continue;
          for (final side in const [
            GridPos(-1, 0),
            GridPos(1, 0),
            GridPos(0, -1),
            GridPos(0, 1),
          ]) {
            final stand = GridPos(tile.x + side.x, tile.y + side.y);
            if (grid.hasGroundAt(stand) && !grid.blocksBodyAt(stand)) {
              return (tile, stand);
            }
          }
        }
      }
    }
    fail('the seeded window holds no such blocker — pick another seed');
  }

  /// Drives [actor] straight at the center of [target] for [steps] fixed
  /// steps, asserting after every one that no tile under the body blocks.
  void driveAt(IActor actor, GridPos target, int steps) {
    final grid = locator<GridManager>();
    final targetCenter = grid.gridToWorld(target);
    const bodyHalf = EngineConstants.actorBodyHalfExtentTiles *
        GameConstants.tileDimension;
    for (var i = 0; i < steps; i++) {
      final toTarget = (targetCenter - actor.position).normalized();
      actor.movement.applyMovement(toTarget, fixedStep);
      actor.update(fixedStep);
      for (final corner in [
        WorldPos(actor.position.x - bodyHalf + 1e-6,
            actor.position.y - bodyHalf + 1e-6),
        WorldPos(actor.position.x + bodyHalf - 1e-6,
            actor.position.y - bodyHalf + 1e-6),
        WorldPos(actor.position.x - bodyHalf + 1e-6,
            actor.position.y + bodyHalf - 1e-6),
        WorldPos(actor.position.x + bodyHalf - 1e-6,
            actor.position.y + bodyHalf - 1e-6),
      ]) {
        expect(grid.blocksBodyAt(grid.worldToGrid(corner)), isFalse,
            reason: 'the body entered a blocking tile at step $i');
      }
    }
  }

  test('the sea stops the boar at its edge', () {
    final grid = locator<GridManager>();
    final (water, stand) = findBlockerWithApproach((tile) {
      final data = grid.getGroundDataAt(tile);
      return data != null && data.id == 't1_ground_empty_water';
    });

    final boar = ActorFactory.create('test_boar', grid.gridToWorld(stand));
    final start = boar.position;
    driveAt(boar, water, 240); // 4 seconds of shoving into the sea

    // It moved (pressed up against the edge), and never entered the water.
    expect(boar.position.distanceTo(start), greaterThan(0));
    expect(
      boar.position.distanceTo(grid.gridToWorld(water)),
      greaterThan(GameConstants.tileDimension / 4),
      reason: 'the body center ended inside the water tile',
    );
  });

  test('a mountain wall stops the boar', () {
    final grid = locator<GridManager>();
    final (wall, stand) = findBlockerWithApproach(grid.hasElevationAt);

    final boar = ActorFactory.create('test_boar', grid.gridToWorld(stand));
    driveAt(boar, wall, 240);

    expect(
      grid.blocksBodyAt(grid.worldToGrid(boar.position)),
      isFalse,
      reason: 'the boar ended inside the wall',
    );
  });

  test('ghosts keep the raw integration — has_collision false, as authored',
      () {
    final grid = locator<GridManager>();
    locator<ActorRegistry>().registerJson(
      <String, Object?>{'id': 'test_ghost', 'has_collision': false},
    );
    final (water, stand) = findBlockerWithApproach((tile) {
      final data = grid.getGroundDataAt(tile);
      return data != null && data.id == 't1_ground_empty_water';
    });

    final ghost = ActorFactory.create('test_ghost', grid.gridToWorld(stand));
    final targetCenter = grid.gridToWorld(water);
    for (var i = 0; i < 240; i++) {
      ghost.movement.applyMovement(
        (targetCenter - ghost.position).normalized(),
        fixedStep,
      );
      ghost.update(fixedStep);
    }
    // Straight through: the ghost reaches (or crosses) the water center.
    expect(
      ghost.position.distanceTo(targetCenter),
      lessThan(GameConstants.tileDimension * 1.0),
    );
  });
}
