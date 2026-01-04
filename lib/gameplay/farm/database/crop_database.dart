import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/database/crop_database.dart';

import '../../world/entities/objects/farm/crop_stage_type.dart';
import '../models/crop_model.dart';

final class CropDatabase {
  CropDatabase._();

  static final Map<String, CropData> _cropDatabase = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _cropDatabase
      ..clear()
      ..addAll(CropDatabaseDef.crops);

    _isInitialized = true;
    developer.log('[CropDatabase] Loaded ${_cropDatabase.length} crops');
  }

  static CropModel? createCrop(String cropId) {
    if (!_isInitialized) {
      developer.log('[CropDatabase] ERROR: Not initialized!');
      return null;
    }

    final cropData = _cropDatabase[cropId];
    if (cropData == null) {
      developer.log('[CropDatabase] Crop not found: $cropId');
      return null;
    }

    return CropModel(
      cropId: cropId,
      name: cropData.name,
      description: cropData.description,
      stage: CropStageType.planted,
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
      ySortingFromStage: cropData.ySortingFromStage ?? CropStageType.planted,
    );
  }

  static List<String> getAllCropIds() => _cropDatabase.keys.toList();

  static List<String> getCropsBySeason(String season) {
    return _cropDatabase.entries
        .where((e) {
          final requiredSeason = e.value.requiredSeason;
          return requiredSeason == 'any' || requiredSeason == season;
        })
        .map((e) => e.key)
        .toList();
  }

  static CropData? getCropData(String cropId) {
    return _cropDatabase[cropId];
  }

  static bool get isInitialized => _isInitialized;
}
