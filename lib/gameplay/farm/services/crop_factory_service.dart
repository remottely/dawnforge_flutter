import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/database/modern_farm/modern_farm_crop_entity_database_def.dart';

import '../../inventory/entities/enums/hand_item_id.dart';
import '../../world/entities/objects/farm/crop_entity.dart';

/// Service for creating crops from JSON database (L2: Factory with JSON database, I2: Service = stateless)
class CropFactoryService {
  final Map<HandItemId, CropEntity> _database = {};
  bool _isInitialized = false;

  /// Initialize the service by loading the crop database
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('[CropFactoryService] Already initialized');
      return;
    }

    _database
      ..clear()
      ..addAll(ModernFarmCropEntityDatabaseDef.cropEntityList);

    _isInitialized = true;
    developer.log(
      '[CropFactoryService] Loaded ${_database.length} crops from constants',
    );
  }

  /// Create a crop instance from the database by cropId
  CropEntity? createCrop(HandItemId cropId) {
    if (!_isInitialized) {
      developer.log(
        '[CropFactoryService] ERROR: Not initialized! Call initialize() first',
      );
      return null;
    }

    final template = _database[cropId];
    if (template == null) {
      developer.log('[CropFactoryService] Crop not found: $cropId');
      return null;
    }

    try {
      return template.copyWith(daysPlanted: 0);
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
  List<HandItemId> getAllCropIds() {
    if (!_isInitialized) return [];
    return _database.keys.toList();
  }

  /// Get crops that can be planted in a specific season
  List<HandItemId> getCropsBySeason(String season) {
    if (!_isInitialized) return [];

    return _database.entries
        .where((e) {
          final requiredSeason = e.value.requiredSeason;
          return requiredSeason == null || requiredSeason == 'any' || requiredSeason == season;
        })
        .map((e) => e.key)
        .toList();
  }

  /// Get raw crop data from database
  CropEntity? getCropData(HandItemId cropId) {
    if (!_isInitialized) return null;
    return _database[cropId];
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
