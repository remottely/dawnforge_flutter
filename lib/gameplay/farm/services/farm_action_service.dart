import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/models/crop_model.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';

final class FarmActionService {
  FarmActionService._();

  static final instance = FarmActionService._();

  FarmActionResult tillSoil(int x, int y) {
    developer.log('[FarmActionService] Attempting to till soil at ($x, $y)');

    final success = FarmManager.instance.tillSoil(x, y);

    if (success) {
      developer.log('[FarmActionService] ✅ Soil tilled successfully');
      return FarmActionResult.success();
    }

    developer.log('[FarmActionService] ❌ Failed to till soil');
    return FarmActionResult.failure('Cannot till at this location');
  }

  FarmActionResult waterTile(int x, int y) {
    developer.log('[FarmActionService] Attempting to water tile at ($x, $y)');

    final success = FarmManager.instance.waterTile(x, y);

    if (success) {
      developer.log('[FarmActionService] ✅ Tile watered successfully');
      return FarmActionResult.success();
    }

    developer.log('[FarmActionService] ❌ Failed to water tile');
    return FarmActionResult.failure('Cannot water at this location');
  }

  /// TODO: Integrate with inventory to check for strawberries and consume them.
  FarmActionResult plantSeed(int x, int y, String cropId) {
    developer.log(
      '[FarmActionService] Attempting to plant $cropId at ($x, $y)',
    );

    final success = FarmManager.instance.plantSeed(x, y, cropId);

    if (success) {
      developer.log('[FarmActionService] ✅ Seed planted successfully');
      return FarmActionResult.success();
    }

    developer.log('[FarmActionService] ❌ Failed to plant seed');
    return FarmActionResult.failure('Cannot plant at this location');
  }

  HarvestResult harvestCrop(int x, int y) {
    developer.log('[FarmActionService] Attempting to harvest at ($x, $y)');

    final crop = FarmManager.instance.harvestCrop(x, y);

    if (crop == null) {
      developer.log('[FarmActionService] ❌ Nothing to harvest');
      return HarvestResult.failure();
    }

    developer.log(
      '[FarmActionService] ✅ Harvested ${crop.yieldAmount}x ${crop.name}',
    );

    final inventoryResult = _addHarvestToInventory(crop);

    return HarvestResult.success(crop: crop, addedToInventory: inventoryResult);
  }

  bool _addHarvestToInventory(CropModel crop) {
    final harvestItem = ItemFactory.createItem(crop.harvestItemId);

    if (harvestItem == null) {
      developer.log(
        '[FarmActionService] ⚠️ Harvest item not found: ${crop.harvestItemId}',
      );
      return false;
    }

    final success = InventoryManager.instance.addItem(
      harvestItem,
      crop.yieldAmount,
    );

    if (success) {
      developer.log(
        '[FarmActionService] 🎒 Added ${crop.yieldAmount}x ${harvestItem.name} to inventory',
      );
    } else {
      developer.log('[FarmActionService] ⚠️ Inventory full, items lost!');
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
  final CropModel? crop;
  final bool addedToInventory;

  const HarvestResult._({
    required this.success,
    this.crop,
    this.addedToInventory = false,
  });

  factory HarvestResult.success({
    required CropModel crop,
    required bool addedToInventory,
  }) => HarvestResult._(
    success: true,
    crop: crop,
    addedToInventory: addedToInventory,
  );

  factory HarvestResult.failure() => const HarvestResult._(success: false);
}
