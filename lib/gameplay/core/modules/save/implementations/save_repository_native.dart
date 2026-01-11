import 'dart:convert';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'dart:io' show gzip;

import 'package:shared_preferences/shared_preferences.dart';

import '../save_repository.dart';

SaveRepository createRepository() => SaveRepositoryNative();

final class SaveRepositoryNative implements SaveRepository {
  static const String _keyPrefix = 'darkness_dungeon_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sharedPreferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<bool> save(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await _sharedPreferences;
      final prefixedKey = '$_keyPrefix$key';
      final jsonString = jsonEncode(data);

      final shouldCompress = jsonString.length > 100 * 1024;
      String dataToSave;

      if (shouldCompress) {
        final compressed = gzip.encode(utf8.encode(jsonString));
        dataToSave = base64.encode(compressed);
        await prefs.setBool('${prefixedKey}_compressed', true);
        GameLogger.info('[SaveRepositoryNative] Compressed save data: '
          '${jsonString.length} bytes → ${dataToSave.length} bytes '
          '(${((1 - dataToSave.length / jsonString.length) * 100).toStringAsFixed(1)}% reduction)');
      } else {
        dataToSave = jsonString;
        await prefs.remove('${prefixedKey}_compressed');
      }

      final success = await prefs.setString(prefixedKey, dataToSave);

      if (success) {
        GameLogger.info('[SaveRepositoryNative] Saved data for key: $prefixedKey '
          '(${dataToSave.length} bytes${shouldCompress ? ', compressed' : ''})');
      } else {
        GameLogger.warning('[SaveRepositoryNative] Failed to save data for key: $prefixedKey');
      }

      return success;
    } catch (e) {
      GameLogger.error('[SaveRepositoryNative] Error saving data for key: $key');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    try {
      final prefs = await _sharedPreferences;
      final prefixedKey = '$_keyPrefix$key';
      final dataString = prefs.getString(prefixedKey);

      if (dataString == null) {
        GameLogger.warning('[SaveRepositoryNative] No data found for key: $prefixedKey');
        return null;
      }

      final isCompressed = prefs.getBool('${prefixedKey}_compressed') ?? false;

      String jsonString;
      if (isCompressed) {
        try {
          final compressed = base64.decode(dataString);
          final decompressed = gzip.decode(compressed);
          jsonString = utf8.decode(decompressed);
          GameLogger.info('[SaveRepositoryNative] Decompressed data: '
            '${dataString.length} bytes → ${jsonString.length} bytes');
        } catch (e) {
          GameLogger.warning('[SaveRepositoryNative] Decompression failed, trying raw data');
          jsonString = dataString;
        }
      } else {
        jsonString = dataString;
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      GameLogger.info('[SaveRepositoryNative] Loaded data for key: $prefixedKey '
        '(${jsonString.length} bytes${isCompressed ? ', decompressed' : ''})');

      return data;
    } catch (e) {
      GameLogger.error('[SaveRepositoryNative] Error loading data for key: $key');
      return null;
    }
  }

  @override
  Future<bool> delete(String key) async {
    try {
      final prefs = await _sharedPreferences;
      final prefixedKey = '$_keyPrefix$key';

      final success = await prefs.remove(prefixedKey);

      if (success) {
        GameLogger.info('[SaveRepositoryNative] Deleted data for key: $prefixedKey');
      }

      return success;
    } catch (e) {
      GameLogger.error('[SaveRepositoryNative] Error deleting data for key: $key');
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      final prefs = await _sharedPreferences;
      final allKeys = prefs.getKeys();

      final gameKeys = allKeys.where((key) => key.startsWith(_keyPrefix));

      var allSuccess = true;
      var removedCount = 0;

      for (final key in gameKeys) {
        final success = await prefs.remove(key);
        if (!success) {
          allSuccess = false;
          GameLogger.warning('[SaveRepositoryNative] Failed to remove key: $key');
        } else {
          removedCount++;
        }
      }

      GameLogger.info('[SaveRepositoryNative] Cleared $removedCount game keys');

      return allSuccess;
    } catch (e) {
      GameLogger.error('[SaveRepositoryNative] Error clearing game data');
      return false;
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      final prefs = await _sharedPreferences;
      final prefixedKey = '$_keyPrefix$key';
      return prefs.containsKey(prefixedKey);
    } catch (e) {
      GameLogger.warning('[SaveRepositoryNative] Error checking existence for key: $key');
      return false;
    }
  }

  @override
  Future<List<String>> listKeys() async {
    try {
      final prefs = await _sharedPreferences;
      final allKeys = prefs.getKeys();

      final gameKeys = allKeys
          .where((key) => key.startsWith(_keyPrefix))
          .map((key) => key.substring(_keyPrefix.length))
          .toList();

      GameLogger.info('[SaveRepositoryNative] Found ${gameKeys.length} game save keys');

      return gameKeys;
    } catch (e) {
      GameLogger.error('[SaveRepositoryNative] Error listing keys');
      return [];
    }
  }
}
