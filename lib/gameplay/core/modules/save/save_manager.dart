import 'dart:async';
import 'dart:developer' as developer;

import 'save_data_model.dart';
import 'save_repository.dart';

final class SaveManager {
  SaveManager._();

  static final instance = SaveManager._();

  static const String _kSaveKey = 'main_save';

  static const String _kMetadataKey = 'save_metadata';

  static const Duration _kAutoSaveDebounceInterval = Duration(seconds: 30);

  late final SaveRepository _repository = SaveRepository();

  Timer? _autoSaveTimer;

  DateTime? _lastSaveTime;

  SaveData? _cachedSaveData;

  Future<bool> save(SaveData data) async {
    try {
      if (!data.isValid()) {
        developer.log(
          '[SaveManager] Cannot save invalid data | playerData=${data.playerData}',
          name: 'SaveManager',
          level: 900,
        );
        return false;
      }

      final success = await _repository.save(_kSaveKey, data.toJson());

      if (success) {
        _lastSaveTime = DateTime.now();
        _cachedSaveData = data;

        await _updateMetadata();

        developer.log(
          '[SaveManager] Save successful at ${_lastSaveTime!.toIso8601String()}',
          name: 'SaveManager',
        );
      } else {
        developer.log(
          '[SaveManager] Save failed',
          name: 'SaveManager',
          level: 1000,
        );
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveManager] Error during save',
        name: 'SaveManager',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  Future<SaveData?> load() async {
    try {
      final json = await _repository.load(_kSaveKey);

      if (json == null) {
        developer.log(
          '[SaveManager] No save data found',
          name: 'SaveManager',
          level: 500,
        );
        return null;
      }

      final saveData = SaveData.fromJson(json);

      if (!saveData.isValid()) {
        developer.log(
          '[SaveManager] Loaded save data is corrupted',
          name: 'SaveManager',
          level: 900,
        );

        await _recoverCorruptedSave(json);

        return null;
      }

      _cachedSaveData = saveData;

      developer.log(
        '[SaveManager] Load successful (version ${saveData.version})',
        name: 'SaveManager',
      );

      return saveData;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveManager] Error during load',
        name: 'SaveManager',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );

      return null;
    }
  }

  Future<bool> hasSave() async {
    try {
      final data = await _repository.load(_kSaveKey);
      return data != null;
    } catch (e) {
      developer.log(
        '[SaveManager] Error checking for save',
        name: 'SaveManager',
        error: e,
        level: 900,
      );
      return false;
    }
  }

  Future<bool> deleteSave() async {
    try {
      final mainDeleted = await _repository.delete(_kSaveKey);
      final metaDeleted = await _repository.delete(_kMetadataKey);

      _cachedSaveData = null;
      _lastSaveTime = null;

      developer.log('[SaveManager] Save deleted', name: 'SaveManager');

      return mainDeleted && metaDeleted;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveManager] Error deleting save',
        name: 'SaveManager',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  void autoSave() {
    _autoSaveTimer?.cancel();

    if (_cachedSaveData == null) {
      developer.log(
        '[SaveManager] Auto-save skipped: no cached data',
        name: 'SaveManager',
        level: 500,
      );
      return;
    }

    if (_lastSaveTime != null) {
      final timeSinceLastSave = DateTime.now().difference(_lastSaveTime!);
      if (timeSinceLastSave < _kAutoSaveDebounceInterval) {
        developer.log(
          '[SaveManager] Auto-save debounced (${timeSinceLastSave.inSeconds}s since last save)',
          name: 'SaveManager',
          level: 500,
        );
        return;
      }
    }

    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      developer.log('[SaveManager] Auto-save triggered', name: 'SaveManager');

      final updatedData = _cachedSaveData!.copyWith(timestamp: DateTime.now());

      await save(updatedData);
    });
  }

  Future<Map<String, dynamic>?> getSaveMetadata() async {
    try {
      return await _repository.load(_kMetadataKey);
    } catch (e) {
      developer.log(
        '[SaveManager] Error loading metadata',
        name: 'SaveManager',
        error: e,
        level: 900,
      );
      return null;
    }
  }

  Future<void> _updateMetadata() async {
    try {
      final metadata = await getSaveMetadata() ?? {};

      final saveCount = (metadata['saveCount'] as int? ?? 0) + 1;

      final updatedMetadata = {
        'lastSaveTime': DateTime.now().toIso8601String(),
        'saveCount': saveCount,
        'version': SaveData.kCurrentVersion,
      };

      await _repository.save(_kMetadataKey, updatedMetadata);
    } catch (e) {
      developer.log(
        '[SaveManager] Failed to update metadata',
        name: 'SaveManager',
        error: e,
        level: 500,
      );
    }
  }

  Future<void> _recoverCorruptedSave(Map<String, dynamic> corruptedData) async {
    try {
      final backupKey =
          'backup_corrupted_${DateTime.now().millisecondsSinceEpoch}';
      await _repository.save(backupKey, corruptedData);

      developer.log(
        '[SaveManager] Corrupted save backed up to: $backupKey',
        name: 'SaveManager',
      );
    } catch (e) {
      developer.log(
        '[SaveManager] Failed to backup corrupted save',
        name: 'SaveManager',
        error: e,
        level: 900,
      );
    }
  }

  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
}
