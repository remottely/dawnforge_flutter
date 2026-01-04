import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../core/modules/world/world_state_manager.dart';
import '../../world/entities/world_entities.dart';

/// Manager for farm state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
class FarmManager {
  FarmManager._() {
    _initializeTiles();
    developer.log('[FarmManager] Initialized');
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
    developer.log('[FarmManager] Tiles initialized');
  }

  void notifyChange() {
    tilesNotifier.value = Map.unmodifiable(_tiles);
    developer.log('[FarmManager] Notifying tile changes');
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
    developer.log('[FarmManager] Watering tile at ($x, $y)');

    final tile = getTile(x, y);
    final farmObject = _getFarmObject(tile);
    if (tile == null || farmObject == null) {
      developer.log('[FarmManager] Cannot water missing tile');
      return false;
    }

    if (farmObject.soilState == SoilState.untilled) {
      developer.log('[FarmManager] Cannot water untilled soil');
      return false;
    }

    if (farmObject.soilState == SoilState.watered) {
      developer.log('[FarmManager] Tile already watered');
      return false;
    }

    final currentDay = WorldStateManager.instance.currentDay;
    final wateredFarmObject = farmObject.water(currentDay);
    final wateredTile = tile.placeObject(wateredFarmObject);

    setTile(wateredTile);
    notifyChange();

    developer.log('[FarmManager] ✓ Tile watered successfully');
    return true;
  }

  /// Plant a crop at coordinates
  bool plantSeed(int x, int y, CropEntity crop) {
    developer.log('[FarmManager] Planting ${crop.name} at ($x, $y)');

    final tile = getTile(x, y);
    final farmObject = _getFarmObject(tile);
    if (tile == null || farmObject == null) {
      developer.log('[FarmManager] No tile at ($x, $y)');
      return false;
    }

    final bool canPlantHere = crop.isTree
        ? farmObject.canPlantTree
        : farmObject.canPlantCrop;

    if (!canPlantHere) {
      if (farmObject.isOccupied) {
        developer.log('[FarmManager] Tile already has a crop');
      } else {
        developer.log(
          '[FarmManager] Soil not prepared for planting '
          '(${crop.isTree ? 'needs untilled for trees' : 'needs tilled/watered for crops'})',
        );
      }
      return false;
    }

    final plantedFarmObject = crop.isTree
        ? farmObject.plantTree(crop)
        : farmObject.plant(crop);
    final plantedTile = tile.placeObject(plantedFarmObject);
    setTile(plantedTile);
    notifyChange();

    developer.log(
      '[FarmManager] ✓ ${crop.name} planted successfully at ($x,$y) '
      'soil:${plantedFarmObject.soilState.name} stage:${crop.stage.name}',
      name: 'farm.manager.plant',
    );
    return true;
  }

  /// Harvest crop at coordinates
  CropEntity? harvestCrop(int x, int y) {
    developer.log('[FarmManager] Harvesting crop at ($x, $y)');

    final tile = getTile(x, y);
    final farmObject = _getFarmObject(tile);
    if (tile == null || farmObject == null) {
      developer.log('[FarmManager] No tile at ($x, $y)');
      return null;
    }

    if (!farmObject.canHarvest) {
      if (farmObject.isEmpty) {
        developer.log('[FarmManager] No crop to harvest');
      } else {
        developer.log('[FarmManager] Crop not ready to harvest');
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

    developer.log(
      '[FarmManager] ✓ Harvested ${harvestedCrop.yieldAmount}x ${harvestedCrop.name} '
      'at ($x,$y) -> soil:${harvestedFarmObject.soilState.name} crop:${harvestedFarmObject.crop?.cropId ?? "none"}',
      name: 'farm.manager.harvest',
    );
    return harvestedCrop;
  }

  /// Advance day for all crops
  void advanceDay() {
    developer.log('[FarmManager] Advancing all crops for new day');

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
        developer.log(
          '[FarmManager] ↻ advanced tile (${
            tile.x
          },${tile.y}) '
          'soil ${farmObject.soilState.name} -> ${advancedFarmObject.soilState.name}, '
          'crop ${farmObject.crop?.cropId ?? "none"}/${farmObject.crop?.stage.name ?? "none"} '
          '-> ${advancedFarmObject.crop?.cropId ?? "none"}/${advancedFarmObject.crop?.stage.name ?? "none"}',
          name: 'farm.manager.advance',
        );
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
    CropEntity? Function(String cropId) cropFactory,
  ) {
    _tiles.clear();

    final tilesData = json['tiles'] as List<dynamic>?;
    if (tilesData == null) {
      developer.log('[FarmManager] No tiles to load');
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
