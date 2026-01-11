

import 'package:dawnforge/core/utils/logger/game_logger.dart';


import 'package:flutter/foundation.dart';

import '../../core/modules/world/world_state_manager.dart';
import '../../world/entities/world_entities.dart';

/// Manager for farm state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
class FarmManager {
  FarmManager._() {
    _initializeTiles();
    GameLogger.info('[FarmManager] Initialized');
  }

  static final instance = FarmManager._();

  final Map<String, GridTile> _tiles = {}; // key: "x,y"

  /// C1: ValueNotifier para reatividade
  late final ValueNotifier<Map<String, GridTile>> tilesNotifier;

  /// J3: ValueNotifiers para cross-module communication
  final ValueNotifier<GridTile?> lastTilledNotifier = ValueNotifier(null);
  final ValueNotifier<CropEntity?> lastHarvestedNotifier = ValueNotifier(null);

  void _initializeTiles() {
    // Initialize with empty tiles if needed
    // For now, tiles are created on-demand
    tilesNotifier = ValueNotifier(Map.unmodifiable(_tiles));
    GameLogger.info('[FarmManager] Tiles initialized');
  }

  void notifyChange() {
    tilesNotifier.value = Map.unmodifiable(_tiles);
    GameLogger.info('[FarmManager] Notifying tile changes');
  }

  String _makeKey(int x, int y) => '$x,$y';

  /// Get a tile at specific coordinates
  GridTile? getTile(int x, int y) {
    return _tiles[_makeKey(x, y)];
  }

  /// Get all tiles
  List<GridTile> getAllTiles() {
    return _tiles.values.toList();
  }

  /// Update or create a tile
  void setTile(GridTile tile) {
    _tiles[_makeKey(tile.x, tile.y)] = tile;
  }

  /// Get FarmObject from tile (helper)
  FarmObject? _getFarmObject(GridTile? tile) {
    return tile?.object as FarmObject?;
  }

  /// Water tile at coordinates
  bool waterTile(int x, int y) {
    GameLogger.info('[FarmManager] Watering tile at ($x, $y)');

    final tile = getTile(x, y);
    final farmObject = _getFarmObject(tile);
    if (tile == null || farmObject == null) {
      GameLogger.warning('[FarmManager] Cannot water missing tile');
      return false;
    }

    if (farmObject.soilState == SoilState.untilled) {
      GameLogger.warning('[FarmManager] Cannot water untilled soil');
      return false;
    }

    if (farmObject.soilState == SoilState.watered) {
      GameLogger.info('[FarmManager] Tile already watered');
      return false;
    }

    final currentDay = WorldStateManager.instance.currentDay;
    final wateredFarmObject = farmObject.water(currentDay);
    final wateredTile = tile.placeObject(wateredFarmObject);

    setTile(wateredTile);
    notifyChange();

    GameLogger.info('[FarmManager] ✓ Tile watered successfully');
    return true;
  }

  /// Plant a crop at coordinates
  bool plantSeed(int x, int y, CropEntity crop) {
    GameLogger.info('[FarmManager] Planting ${crop.name} at ($x, $y)');

    final tile = getTile(x, y);
    final farmObject = _getFarmObject(tile);
    if (tile == null || farmObject == null) {
      GameLogger.warning('[FarmManager] No tile at ($x, $y)');
      return false;
    }

    final bool canPlantHere = crop.isTree
        ? farmObject.canPlantTree
        : farmObject.canPlantCrop;

    if (!canPlantHere) {
      if (farmObject.isOccupied) {
        GameLogger.warning('[FarmManager] Tile already has a crop');
      } else {
        GameLogger.warning('[FarmManager] Soil not prepared for planting (${crop.isTree ? 'needs untilled for trees' : 'needs tilled/watered for crops'})');
      }
      return false;
    }

    final plantedFarmObject = crop.isTree
        ? farmObject.plantTree(crop)
        : farmObject.plant(crop);
    final plantedTile = tile.placeObject(plantedFarmObject);
    setTile(plantedTile);
    notifyChange();

    GameLogger.info('[FarmManager] ✓ ${crop.name} planted successfully at ($x,$y) soil:${plantedFarmObject.soilState.name} stage:${crop.stage.name}');
    return true;
  }

  /// Harvest crop at coordinates
  CropEntity? harvestCrop(int x, int y) {
    GameLogger.info('[FarmManager] Harvesting crop at ($x, $y)');

    final tile = getTile(x, y);
    final farmObject = _getFarmObject(tile);
    if (tile == null || farmObject == null) {
      GameLogger.warning('[FarmManager] No tile at ($x, $y)');
      return null;
    }

    if (!farmObject.canHarvest) {
      if (farmObject.isEmpty) {
        GameLogger.warning('[FarmManager] No crop to harvest');
      } else {
        GameLogger.warning('[FarmManager] Crop not ready to harvest');
      }
      return null;
    }

    final harvestedCrop = farmObject.crop!;
    final harvestedFarmObject = farmObject.harvest();
    final harvestedTile = tile.placeObject(harvestedFarmObject);

    setTile(harvestedTile);
    lastHarvestedNotifier.value =
        harvestedCrop; // J3: Cross-module notification
    notifyChange();

    GameLogger.info('[FarmManager] ✓ Harvested ${harvestedCrop.yieldAmount}x ${harvestedCrop.name} at ($x,$y) -> soil:${harvestedFarmObject.soilState.name} crop:${harvestedFarmObject.crop?.id ?? "none"}');
    return harvestedCrop;
  }

  /// Advance day for all crops
  void advanceDay() {
    GameLogger.info('[FarmManager] Advancing all crops for new day');

    final dayEnded = WorldStateManager.instance.currentDay - 1;
    var cropsGrown = 0;

    for (final tile in _tiles.values.toList()) {
      final farmObject = _getFarmObject(tile);
      if (farmObject == null) continue;

      final advancedFarmObject = farmObject.advanceDay(dayEnded);
      final advancedTile = tile.placeObject(advancedFarmObject);
      
      // Track crop growth
      if (farmObject.crop != null && advancedFarmObject.crop != null) {
        final beforeDays = farmObject.crop!.daysPlanted;
        final afterDays = advancedFarmObject.crop!.daysPlanted;
        
        if (afterDays > beforeDays) {
          cropsGrown++;
        }
      }

      if (farmObject.crop != advancedFarmObject.crop ||
          farmObject.soilState != advancedFarmObject.soilState) {
        GameLogger.info('[FarmManager] ↻ advanced tile (${tile.x},${tile.y}) soil ${farmObject.soilState.name} -> ${advancedFarmObject.soilState.name}, crop ${farmObject.crop?.id ?? "none"}/${farmObject.crop?.stage.name ?? "none"} -> ${advancedFarmObject.crop?.id ?? "none"}/${advancedFarmObject.crop?.stage.name ?? "none"}');
      }

      setTile(advancedTile);
    }

    notifyChange();

    GameLogger.info('[FarmManager] ✓ Advanced $cropsGrown crops for day $dayEnded');
  }

  /// Serialization (E2)
  Map<String, dynamic> toJson() {
    final tilesData = _tiles.values.map((t) => t.toJson()).toList();

    return {'tiles': tilesData};
  }

  /// Deserialization (E2)
  void fromJson(
    Map<String, dynamic> json,
    // CropEntity? Function(HandItemId cropId) cropFactory,
  ) {
    _tiles.clear();

    final tilesData = json['tiles'] as List<dynamic>?;
    if (tilesData == null) {
      GameLogger.warning('[FarmManager] No tiles to load');
      notifyChange();
      return;
    }

    for (final tileJson in tilesData) {
      final tileData = tileJson as Map<String, dynamic>;
      
      // GridTile.toJson() salva: {x, y, object, metadata}
      // Precisamos reconstruir o GridTile a partir disso
      final objectData = tileData['object'] as Map<String, dynamic>?;
      final FarmObject? farmObject = objectData != null 
          ? FarmObject.fromJson(objectData)
          : null;
      
      final tile = GridTile(
        x: tileData['x'] as int,
        y: tileData['y'] as int,
        object: farmObject,
        metadata: tileData['metadata'] as Map<String, dynamic>?,
      );
      setTile(tile);
    }

    GameLogger.info('[FarmManager] Loaded ${_tiles.length} tiles from JSON');
    notifyChange();
  }

  /// Clear all tiles
  void clear() {
    _tiles.clear();
    lastTilledNotifier.value = null;
    lastHarvestedNotifier.value = null;
    notifyChange();
    GameLogger.info('[FarmManager] All tiles cleared');
  }

  /// Reset farm state
  void reset() {
    _tiles.clear();
    lastTilledNotifier.value = null;
    lastHarvestedNotifier.value = null;
    notifyChange();
    GameLogger.info('[FarmManager] Farm state reset');
  }
}
