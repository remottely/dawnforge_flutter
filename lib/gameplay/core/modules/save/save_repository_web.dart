import 'dart:convert';
import 'dart:developer' as developer;

import 'package:web/web.dart' as web;

import 'save_repository.dart';

/// Web platform implementation of [SaveRepository] using localStorage.
///
/// Uses browser's `localStorage` API for persistent storage on web platform.
/// Data is serialized to JSON strings before storage.
///
/// Monitors storage usage and logs warnings when approaching the ~5MB limit.
final class SaveRepositoryWeb implements SaveRepository {
  static const String _keyPrefix = 'darkness_dungeon_';
  static const int _warningThresholdBytes =
      4 * 1024 * 1024; // 4MB (warn before 5MB limit)

  /// Gets the localStorage instance.
  web.Storage get _localStorage => web.window.localStorage;

  /// Calculates approximate total size of game data in localStorage.
  int _calculateStorageSize() {
    var totalSize = 0;
    final length = _localStorage.length;

    for (var i = 0; i < length; i++) {
      final key = _localStorage.key(i);
      if (key != null && key.startsWith(_keyPrefix)) {
        final value = _localStorage.getItem(key);
        if (value != null) {
          // Approximate size: key + value in UTF-16 (2 bytes per char)
          totalSize += ((key.length + value.length) * 2).toInt();
        }
      }
    }
    return totalSize;
  }

  /// Logs a warning if storage size is approaching the limit.
  void _checkStorageSize() {
    final currentSize = _calculateStorageSize();
    if (currentSize > _warningThresholdBytes) {
      final sizeMB = (currentSize / (1024 * 1024)).toStringAsFixed(2);
      developer.log(
        '[SaveRepositoryWeb] WARNING: Storage usage is $sizeMB MB (approaching 5MB limit)',
        name: 'SaveRepository',
        level: 900, // WARNING
      );
    }
  }

  @override
  Future<bool> save(String key, Map<String, dynamic> data) async {
    try {
      final prefixedKey = '$_keyPrefix$key';
      final jsonString = jsonEncode(data);

      _localStorage.setItem(prefixedKey, jsonString);

      developer.log(
        '[SaveRepositoryWeb] Saved data for key: $prefixedKey',
        name: 'SaveRepository',
      );

      // Check storage size after save
      _checkStorageSize();

      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryWeb] Error saving data for key: $key',
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
      final prefixedKey = '$_keyPrefix$key';
      final jsonString = _localStorage.getItem(prefixedKey);

      if (jsonString == null) {
        developer.log(
          '[SaveRepositoryWeb] No data found for key: $prefixedKey',
          name: 'SaveRepository',
          level: 500, // FINE
        );
        return null;
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      developer.log(
        '[SaveRepositoryWeb] Loaded data for key: $prefixedKey',
        name: 'SaveRepository',
      );

      return data;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryWeb] Error loading data for key: $key',
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
      final prefixedKey = '$_keyPrefix$key';
      _localStorage.removeItem(prefixedKey);

      developer.log(
        '[SaveRepositoryWeb] Deleted data for key: $prefixedKey',
        name: 'SaveRepository',
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryWeb] Error deleting data for key: $key',
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
      // Collect all game keys first (to avoid concurrent modification)
      final gameKeys = <String>[];
      final length = _localStorage.length;

      for (var i = 0; i < length; i++) {
        final key = _localStorage.key(i);
        if (key != null && key.startsWith(_keyPrefix)) {
          gameKeys.add(key);
        }
      }

      // Remove all game keys
      for (final key in gameKeys) {
        _localStorage.removeItem(key);
      }

      developer.log(
        '[SaveRepositoryWeb] Cleared ${gameKeys.length} game keys',
        name: 'SaveRepository',
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryWeb] Error clearing game data',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return false;
    }
  }
}
