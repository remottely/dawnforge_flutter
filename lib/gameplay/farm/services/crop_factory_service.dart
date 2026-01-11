import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:dawnforge/gameplay/database/modern_farm/modern_farm_crop_entity_database_def.dart';

import '../../inventory/entities/enums/hand_item_id.dart';
import '../../world/entities/objects/farm/crop_entity.dart';

/// Service for creating crops from JSON database (L2: Factory with JSON database, I2: Service = stateless)
class CropFactoryService {
  final Map<HandItemId, CropEntity> _database = {};
  bool _isInitialized = false;

  /// Initialize the service by loading the crop database
  Future<void> initialize() async {
    if (_isInitialized) {
      GameLogger.info('[CropFactoryService] Already initialized');
      return;
    }

    _database
      ..clear()
      ..addAll(ModernFarmCropEntityDatabaseDef.cropEntityList);

    _isInitialized = true;
    GameLogger.info(
      '[CropFactoryService] Loaded ${_database.length} crops from constants',
    );
  }

  /// Create a crop instance from the database by cropId
  CropEntity? createCrop(HandItemId cropId) {
    if (!_isInitialized) {
      GameLogger.error(
        '[CropFactoryService] ERROR: Not initialized! Call initialize() first',
      );
      return null;
    }

    final template = _database[cropId];
    if (template == null) {
      GameLogger.warning('[CropFactoryService] Crop not found: $cropId');
      return null;
    }

    try {
      return template.copyWith(
        daysPlanted: 0,
        regrowData: template.regrowData.resetState(),
      );
    } catch (e, stackTrace) {
      GameLogger.error(
        '[CropFactoryService] ERROR creating crop $cropId: $e\n$stackTrace',
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
          return requiredSeason == 'any' || requiredSeason == season;
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
