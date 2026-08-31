import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_empty_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tile = GameConstants.tileDimension;
  final grid = GridManager();

  group('GridManager', () {
    test('gridToWorld returns the tile center', () {
      expect(
        grid.gridToWorld(const GridPos(0, 0)),
        const WorldPos(tile / 2, tile / 2),
      );
      expect(
        grid.gridToWorld(const GridPos(2, -1)),
        const WorldPos(2 * tile + tile / 2, -tile + tile / 2),
      );
    });

    test('worldToGrid floors, so negative space maps correctly', () {
      expect(grid.worldToGrid(const WorldPos(1, 1)), const GridPos(0, 0));
      expect(grid.worldToGrid(const WorldPos(-1, -1)), const GridPos(-1, -1));
    });

    test('round trip: a tile center maps back to its tile', () {
      const pos = GridPos(7, -3);
      expect(grid.worldToGrid(grid.gridToWorld(pos)), pos);
    });
  });

  group('GridManager nodeless occupancy (FP3.4)', () {
    GroundBuildableData terrain() =>
        GroundBuildableData(id: 't1_ground_buildable_terrain');

    test('register → query → unregister, the data instance is SHARED', () {
      final fresh = GridManager();
      final data = terrain();
      const pos = GridPos(3, 4);

      expect(fresh.hasGroundAt(pos), isFalse);
      expect(fresh.getGroundDataAt(pos), isNull);

      fresh.registerGroundData(pos, data);
      expect(fresh.hasGroundAt(pos), isTrue);
      // The registry resource itself, never a clone — nodeless tiles are
      // immutable and all reference one shared instance (rule 8's valid
      // "cached ref", not duplicated state).
      expect(identical(fresh.getGroundDataAt(pos), data), isTrue);
      expect(fresh.registeredGroundTiles, contains(pos));

      fresh.unregisterGroundData(pos);
      expect(fresh.hasGroundAt(pos), isFalse);
    });

    test('registering over a resident tile is a wiring bug — crash', () {
      final fresh = GridManager();
      const pos = GridPos(0, 0);
      fresh.registerGroundData(pos, terrain());
      expect(() => fresh.registerGroundData(pos, terrain()), throwsStateError);
    });

    test('unregistering an absent tile is quiet — the unload-replay branch',
        () {
      final fresh = GridManager()
        ..unregisterGroundData(const GridPos(9, 9)); // must not throw
      expect(fresh.hasGroundAt(const GridPos(9, 9)), isFalse);
    });

    test('empty tiles register like any ground and answer their flags', () {
      final fresh = GridManager();
      const pos = GridPos(-2, 5);
      fresh.registerGroundData(
        pos,
        GroundEmptyData(id: 't1_ground_empty_water', isWater: true),
      );
      final data = fresh.getGroundDataAt(pos);
      expect(data, isA<GroundEmptyData>());
      expect((data! as GroundEmptyData).isWater, isTrue);
      expect((data as GroundEmptyData).isPassable, isFalse);
    });
  });

  group('GridManager elevation map (FP3.4)', () {
    test('register → get → release round-trip; flat is 0, a value', () {
      final fresh = GridManager();
      const pos = GridPos(1, 1);
      expect(fresh.hasElevationAt(pos), isFalse);
      expect(fresh.getElevationAt(pos), 0);

      fresh.registerElevationTile(pos, 3);
      expect(fresh.hasElevationAt(pos), isTrue);
      expect(fresh.getElevationAt(pos), 3);

      fresh.releaseElevationTile(pos);
      expect(fresh.hasElevationAt(pos), isFalse);
      expect(fresh.getElevationAt(pos), 0);
    });

    test('height below 1 is not a registration — crash', () {
      final fresh = GridManager();
      expect(
        () => fresh.registerElevationTile(const GridPos(0, 0), 0),
        throwsStateError,
      );
    });

    test('releasing a flat tile is a caller bug', () {
      final fresh = GridManager();
      expect(
        () => fresh.releaseElevationTile(const GridPos(5, 5)),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('GridManager body blocking (FP3.5)', () {
    test('only registered impassables and walls block; the void does not',
        () {
      final fresh = GridManager();
      const water = GridPos(0, 0);
      const cliffHole = GridPos(1, 0);
      const terrain = GridPos(2, 0);
      const wall = GridPos(3, 0);
      const unregistered = GridPos(9, 9);

      fresh
        ..registerGroundData(
          water,
          GroundEmptyData(id: 't1_ground_empty_water', isWater: true),
        )
        ..registerGroundData(
          cliffHole,
          GroundEmptyData(id: 't1_ground_empty_cliff'),
        )
        ..registerGroundData(
          terrain,
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        )
        ..registerGroundData(
          wall,
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        )
        ..registerElevationTile(wall, 2);

      expect(fresh.blocksBodyAt(water), isTrue);
      expect(fresh.blocksBodyAt(cliffHole), isTrue);
      expect(fresh.blocksBodyAt(terrain), isFalse);
      expect(fresh.blocksBodyAt(wall), isTrue, reason: 'a wall is a collider');
      // No collider exists where nothing materialized — the physics mirror
      // of the Godot side; the world edge is WorldBoundaryEnforcer's job.
      expect(fresh.blocksBodyAt(unregistered), isFalse);

      // The A*-side question (FP4.1): here the VOID is unreachable — the
      // exact opposite of the physics answer above — water and cliff refuse,
      // and elevation is deliberately ignored (the wall keeps the good
      // ground underneath; callers judge heights against their own
      // reference).
      expect(fresh.isTileWalkable(unregistered), isFalse);
      expect(fresh.isTileWalkable(water), isFalse);
      expect(fresh.isTileWalkable(cliffHole), isFalse);
      expect(fresh.isTileWalkable(terrain), isTrue);
      expect(fresh.isTileWalkable(wall), isTrue);
    });
  });

  group('GridManager prop occupancy (FP4.1d)', () {
    setUp(() {
      registerCoreSystems();
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_rock_probe',
        'has_collision': true,
      });
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_grass_probe',
        'has_collision': false,
      });
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_wide_probe',
        'grid_size': <int>[2, 1],
      });
    });
    tearDown(resetCoreSystems);

    test('occupy → query → free round trip, footprint-wide', () {
      final fresh = GridManager();
      final wide = PropFactory.create('t1_prop_wide_probe', WorldPos.zero);
      const anchor = GridPos(4, 4);

      expect(fresh.isPropSpaceAvailable(anchor, width: 2), isTrue);
      fresh.occupyPropTiles(anchor, wide);
      // A 2×1 prop claims BOTH tiles, and both map back to the same host.
      expect(identical(fresh.getPropAt(anchor), wide), isTrue);
      expect(identical(fresh.getPropAt(const GridPos(5, 4)), wide), isTrue);
      expect(fresh.isPropSpaceAvailable(const GridPos(5, 4)), isFalse);

      fresh.freePropTiles(anchor, wide);
      expect(fresh.getPropAt(anchor), isNull);
      expect(fresh.getPropAt(const GridPos(5, 4)), isNull);
    });

    test('a colliding prop blocks bodies and walkability; a ghost does not',
        () {
      final fresh = GridManager()
        ..registerGroundData(
          const GridPos(0, 0),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        )
        ..registerGroundData(
          const GridPos(1, 0),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      final rock = PropFactory.create('t1_prop_rock_probe', WorldPos.zero);
      final grass = PropFactory.create('t1_prop_grass_probe', WorldPos.zero);

      fresh
        ..occupyPropTiles(const GridPos(0, 0), rock)
        ..occupyPropTiles(const GridPos(1, 0), grass);

      expect(fresh.blocksBodyAt(const GridPos(0, 0)), isTrue);
      expect(fresh.isTileWalkable(const GridPos(0, 0)), isFalse);
      // has_collision false: claims the tile but stops nobody, as authored.
      expect(fresh.blocksBodyAt(const GridPos(1, 0)), isFalse);
      expect(fresh.isTileWalkable(const GridPos(1, 0)), isTrue);
    });

    test('claiming a held footprint is a wiring bug — crash', () {
      final fresh = GridManager();
      final first = PropFactory.create('t1_prop_rock_probe', WorldPos.zero);
      final second = PropFactory.create('t1_prop_rock_probe', WorldPos.zero);
      fresh.occupyPropTiles(const GridPos(2, 2), first);

      expect(
        () => fresh.occupyPropTiles(const GridPos(2, 2), second),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => fresh.freePropTiles(const GridPos(2, 2), second),
        throwsA(isA<AssertionError>()),
        reason: 'freeing tiles held by somebody else',
      );
    });
  });
}
