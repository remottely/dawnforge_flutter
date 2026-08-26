import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_empty_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
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
}
