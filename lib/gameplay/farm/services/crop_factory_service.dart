import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart' show rootBundle;

import '../entities/crop/crop_entity.dart';
import '../entities/crop/crop_stage_type.dart';

/// Service for creating crops from JSON database (L2: Factory with JSON database, I2: Service = stateless)
class CropFactoryService {
  final Map<String, Map<String, dynamic>> _database = {};
  bool _isInitialized = false;

  static const String _kDatabasePath = 'assets/database/crops_database.json';

  /// Initialize the service by loading the crop database
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('[CropFactoryService] Already initialized');
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(_kDatabasePath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      for (final entry in jsonData.entries) {
        _database[entry.key] = entry.value as Map<String, dynamic>;
      }

      _isInitialized = true;
      developer.log(
        '[CropFactoryService] Loaded ${_database.length} crops',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[CropFactoryService] ERROR loading database',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
        name: cropData['name'] as String,
        description: cropData['description'] as String,
        stage: CropStageType.planted,
        daysPlanted: 0,
        daysToMature: cropData['daysToMature'] as int,
        yieldAmount: cropData['yieldAmount'] as int,
        harvestItemId: cropData['harvestItemId'] as String,
        requiredSeason: cropData['requiredSeason'] as String?,
        spritesheetPath: cropData['spritesheetPath'] as String,
        spriteWidth: (cropData['spriteWidth'] as int?) ?? 16,
        spriteHeight: (cropData['spriteHeight'] as int?) ?? 16,
        spriteRowIndex: cropData['spriteRowIndex'] as int,
        framesCount: cropData['framesCount'] as int,
        skipFirstFrames: (cropData['skipFirstFrames'] as int?) ?? 0,
        ySortingFromStage: CropStageType.fromJson(
          (cropData['ySortingFromStage'] as String?) ?? 'seed',
        ),
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
}
