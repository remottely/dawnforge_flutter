import 'dart:convert';
import 'package:darkness_dungeon/core/utils/logger/game_logger.dart';

import 'package:web/web.dart' as web;

import '../save_repository.dart';

SaveRepository createRepository() => SaveRepositoryWeb();

final class SaveRepositoryWeb implements SaveRepository {
  static const String _keyPrefix = 'darkness_dungeon_';
  static const int _warningThresholdBytes = 4 * 1024 * 1024;

  web.Storage get _localStorage => web.window.localStorage;

  int _calculateStorageSize() {
    var totalSize = 0;
    final length = _localStorage.length;

    for (var i = 0; i < length; i++) {
      final key = _localStorage.key(i);
      if (key != null && key.startsWith(_keyPrefix)) {
        final value = _localStorage.getItem(key);
        if (value != null) {
          totalSize += ((key.length + value.length) * 2).toInt();
        }
      }
    }
    return totalSize;
  }

  void _checkStorageSize() {
    final currentSize = _calculateStorageSize();
    if (currentSize > _warningThresholdBytes) {
      final sizeMB = (currentSize / (1024 * 1024)).toStringAsFixed(2);
      GameLogger.warning('[SaveRepositoryWeb] WARNING: Storage usage is $sizeMB MB (approaching 5MB limit)');
    }
  }

  @override
  Future<bool> save(String key, Map<String, dynamic> data) async {
    try {
      final prefixedKey = '$_keyPrefix$key';
      final jsonString = jsonEncode(data);

      _localStorage.setItem(prefixedKey, jsonString);

      GameLogger.info('[SaveRepositoryWeb] Saved data for key: $prefixedKey');

      _checkStorageSize();

      return true;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveRepositoryWeb] Error saving data for key: $key');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    try {
      final prefixedKey = '$_keyPrefix$key';
      final jsonString = _localStorage.getItem(prefixedKey);

      if (jsonString == null) {
        GameLogger.warning('[SaveRepositoryWeb] No data found for key: $prefixedKey');
        return null;
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      GameLogger.info('[SaveRepositoryWeb] Loaded data for key: $prefixedKey');

      return data;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveRepositoryWeb] Error loading data for key: $key');
      return null;
    }
  }

  @override
  Future<bool> delete(String key) async {
    try {
      final prefixedKey = '$_keyPrefix$key';
      _localStorage.removeItem(prefixedKey);

      GameLogger.info('[SaveRepositoryWeb] Deleted data for key: $prefixedKey');

      return true;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveRepositoryWeb] Error deleting data for key: $key');
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      final gameKeys = <String>[];
      final length = _localStorage.length;

      for (var i = 0; i < length; i++) {
        final key = _localStorage.key(i);
        if (key != null && key.startsWith(_keyPrefix)) {
          gameKeys.add(key);
        }
      }

      for (final key in gameKeys) {
        _localStorage.removeItem(key);
      }

      GameLogger.info('[SaveRepositoryWeb] Cleared ${gameKeys.length} game keys');

      return true;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveRepositoryWeb] Error clearing game data');
      return false;
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      final prefixedKey = '$_keyPrefix$key';
      final value = _localStorage.getItem(prefixedKey);
      return value != null;
    } catch (e) {
      GameLogger.warning('[SaveRepositoryWeb] Error checking existence for key: $key');
      return false;
    }
  }

  @override
  Future<List<String>> listKeys() async {
    try {
      final gameKeys = <String>[];
      final length = _localStorage.length;

      for (var i = 0; i < length; i++) {
        final key = _localStorage.key(i);
        if (key != null && key.startsWith(_keyPrefix)) {
          gameKeys.add(key.substring(_keyPrefix.length));
        }
      }

      GameLogger.info('[SaveRepositoryWeb] Found ${gameKeys.length} game save keys');

      return gameKeys;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveRepositoryWeb] Error listing keys');
      return [];
    }
  }
}
