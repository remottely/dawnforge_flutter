import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/farm/database/crop_database.dart';

import '../models/crop_model.dart';
import '../models/farm_tile_model.dart';
import '../models/soil_state_model.dart';

/// Pure rule engine responsible for transforming tiles according to
/// high-level farm actions (till, water, plant, harvest, day advance).
///
/// Nothing in this class knows about UI, services or persistence. It only
/// receives the current [FarmTileModel] and returns a new instance, making the
/// logic easy to test and reuse.
final class FarmRuleEngine {
  const FarmRuleEngine();

  /// Ensures that we always work with a valid [FarmTileModel].
  FarmTileModel ensureTile(
    FarmTileModel? tile, {
    required int x,
    required int y,
  }) {
    return tile ?? FarmTileModel(x: x, y: y);
  }

  FarmTileModel? till(FarmTileModel tile) {
    if (tile.soilState != SoilStateModel.untilled) {
      developer.log(
        '[FarmRuleEngine] Soil already prepared at (${tile.x}, ${tile.y})',
      );
      return null;
    }
    return tile.till();
  }

  FarmTileModel? water(FarmTileModel tile) {
    if (tile.soilState == SoilStateModel.untilled) {
      developer.log(
        '[FarmRuleEngine] Cannot water untilled soil (${tile.x}, ${tile.y})',
      );
      return null;
    }
    return tile.water();
  }

  FarmTileModel? plant(FarmTileModel tile, String cropId) {
    if (!tile.canPlant) {
      developer.log('[FarmRuleEngine] Cannot plant at (${tile.x}, ${tile.y})');
      return null;
    }

    final crop = CropDatabase.createCrop(cropId);
    if (crop == null) {
      developer.log('[FarmRuleEngine] Invalid crop: $cropId');
      return null;
    }

    return tile.plant(crop);
  }

  ({FarmTileModel updatedTile, CropModel harvestedCrop})? harvest(
    FarmTileModel tile,
  ) {
    if (!tile.canHarvest) {
      developer.log(
        '[FarmRuleEngine] Nothing to harvest at (${tile.x}, ${tile.y})',
      );
      return null;
    }

    final harvestedCrop = tile.crop!;
    final updatedTile = tile.harvest();
    return (updatedTile: updatedTile, harvestedCrop: harvestedCrop);
  }

  FarmTileModel advanceDay(FarmTileModel tile, int dayEnded) {
    if (tile.crop == null) {
      if (_shouldConsumeWater(tile, dayEnded)) {
        return tile.copyWith(
          soilState: SoilStateModel.tilled,
          lastWateredDay: null,
        );
      }
      return tile;
    }

    return tile.advanceDay(dayEnded);
  }

  bool _shouldConsumeWater(FarmTileModel tile, int dayEnded) {
    return tile.soilState == SoilStateModel.watered &&
        tile.lastWateredDay == dayEnded;
  }
}
