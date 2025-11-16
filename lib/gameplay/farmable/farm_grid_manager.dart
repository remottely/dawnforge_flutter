// import 'package:bonfire/bonfire.dart';

// import 'farm_tile.dart';

// class FarmGridManager {
//   static const int _kGridWidth = 20;
//   static const int _kGridHeight = 15;
//   late List<List<FarmTileView>> farmGrid;

//   FarmGridManager() {
//     initializeGrid();
//   }

//   void initializeGrid() {
//     farmGrid = List.generate(
//       _kGridHeight,
//       (y) => List.generate(
//         _kGridWidth,
//         (x) => FarmTileView(position: Vector2(x.toDouble(), y.toDouble())),
//       ),
//     );
//   }

//   FarmTileView? getTileAt(Vector2 position) {
//     int x = position.x.floor();
//     int y = position.y.floor();
//     if (x >= 0 && x < _kGridWidth && y >= 0 && y < _kGridHeight) {
//       return farmGrid[y][x];
//     }
//     return null;
//   }

//   void processDailyGrowth() {
//     for (List<FarmTileView> row in farmGrid) {
//       for (FarmTileView tile in row) {
//         tile.processDay();
//       }
//     }
//   }
// }
