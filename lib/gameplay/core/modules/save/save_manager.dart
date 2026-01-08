import 'dart:async';
import 'package:darkness_dungeon/core/utils/logger/game_logger.dart';

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
        GameLogger.warning('[SaveManager] Cannot save invalid data | playerData=${data.playerData}');
        return false;
      }

      final success = await _repository.save(_kSaveKey, data.toJson());

      if (success) {
        _lastSaveTime = DateTime.now();
        _cachedSaveData = data;

        await _updateMetadata();

        GameLogger.info('[SaveManager] Save successful at ${_lastSaveTime!.toIso8601String()}');
      } else {
        GameLogger.error('[SaveManager] Save failed');
      }

      return success;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveManager] Error during save');
      return false;
    }
  }

  Future<SaveData?> load() async {
    try {
      final json = await _repository.load(_kSaveKey);

      if (json == null) {
        GameLogger.warning('[SaveManager] No save data found');
        return null;
      }

      final saveData = SaveData.fromJson(json);

      if (!saveData.isValid()) {
        GameLogger.warning('[SaveManager] Loaded save data is corrupted');

        await _recoverCorruptedSave(json);

        return null;
      }

      _cachedSaveData = saveData;

      GameLogger.info('[SaveManager] Load successful (version ${saveData.version})');

      return saveData;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveManager] Error during load');

      return null;
    }
  }

  Future<bool> hasSave() async {
    try {
      final data = await _repository.load(_kSaveKey);
      return data != null;
    } catch (e) {
      GameLogger.warning('[SaveManager] Error checking for save');
      return false;
    }
  }

  Future<bool> deleteSave() async {
    try {
      final mainDeleted = await _repository.delete(_kSaveKey);
      final metaDeleted = await _repository.delete(_kMetadataKey);

      _cachedSaveData = null;
      _lastSaveTime = null;

      GameLogger.info('[SaveManager] Save deleted');

      return mainDeleted && metaDeleted;
    } catch (e, stackTrace) {
      GameLogger.error('[SaveManager] Error deleting save');
      return false;
    }
  }

  void autoSave() {
    _autoSaveTimer?.cancel();

    if (_cachedSaveData == null) {
      GameLogger.info('[SaveManager] Auto-save skipped: no cached data');
      return;
    }

    if (_lastSaveTime != null) {
      final timeSinceLastSave = DateTime.now().difference(_lastSaveTime!);
      if (timeSinceLastSave < _kAutoSaveDebounceInterval) {
        GameLogger.info('[SaveManager] Auto-save debounced (${timeSinceLastSave.inSeconds}s since last save)');
        return;
      }
    }

    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      GameLogger.info('[SaveManager] Auto-save triggered');

      final updatedData = _cachedSaveData!.copyWith(timestamp: DateTime.now());

      await save(updatedData);
    });
  }

  Future<Map<String, dynamic>?> getSaveMetadata() async {
    try {
      return await _repository.load(_kMetadataKey);
    } catch (e) {
      GameLogger.warning('[SaveManager] Error loading metadata');
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
      GameLogger.warning('[SaveManager] Failed to update metadata');
    }
  }

  Future<void> _recoverCorruptedSave(Map<String, dynamic> corruptedData) async {
    try {
      final backupKey =
          'backup_corrupted_${DateTime.now().millisecondsSinceEpoch}';
      await _repository.save(backupKey, corruptedData);

      GameLogger.info('[SaveManager] Corrupted save backed up to: $backupKey');
    } catch (e) {
      GameLogger.warning('[SaveManager] Failed to backup corrupted save');
    }
  }

  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
}
