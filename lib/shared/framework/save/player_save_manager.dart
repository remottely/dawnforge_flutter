// lib/shared/framework/save/player_save_manager.dart (ATUALIZADO)
import 'dart:convert';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/shared/framework/save/migration_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSaveManager {
  static const String _kPlayerDataKey = 'player_data_v3'; // ✅ Versão nova
  
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
  
  /// Carrega o estado do player (com migração automática)
  static Future<CharacterData?> loadPlayer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kPlayerDataKey);
      
      if (jsonString == null) {
        // ✅ Tenta carregar save antigo
        return _tryLoadLegacySave(prefs);
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // ✅ Valida e migra se necessário
      final migratedJson = SaveMigrationHelper.migrateOldSave(json);
      
      if (!SaveMigrationHelper.validateSave(migratedJson)) {
        GameLogger.error('[SaveManager] ✗ Invalid save data');
        return null;
      }
      
      final data = CharacterData.fromJson(migratedJson);
      
      GameLogger.info('[SaveManager] ✓ Player loaded');
      
      return data;
    } catch (e, stack) {
      GameLogger.error('[SaveManager] ✗ Error loading: $e\n$stack');
      return null;
    }
  }
  
  /// Tenta carregar save do formato antigo
  static Future<CharacterData?> _tryLoadLegacySave(SharedPreferences prefs) async {
    // Tenta chaves antigas
    final oldKeys = ['player_data_v2', 'player_data_v1', 'player_data'];
    
    for (final key in oldKeys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        GameLogger.info('[SaveManager] Found legacy save with key: $key');
        
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final migratedJson = SaveMigrationHelper.migrateOldSave(json);
          final data = CharacterData.fromJson(migratedJson);
          
          // Salva no formato novo
          await savePlayer(data);
          
          // Remove save antigo
          await prefs.remove(key);
          
          GameLogger.info('[SaveManager] ✓ Legacy save migrated');
          return data;
        } catch (e) {
          GameLogger.error('[SaveManager] ✗ Failed to migrate legacy save: $e');
        }
      }
    }
    
    GameLogger.info('[SaveManager] No save found');
    return null;
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
      return prefs.containsKey(_kPlayerDataKey) ||
             prefs.containsKey('player_data_v2') || // Legacy
             prefs.containsKey('player_data_v1') || // Legacy
             prefs.containsKey('player_data');       // Legacy
    } catch (e) {
      return false;
    }
  }
}
