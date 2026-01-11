import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:dawnforge/gameplay/world/entities/objects/farm/crop_entity.dart';
import 'package:dawnforge/gameplay/farm/managers/farm_manager.dart';
import 'package:dawnforge/gameplay/farm/usecases/till_soil_use_case.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/gameplay/inventory/services/item_factory_service.dart';
import 'package:dawnforge/gameplay/inventory/usecases/add_item_use_case.dart';

final class FarmActionService {
  FarmActionService._();

  static final instance = FarmActionService._();

  FarmActionResult tillSoil(int x, int y) {
    GameLogger.info('[FarmActionService] Attempting to till soil at ($x, $y)');

    final success = getIt<TillSoilUseCase>().call(x, y);
    // final success = getIt<FarmManager>().tillSoil(x, y);

    if (success) {
      GameLogger.info('[FarmActionService] ✅ Soil tilled successfully');
      return FarmActionResult.success();
    }

    GameLogger.warning('[FarmActionService] ❌ Failed to till soil');
    return FarmActionResult.failure('Cannot till at this location');
  }

  FarmActionResult waterTile(int x, int y) {
    GameLogger.info('[FarmActionService] Attempting to water tile at ($x, $y)');

    final success = getIt<FarmManager>().waterTile(x, y);

    if (success) {
      GameLogger.info('[FarmActionService] ✅ Tile watered successfully');
      return FarmActionResult.success();
    }

    GameLogger.warning('[FarmActionService] ❌ Failed to water tile');
    return FarmActionResult.failure('Cannot water at this location');
  }

  /// TODO: Integrate with inventory to check for strawberries and consume them.
  FarmActionResult plantSeed(int x, int y, CropEntity crop) {
    GameLogger.info(
      '[FarmActionService] Attempting to plant ${crop.id} at ($x, $y)',
    );

    final success = getIt<FarmManager>().plantSeed(x, y, crop);

    if (success) {
      GameLogger.info('[FarmActionService] ✅ Seed planted successfully');
      return FarmActionResult.success();
    }

    GameLogger.warning('[FarmActionService] ❌ Failed to plant seed');
    return FarmActionResult.failure('Cannot plant at this location');
  }

  HarvestResult harvestCrop(int x, int y) {
    GameLogger.info('[FarmActionService] Attempting to harvest at ($x, $y)');

    final crop = getIt<FarmManager>().harvestCrop(x, y);

    if (crop == null) {
      GameLogger.warning('[FarmActionService] ❌ Nothing to harvest');
      return HarvestResult.failure();
    }

    GameLogger.info(
      '[FarmActionService] ✅ Harvested ${crop.yieldAmount}x ${crop.name}',
    );

    final inventoryResult = _addHarvestToInventory(crop);

    return HarvestResult.success(crop: crop, addedToInventory: inventoryResult);
  }

  bool _addHarvestToInventory(CropEntity crop) {
    final harvestItem = getIt<ItemFactoryService>().createItem(
      crop.harvestItemId,
    );

    if (harvestItem == null) {
      GameLogger.warning(
        '[FarmActionService] ⚠️ Harvest item not found: ${crop.harvestItemId}',
      );
      return false;
    }

    final success = getIt<AddItemUseCase>().addItemEntity(
      harvestItem,
      crop.yieldAmount,
    );

    if (success) {
      GameLogger.info(
        '[FarmActionService] 🎒 Added ${crop.yieldAmount}x ${harvestItem.name} to inventory',
      );
    } else {
      GameLogger.warning('[FarmActionService] ⚠️ Inventory full, items lost!');
    }

    return success;
  }
}

final class FarmActionResult {
  final bool success;
  final String? errorMessage;

  const FarmActionResult._({required this.success, this.errorMessage});

  factory FarmActionResult.success() => const FarmActionResult._(success: true);

  factory FarmActionResult.failure(String message) =>
      FarmActionResult._(success: false, errorMessage: message);
}

final class HarvestResult {
  final bool success;
  final CropEntity? crop;
  final bool addedToInventory;

  const HarvestResult._({
    required this.success,
    this.crop,
    this.addedToInventory = false,
  });

  factory HarvestResult.success({
    required CropEntity crop,
    required bool addedToInventory,
  }) => HarvestResult._(
    success: true,
    crop: crop,
    addedToInventory: addedToInventory,
  );

  factory HarvestResult.failure() => const HarvestResult._(success: false);
}
