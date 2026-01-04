import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/database/crop_data.dart';

import '../../world/entities/objects/farm/crop_entity.dart';
import '../../world/entities/objects/farm/crop_stage_type.dart';

/// Service for creating crops from JSON database (L2: Factory with JSON database, I2: Service = stateless)
class CropFactoryService {
  final Map<String, CropData> _database = {};
  bool _isInitialized = false;

  /// Initialize the service by loading the crop database
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('[CropFactoryService] Already initialized');
      return;
    }

    _database
      ..clear()
      ..addAll(CropDatabaseDef.crops);

    _isInitialized = true;
    developer.log(
      '[CropFactoryService] Loaded ${_database.length} crops from constants',
    );
  }

  /// Create a crop instance from the database by cropId
  CropEntity? createCrop(String cropId) {
    if (!_isInitialized) {
      developer.log(
        '[CropFactoryService] ERROR: Not initialized! Call initialize() first',
      );
      return null;
    }

    final cropData = _database[cropId];
    if (cropData == null) {
      developer.log('[CropFactoryService] Crop not found: $cropId');
      return null;
    }

    try {
      return CropEntity(
        cropId: cropId,
        name: cropData.name,
        description: cropData.description,
        // Trees start visible as seedlings; crops start as planted seeds.
        stage: cropData.isTree ? CropStageType.seedling : CropStageType.planted,
        daysPlanted: 0,
        daysToMature: cropData.daysToMature ?? 0,
        yieldAmount: cropData.yieldAmount,
        harvestItemId: cropData.harvestItemId,
        requiredSeason: cropData.requiredSeason,
        spritesheetPath: cropData.spritesheetPath,
        spriteWidth: cropData.spriteWidth,
        spriteHeight: cropData.spriteHeight,
        spriteRowIndex: cropData.spriteRowIndex,
        framesCount: cropData.framesCount,
        skipFirstFrames: cropData.skipFirstFrames,
        ySortingFromStage: cropData.ySortingFromStage,
        isTree: cropData.isTree,
      );
    } catch (e, stackTrace) {
      developer.log(
        '[CropFactoryService] ERROR creating crop $cropId',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get all available crop IDs
  List<String> getAllCropIds() {
    if (!_isInitialized) return [];
    return _database.keys.toList();
  }

  /// Get crops that can be planted in a specific season
  List<String> getCropsBySeason(String season) {
    if (!_isInitialized) return [];

    return _database.entries
        .where((e) {
          final requiredSeason = e.value.requiredSeason;
          return requiredSeason == 'any' || requiredSeason == season;
        })
        .map((e) => e.key)
        .toList();
  }

  /// Get raw crop data from database
  CropData? getCropData(String cropId) {
    if (!_isInitialized) return null;
    return _database[cropId];
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
