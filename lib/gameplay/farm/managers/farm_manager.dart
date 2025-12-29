import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../core/modules/world/world_state_manager.dart';
import '../entities/crop.dart';
import '../entities/farm_tile.dart';
import '../entities/soil_state.dart';

/// Manager for farm state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
class FarmManager {
  FarmManager._() {
    _initializeTiles();
    developer.log('[FarmManager] Initialized');
  }

  static final instance = FarmManager._();

  final Map<String, FarmTile> _tiles = {}; // key: "x,y"

  /// C1: ValueNotifier para reatividade
  late final ValueNotifier<Map<String, FarmTile>> tilesNotifier;

  /// J3: ValueNotifiers para cross-module communication
  final ValueNotifier<FarmTile?> lastTilledNotifier = ValueNotifier(null);
  final ValueNotifier<Crop?> lastHarvestedNotifier = ValueNotifier(null);

  void _initializeTiles() {
    // Initialize with empty tiles if needed
    // For now, tiles are created on-demand
    tilesNotifier = ValueNotifier(Map.unmodifiable(_tiles));
    developer.log('[FarmManager] Tiles initialized');
  }

  void notifyChange() {
    tilesNotifier.value = Map.unmodifiable(_tiles);
    developer.log('[FarmManager] Notifying tile changes');
  }

  String _makeKey(int x, int y) => '$x,$y';

  /// Get a tile at specific coordinates
  FarmTile? getTile(int x, int y) {
    return _tiles[_makeKey(x, y)];
  }

  /// Get all tiles
  List<FarmTile> getAllTiles() {
    return _tiles.values.toList();
  }

  /// Update or create a tile
  void setTile(FarmTile tile) {
    _tiles[_makeKey(tile.x, tile.y)] = tile;
  }

  /// Water tile at coordinates
  bool waterTile(int x, int y) {
    developer.log('[FarmManager] Watering tile at ($x, $y)');

    final tile = getTile(x, y);
    if (tile == null) {
      developer.log('[FarmManager] Cannot water missing tile');
      return false;
    }

    if (tile.soilState == SoilState.untilled) {
      developer.log('[FarmManager] Cannot water untilled soil');
      return false;
    }

    if (tile.soilState == SoilState.watered) {
      developer.log('[FarmManager] Tile already watered');
      return false;
    }

    final currentDay = WorldStateManager.instance.currentDay;
    final wateredTile = tile.water(currentDay);

    setTile(wateredTile);
    notifyChange();

    developer.log('[FarmManager] ✓ Tile watered successfully');
    return true;
  }

  /// Plant a crop at coordinates
  bool plantSeed(int x, int y, Crop crop) {
    developer.log('[FarmManager] Planting ${crop.name} at ($x, $y)');

    final tile = getTile(x, y);
    if (tile == null) {
      developer.log('[FarmManager] No tile at ($x, $y)');
      return false;
    }

    if (!tile.canPlant) {
      if (tile.isOccupied) {
        developer.log('[FarmManager] Tile already has a crop');
      } else {
        developer.log('[FarmManager] Soil not prepared for planting');
      }
      return false;
    }

    final plantedTile = tile.plant(crop);
    setTile(plantedTile);
    notifyChange();

    developer.log('[FarmManager] ✓ ${crop.name} planted successfully');
    return true;
  }

  /// Harvest crop at coordinates
  Crop? harvestCrop(int x, int y) {
    developer.log('[FarmManager] Harvesting crop at ($x, $y)');

    final tile = getTile(x, y);
    if (tile == null) {
      developer.log('[FarmManager] No tile at ($x, $y)');
      return null;
    }

    if (!tile.canHarvest) {
      if (tile.isEmpty) {
        developer.log('[FarmManager] No crop to harvest');
      } else {
        developer.log('[FarmManager] Crop not ready to harvest');
      }
      return null;
    }

    final harvestedCrop = tile.crop!;
    final harvestedTile = tile.harvest();

    setTile(harvestedTile);
    lastHarvestedNotifier.value =
        harvestedCrop; // J3: Cross-module notification
    notifyChange();

    developer.log(
      '[FarmManager] ✓ Harvested ${harvestedCrop.yieldAmount}x ${harvestedCrop.name}',
    );
    return harvestedCrop;
  }

  /// Advance day for all crops
  void advanceDay() {
    developer.log('[FarmManager] Advancing all crops for new day');

    final dayEnded = WorldStateManager.instance.currentDay - 1;
    var cropsGrown = 0;

    for (final tile in _tiles.values.toList()) {
      final advancedTile = tile.advanceDay(dayEnded);
      
      // Track crop growth
      if (tile.crop != null && advancedTile.crop != null) {
        final beforeDays = tile.crop!.daysPlanted;
        final afterDays = advancedTile.crop!.daysPlanted;
        
        if (afterDays > beforeDays) {
          cropsGrown++;
        }
      }

      setTile(advancedTile);
    }

    notifyChange();

    developer.log(
      '[FarmManager] ✓ Advanced $cropsGrown crops for day $dayEnded',
    );
  }

  /// Serialization (E2)
  Map<String, dynamic> toJson() {
    final tilesData = _tiles.values.map((t) => t.toJson()).toList();

    return {'tiles': tilesData};
  }

  /// Deserialization (E2)
  void fromJson(
    Map<String, dynamic> json,
    Crop? Function(String cropId) cropFactory,
  ) {
    _tiles.clear();

    final tilesData = json['tiles'] as List<dynamic>?;
    if (tilesData == null) {
      developer.log('[FarmManager] No tiles to load');
      notifyChange();
      return;
    }

    for (final tileJson in tilesData) {
      final tile = FarmTile.fromJson(
        tileJson as Map<String, dynamic>,
        cropFactory,
      );
      setTile(tile);
    }

    developer.log('[FarmManager] Loaded ${_tiles.length} tiles from JSON');
    notifyChange();
  }

  /// Clear all tiles
  void clear() {
    _tiles.clear();
    lastTilledNotifier.value = null;
    lastHarvestedNotifier.value = null;
    notifyChange();
    developer.log('[FarmManager] All tiles cleared');
  }

  /// Reset farm state
  void reset() {
    _tiles.clear();
    lastTilledNotifier.value = null;
    lastHarvestedNotifier.value = null;
    notifyChange();
    developer.log('[FarmManager] Farm state reset');
  }
}
