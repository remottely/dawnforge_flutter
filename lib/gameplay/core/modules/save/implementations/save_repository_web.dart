import 'dart:convert';
import 'dart:developer' as developer;

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
      developer.log(
        '[SaveRepositoryWeb] WARNING: Storage usage is $sizeMB MB (approaching 5MB limit)',
        name: 'SaveRepository',
        level: 900,
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

      _checkStorageSize();

      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryWeb] Error saving data for key: $key',
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
      final prefixedKey = '$_keyPrefix$key';
      final jsonString = _localStorage.getItem(prefixedKey);

      if (jsonString == null) {
        developer.log(
          '[SaveRepositoryWeb] No data found for key: $prefixedKey',
          name: 'SaveRepository',
          level: 500,
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
        level: 1000,
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
        level: 1000,
      );
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
        level: 1000,
      );
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
      developer.log(
        '[SaveRepositoryWeb] Error checking existence for key: $key',
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
      final gameKeys = <String>[];
      final length = _localStorage.length;

      for (var i = 0; i < length; i++) {
        final key = _localStorage.key(i);
        if (key != null && key.startsWith(_keyPrefix)) {
          gameKeys.add(key.substring(_keyPrefix.length));
        }
      }

      developer.log(
        '[SaveRepositoryWeb] Found ${gameKeys.length} game save keys',
        name: 'SaveRepository',
      );

      return gameKeys;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveRepositoryWeb] Error listing keys',
        name: 'SaveRepository',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return [];
    }
  }
}
