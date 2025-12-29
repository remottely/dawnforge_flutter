// import 'dart:developer' as developer;

// import 'package:darkness_dungeon/gameplay/farm/database/crop_database.dart';
// import 'package:darkness_dungeon/gameplay/farm/models/crop_model.dart';
// import 'package:darkness_dungeon/gameplay/farm/models/farm_tile_model.dart';
// import 'package:darkness_dungeon/gameplay/farm/models/soil_state_model.dart';

// final class FarmRuleEngine {
//   const FarmRuleEngine();

//   FarmTileModel ensureTile(
//     FarmTileModel? tile, {
//     required int x,
//     required int y,
//   }) {
//     return tile ?? FarmTileModel(x: x, y: y);
//   }

//   FarmTileModel? till(FarmTileModel tile) {
//     if (tile.soilState != SoilStateModel.untilled) {
//       developer.log(
//         '[FarmRuleEngine] Soil already prepared at (${tile.x}, ${tile.y})',
//       );
//       return null;
//     }
//     return tile.till();
//   }

//   FarmTileModel? water(FarmTileModel tile) {
//     if (tile.soilState == SoilStateModel.untilled) {
//       developer.log(
//         '[FarmRuleEngine] Cannot water untilled soil (${tile.x}, ${tile.y})',
//       );
//       return null;
//     }
//     return tile.water();
//   }

//   FarmTileModel? plant(FarmTileModel tile, String cropId) {
//     if (!tile.canPlant) {
//       developer.log(
//         '[FarmRuleEngine] ❌ Cannot plant at (${tile.x}, ${tile.y}): '
//         'isEmpty=${tile.isEmpty}, soilState=${tile.soilState.name}, '
//         'hasCrop=${tile.crop != null}',
//       );
//       return null;
//     }

//     final crop = CropDatabase.createCrop(cropId);
//     if (crop == null) {
//       developer.log('[FarmRuleEngine] ❌ Invalid crop: $cropId');
//       return null;
//     }

//     developer.log(
//       '[FarmRuleEngine] ✅ Planting $cropId at (${tile.x}, ${tile.y})',
//     );
//     return tile.plant(crop);
//   }

//   ({FarmTileModel updatedTile, CropModel harvestedCrop})? harvest(
//     FarmTileModel tile,
//   ) {
//     if (!tile.canHarvest) {
//       developer.log(
//         '[FarmRuleEngine] Nothing to harvest at (${tile.x}, ${tile.y})',
//       );
//       return null;
//     }

//     final harvestedCrop = tile.crop!;
//     final updatedTile = tile.harvest();
//     return (updatedTile: updatedTile, harvestedCrop: harvestedCrop);
//   }

//   FarmTileModel advanceDay(FarmTileModel tile, int dayEnded) {
//     if (tile.crop == null) {
//       if (_shouldConsumeWater(tile, dayEnded)) {
//         return tile.copyWith(soilState: SoilStateModel.tilled);
//       }
//       return tile;
//     }

//     return tile.advanceDay(dayEnded);
//   }

//   bool _shouldConsumeWater(FarmTileModel tile, int dayEnded) {
//     return tile.soilState == SoilStateModel.watered &&
//         tile.lastWateredDay == dayEnded;
//   }
// }
