import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/database/modern_farm/modern_farm_crop_database_def.dart';

import '../../world/entities/objects/farm/crop_entity.dart';
import '../models/crop_model.dart';

final class CropDatabase {
  CropDatabase._();

  static final Map<String, CropEntity> _cropDatabase = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _cropDatabase
      ..clear()
      ..addAll(ModernFarmCropDatabaseDef.crops);

    _isInitialized = true;
    developer.log('[CropDatabase] Loaded ${_cropDatabase.length} crops');
  }

  static CropModel? createCrop(String cropId) {
    if (!_isInitialized) {
      developer.log('[CropDatabase] ERROR: Not initialized!');
      return null;
    }

    final template = _cropDatabase[cropId];
    if (template == null) {
      developer.log('[CropDatabase] Crop not found: $cropId');
      return null;
    }

    return CropModel(
      cropId: cropId,
      name: template.name,
      description: template.description,
      stage: template.stage,
      daysPlanted: 0,
      daysToMature: template.daysToMature,
      yieldAmount: template.yieldAmount,
      harvestItemId: template.harvestItemId,
      requiredSeason: template.requiredSeason,
      spritesheetPath: template.spritesheetPath,
      spriteWidth: template.spriteWidth,
      spriteHeight: template.spriteHeight,
      spriteRowIndex: template.spriteRowIndex,
      framesCount: template.framesCount,
      skipFirstFrames: template.skipFirstFrames,
      ySortingFromStage: template.ySortingFromStage ?? template.stage,
    );
  }

  static List<String> getAllCropIds() => _cropDatabase.keys.toList();

  static List<String> getCropsBySeason(String season) {
    return _cropDatabase.entries
        .where((e) {
          final requiredSeason = e.value.requiredSeason;
          return requiredSeason == null || requiredSeason == 'any' || requiredSeason == season;
        })
        .map((e) => e.key)
        .toList();
  }

  static CropEntity? getCropData(String cropId) {
    return _cropDatabase[cropId];
  }

  static bool get isInitialized => _isInitialized;
}
