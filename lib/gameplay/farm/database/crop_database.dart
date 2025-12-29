import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import '../../world/entities/objects/farm/crop_stage_type.dart';
import '../models/crop_model.dart';

final class CropDatabase {
  CropDatabase._();

  static final Map<String, Map<String, dynamic>> _cropDatabase = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/database/crops_database.json',
      );
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      for (var entry in jsonData.entries) {
        _cropDatabase[entry.key] = entry.value as Map<String, dynamic>;
      }

      _isInitialized = true;
      developer.log('[CropDatabase] Loaded ${_cropDatabase.length} crops');
    } catch (e) {
      developer.log('[CropDatabase] ERROR loading database: $e');
      rethrow;
    }
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
  }

  static List<String> getAllCropIds() => _cropDatabase.keys.toList();

  static List<String> getCropsBySeason(String season) {
    return _cropDatabase.entries
        .where(
          (e) =>
              e.value['requiredSeason'] == season ||
              e.value['requiredSeason'] == 'any',
        )
        .map((e) => e.key)
        .toList();
  }

  static Map<String, dynamic>? getCropData(String cropId) {
    return _cropDatabase[cropId];
  }

  static bool get isInitialized => _isInitialized;
}
