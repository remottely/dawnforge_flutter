import 'package:bonfire/bonfire.dart';

import 'farm_tile.dart';

class FarmGridManager {
  static const int gridWidth = 20;
  static const int gridHeight = 15;
  late List<List<FarmTileView>> farmGrid;

  FarmGridManager() {
    initializeGrid();
  }

  void initializeGrid() {
    farmGrid = List.generate(
      gridHeight,
      (y) => List.generate(
        gridWidth,
        (x) => FarmTileView(Vector2(x.toDouble(), y.toDouble())),
      ),
    );
  }

  FarmTileView? getTileAt(Vector2 position) {
    int x = position.x.floor();
    int y = position.y.floor();
    if (x >= 0 && x < gridWidth && y >= 0 && y < gridHeight) {
      return farmGrid[y][x];
    }
    return null;
  }

  void processDailyGrowth() {
    for (var row in farmGrid) {
      for (var tile in row) {
        tile.processDay();
      }
    }
  }
}
