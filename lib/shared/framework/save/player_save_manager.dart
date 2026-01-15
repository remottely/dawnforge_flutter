// lib/shared/framework/save/player_save_manager.dart (SIMPLIFICADO)
import 'dart:convert';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSaveManager {
  static const String _kPlayerDataKey = 'player_data_v3';
  
  /// Salva o estado do player
  static Future<bool> savePlayer(CharacterData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(data.toJson());
      
      final success = await prefs.setString(_kPlayerDataKey, json);
      
      if (success) {
        GameLogger.info('[SaveManager] ✓ Player saved');
      }
      
      return success;
    } catch (e, stack) {
      GameLogger.error('[SaveManager] ✗ Error saving: $e\n$stack');
      return false;
    }
  }
  
  /// Carrega o estado do player
  static Future<CharacterData?> loadPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kPlayerDataKey);
      
      if (jsonString == null) {
        GameLogger.info('[SaveManager] No save found');
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = CharacterData.fromJson(json);
      
      GameLogger.info('[SaveManager] ✓ Player loaded');
      
      return data;
    } catch (e, stack) {
      GameLogger.error('[SaveManager] ✗ Error loading: $e\n$stack');
      return null;
    }
  }
  
  /// Limpa o save
  static Future<bool> clearSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_kPlayerDataKey);
      
      if (success) {
        GameLogger.info('[SaveManager] ✓ Save cleared');
      }
      
      return success;
    } catch (e) {
      GameLogger.error('[SaveManager] ✗ Error clearing save: $e');
      return false;
    }
  }
  
  /// Verifica se existe um save
  static Future<bool> hasSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_kPlayerDataKey);
    } catch (e) {
      return false;
    }
  }
}
