import 'dart:convert';
import 'dart:developer' as developer;
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
        developer.log(
          '[SaveRepositoryNative] Compressed save data: '
          '${jsonString.length} bytes → ${dataToSave.length} bytes '
          '(${((1 - dataToSave.length / jsonString.length) * 100).toStringAsFixed(1)}% reduction)',
          name: 'SaveRepository',
        );
      } else {
        dataToSave = jsonString;
        await prefs.remove('${prefixedKey}_compressed');
      }

      final success = await prefs.setString(prefixedKey, dataToSave);

      if (success) {
        developer.log(
          '[SaveRepositoryNative] Saved data for key: $prefixedKey '
          '(${dataToSave.length} bytes${shouldCompress ? ', compressed' : ''})',
          name: 'SaveRepository',
        );
      } else {
        developer.log(
          '[SaveRepositoryNative] Failed to save data for key: $prefixedKey',
          name: 'SaveRepository',
          level: 900,
        );
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryNative] Error saving data for key: $key',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
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
        developer.log(
          '[SaveRepositoryNative] No data found for key: $prefixedKey',
          name: 'SaveRepository',
          level: 500,
        );
        return null;
      }

      final isCompressed = prefs.getBool('${prefixedKey}_compressed') ?? false;

      String jsonString;
      if (isCompressed) {
        try {
          final compressed = base64.decode(dataString);
          final decompressed = gzip.decode(compressed);
          jsonString = utf8.decode(decompressed);
          developer.log(
            '[SaveRepositoryNative] Decompressed data: '
            '${dataString.length} bytes → ${jsonString.length} bytes',
            name: 'SaveRepository',
          );
        } catch (e) {
          developer.log(
            '[SaveRepositoryNative] Decompression failed, trying raw data',
            name: 'SaveRepository',
            level: 900,
          );
          jsonString = dataString;
        }
      } else {
        jsonString = dataString;
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      developer.log(
        '[SaveRepositoryNative] Loaded data for key: $prefixedKey '
        '(${jsonString.length} bytes${isCompressed ? ', decompressed' : ''})',
        name: 'SaveRepository',
      );

      return data;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryNative] Error loading data for key: $key',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
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
        developer.log(
          '[SaveRepositoryNative] Deleted data for key: $prefixedKey',
          name: 'SaveRepository',
        );
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryNative] Error deleting data for key: $key',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
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
          developer.log(
            '[SaveRepositoryNative] Failed to remove key: $key',
            name: 'SaveRepository',
            level: 900,
          );
        } else {
          removedCount++;
        }
      }

      developer.log(
        '[SaveRepositoryNative] Cleared $removedCount game keys',
        name: 'SaveRepository',
      );

      return allSuccess;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryNative] Error clearing game data',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
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
      developer.log(
        '[SaveRepositoryNative] Error checking existence for key: $key',
        name: 'SaveRepository',
        error: e,
        level: 900,
      );
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

      developer.log(
        '[SaveRepositoryNative] Found ${gameKeys.length} game save keys',
        name: 'SaveRepository',
      );

      return gameKeys;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryNative] Error listing keys',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return [];
    }
  }
}
