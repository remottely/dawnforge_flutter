import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/data/farm_tile_store.dart';
import 'package:darkness_dungeon/gameplay/farm/domain/farm_rule_engine.dart';
import 'package:darkness_dungeon/gameplay/farm/models/crop_model.dart';
import 'package:darkness_dungeon/gameplay/farm/models/farm_tile_model.dart';

final class FarmManager {
  FarmManager._();

  static final instance = FarmManager._();

  final FarmTileStore _store = FarmTileStore();
  final FarmRuleEngine _rules = const FarmRuleEngine();

  FarmTileModel? getTile(int x, int y) {
    return _store.getTile(x, y);
  }

  void setTile(FarmTileModel tile) {
    _store.saveTile(tile);
  }

  List<FarmTileModel> getAllTiles() => _store.getAllTiles();

  void clearAll() {
    _store.clear();
    developer.log('[FarmManager] All tiles cleared');
  }

  void reset() {
    _store.clear();
    developer.log('[FarmManager] Farm state reset');
  }

  bool tillSoil(int x, int y) {
    developer.log('[FarmManager] Tilling soil at ($x, $y)');

    // TODO(Kevin): Validar que player tem enxada equipada
    // if (!_playerHasTool('hoe')) {
    //   developer.log('[FarmManager] Player needs hoe');
    //   return false;
    // }

    final tile = _rules.ensureTile(getTile(x, y), x: x, y: y);
    final updatedTile = _rules.till(tile);
    if (updatedTile == null) {
      return false;
    }

    _store.saveTile(updatedTile);
    developer.log('[FarmManager] ✓ Soil tilled successfully');
    return true;
  }

  bool waterTile(int x, int y) {
    developer.log('[FarmManager] Watering tile at ($x, $y)');

    // TODO(Kevin): Validar que player tem regador equipado
    // if (!_playerHasTool('watering_can')) {
    //   developer.log('[FarmManager] Player needs watering can');
    //   return false;
    // }

    final tile = getTile(x, y);
    if (tile == null) {
      developer.log('[FarmManager] Cannot water missing tile');
      return false;
    }

    final updatedTile = _rules.water(tile);
    if (updatedTile == null) {
      return false;
    }

    _store.saveTile(updatedTile);
    developer.log('[FarmManager] ✓ Tile watered successfully');
    return true;
  }

  bool plantSeed(int x, int y, String cropId) {
    developer.log('[FarmManager] Planting $cropId at ($x, $y)');

    // TODO(Kevin): Validar que player tem seed no inventário
    // if (!InventoryManager.instance.hasItem(seedItemId, 1)) {
    //   developer.log('[FarmManager] Player does not have seed');
    //   return false;
    // }

    // TODO(Kevin): Validar estação atual
    // final currentSeason = WorldStateManager.instance.currentSeason;

    final tile = getTile(x, y);
    if (tile == null || !tile.canPlant) {
      developer.log('[FarmManager] Cannot plant on this tile');
      return false;
    }

    final updatedTile = _rules.plant(tile, cropId);
    if (updatedTile == null) {
      return false;
    }

    _store.saveTile(updatedTile);

    // TODO(Kevin): Remover seed do inventário
    // InventoryManager.instance.removeItem(seedItemId, 1);

    developer.log('[FarmManager] ✓ Seed planted successfully');
    return true;
  }

  CropModel? harvestCrop(int x, int y) {
    developer.log('[FarmManager] Harvesting crop at ($x, $y)');

    final tile = getTile(x, y);
    if (tile == null || !tile.canHarvest) {
      developer.log('[FarmManager] Nothing to harvest');
      return null;
    }

    final result = _rules.harvest(tile);
    if (result == null) {
      return null;
    }

    _store.saveTile(result.updatedTile);

    developer.log(
      '[FarmManager] ✓ Harvested ${result.harvestedCrop.yieldAmount}x ${result.harvestedCrop.name}',
    );
    return result.harvestedCrop;
  }

  void advanceDay() {
    developer.log('[FarmManager] Advancing all crops for new day');

    final dayEnded = WorldStateManager.instance.currentDay - 1;

    var cropsGrown = 0;
    final tiles = _store.getAllTiles();
    for (final oldTile in tiles) {
      final beforeDays = oldTile.crop?.daysPlanted;
      final newTile = _rules.advanceDay(oldTile, dayEnded);
      final afterDays = newTile.crop?.daysPlanted;

      if (beforeDays != null && afterDays != null && afterDays > beforeDays) {
        cropsGrown++;
      }

      _store.saveTile(newTile);
    }

    developer.log(
      '[FarmManager] ✓ Advanced $cropsGrown crops for day $dayEnded',
    );
  }

  Map<String, dynamic> toJson() => _store.toJson();

  void fromJson(Map<String, dynamic> json) {
    _store.fromJson(json);
  }
}
