import 'dart:developer' as developer;

import '../../world/entities/objects/farm/crop_entity.dart';
import '../../world/entities/objects/farm/crop_stage_type.dart';
import '../../data/game_data_constants.dart';

/// Service for creating crops from JSON database (L2: Factory with JSON database, I2: Service = stateless)
class CropFactoryService {
  final Map<String, Map<String, dynamic>> _database = {};
  bool _isInitialized = false;

  /// Initialize the service by loading the crop database
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('[CropFactoryService] Already initialized');
      return;
    }

    _database
      ..clear()
      ..addAll(
        CropDbConstants.crops.map(
          (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
        ),
      );

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
      final isTree = cropData['isTree'] as bool? ?? false;

      return CropEntity(
        cropId: cropId,
        name: cropData['name'] as String,
        description: cropData['description'] as String,
        // Trees start visible as seedlings; crops start as planted seeds.
        stage: isTree ? CropStageType.seedling : CropStageType.planted,
        daysPlanted: 0,
        daysToMature: _readInt(cropData['daysToMature'], defaultValue: 0),
        yieldAmount: _readInt(cropData['yieldAmount'], defaultValue: 1),
        harvestItemId: cropData['harvestItemId'] as String,
        requiredSeason: cropData['requiredSeason'] as String?,
        spritesheetPath: cropData['spritesheetPath'] as String,
        spriteWidth: _readInt(cropData['spriteWidth'], defaultValue: 16),
        spriteHeight: _readInt(cropData['spriteHeight'], defaultValue: 16),
        spriteRowIndex: _readInt(cropData['spriteRowIndex'], defaultValue: 0),
        framesCount: _readInt(cropData['framesCount'], defaultValue: 1),
        skipFirstFrames: _readInt(cropData['skipFirstFrames'], defaultValue: 0),
        ySortingFromStage: CropStageType.fromJsonNullable(
          cropData['ySortingFromStage'] as String?,
        ),
        isTree: isTree,
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
        .where(
          (e) =>
              e.value['requiredSeason'] == season ||
              e.value['requiredSeason'] == 'any' ||
              e.value['requiredSeason'] == null,
        )
        .map((e) => e.key)
        .toList();
  }

  /// Get raw crop data from database
  Map<String, dynamic>? getCropData(String cropId) {
    if (!_isInitialized) return null;
    return _database[cropId];
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  int _readInt(Object? value, {required int defaultValue}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return defaultValue;
  }
}
