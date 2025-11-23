import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'models/crop.dart';
import 'models/crop_stage.dart';

/// Database de crops disponíveis no jogo
final class CropDatabase {
  CropDatabase._();

  static final Map<String, Map<String, dynamic>> _cropDatabase = {};
  static bool _isInitialized = false;

  /// Carregar database do arquivo JSON
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/crops/crops_database.json',
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

  /// Criar crop por ID (sempre começa como semente)
  static Crop? createCrop(String cropId) {
    if (!_isInitialized) {
      developer.log('[CropDatabase] ERROR: Not initialized!');
      return null;
    }

    final cropData = _cropDatabase[cropId];
    if (cropData == null) {
      developer.log('[CropDatabase] Crop not found: $cropId');
      return null;
    }

    return Crop(
      cropId: cropId,
      name: cropData['name'] as String,
      description: cropData['description'] as String,
      stage: CropStage.seed, // Sempre começa como semente
      daysPlanted: 0,
      daysToMature: cropData['daysToMature'] as int,
      yieldAmount: cropData['yieldAmount'] as int,
      harvestItemId: cropData['harvestItemId'] as String,
      requiredSeason: cropData['requiredSeason'] as String?,
      iconPath: cropData['iconPath'] as String,
    );
  }

  /// Listar todas as crops
  static List<String> getAllCropIds() => _cropDatabase.keys.toList();

  /// Listar crops por estação
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

  /// Obter dados de uma crop
  static Map<String, dynamic>? getCropData(String cropId) {
    return _cropDatabase[cropId];
  }

  /// Database está inicializado?
  static bool get isInitialized => _isInitialized;
}
