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
}
