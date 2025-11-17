import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import 'save_repository.dart';

/// Factory function for platform-specific instantiation
SaveRepository createRepository() => SaveRepositoryNative();

/// Native platform implementation of [SaveRepository] using SharedPreferences.
///
/// Uses [SharedPreferences] for persistent storage on desktop and mobile platforms.
/// Data is serialized to JSON strings before storage.
///
/// Only manages keys with the 'darkness_dungeon_' prefix to avoid
/// interfering with other application data.
final class SaveRepositoryNative implements SaveRepository {
  static const String _keyPrefix = 'darkness_dungeon_';

  SharedPreferences? _prefs;

  /// Lazily initializes SharedPreferences instance.
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

      final success = await prefs.setString(prefixedKey, jsonString);

      if (success) {
        developer.log(
          '[SaveRepositoryNative] Saved data for key: $prefixedKey',
          name: 'SaveRepository',
        );
      } else {
        developer.log(
          '[SaveRepositoryNative] Failed to save data for key: $prefixedKey',
          name: 'SaveRepository',
          level: 900, // WARNING
        );
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryNative] Error saving data for key: $key',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    try {
      final prefs = await _sharedPreferences;
      final prefixedKey = '$_keyPrefix$key';
      final jsonString = prefs.getString(prefixedKey);

      if (jsonString == null) {
        developer.log(
          '[SaveRepositoryNative] No data found for key: $prefixedKey',
          name: 'SaveRepository',
          level: 500, // FINE
        );
        return null;
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      developer.log(
        '[SaveRepositoryNative] Loaded data for key: $prefixedKey',
        name: 'SaveRepository',
      );

      return data;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryNative] Error loading data for key: $key',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
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
        level: 1000, // ERROR
      );
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      final prefs = await _sharedPreferences;
      final allKeys = prefs.getKeys();

      // Filter only game-related keys
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
            level: 900, // WARNING
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
        level: 1000, // ERROR
      );
      return false;
    }
  }
}
