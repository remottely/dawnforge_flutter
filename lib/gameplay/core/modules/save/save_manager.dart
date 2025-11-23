import 'dart:async';
import 'dart:developer' as developer;

import 'save_data_model.dart';
import 'save_repository.dart';

/// Singleton manager that orchestrates all save/load operations.
///
/// Provides a simple API for saving and loading game data using
/// [SaveRepository] internally. Includes auto-save functionality with
/// debouncing to prevent excessive saves.
///
/// Example usage:
/// ```dart
/// // Save game
/// final saveData = SaveData(
///   version: SaveData.kCurrentVersion,
///   timestamp: DateTime.now(),
///   playerData: playerModel.toJson(),
///   worldData: worldStateManager.toJson(),
///   inventoryData: inventoryManager.toJson(),
/// );
/// final success = await SaveManager.instance.save(saveData);
///
/// // Load game
/// final loadedData = await SaveManager.instance.load();
/// if (loadedData != null && loadedData.isValid()) {
///   // Restore game state
/// }
///
/// // Auto-save (non-blocking, debounced)
/// SaveManager.instance.autoSave();
/// ```
final class SaveManager {
  SaveManager._();

  /// Singleton instance.
  static final instance = SaveManager._();

  /// Key for main save data in persistent storage.
  static const String _kSaveKey = 'main_save';

  /// Key for save metadata in persistent storage.
  static const String _kMetadataKey = 'save_metadata';

  /// Minimum time between auto-saves (debouncing).
  static const Duration _kAutoSaveDebounceInterval = Duration(seconds: 30);

  /// Repository for persistent storage operations.
  late final SaveRepository _repository = SaveRepository();

  /// Timer for auto-save debouncing.
  Timer? _autoSaveTimer;

  /// Timestamp of last save operation.
  DateTime? _lastSaveTime;

  /// Cached save data for auto-save.
  SaveData? _cachedSaveData;

  /// Saves game data to persistent storage.
  ///
  /// Returns `true` if save was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await SaveManager.instance.save(saveData);
  /// if (success) {
  ///   print('Game saved!');
  /// }
  /// ```
  Future<bool> save(SaveData data) async {
    try {
      // Validate data before saving
      if (!data.isValid()) {
        developer.log(
          '[SaveManager] Cannot save invalid data',
          name: 'SaveManager',
          level: 900, // WARNING
        );
        return false;
      }

      // Save main data
      final success = await _repository.save(_kSaveKey, data.toJson());

      if (success) {
        _lastSaveTime = DateTime.now();
        _cachedSaveData = data;

        // Update metadata
        await _updateMetadata();

        developer.log(
          '[SaveManager] Save successful at ${_lastSaveTime!.toIso8601String()}',
          name: 'SaveManager',
        );
      } else {
        developer.log(
          '[SaveManager] Save failed',
          name: 'SaveManager',
          level: 1000, // ERROR
        );
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveManager] Error during save',
        name: 'SaveManager',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return false;
    }
  }

  /// Loads game data from persistent storage.
  ///
  /// Returns [SaveData] if load was successful, `null` otherwise.
  /// Also returns `null` if the loaded data is invalid or corrupted.
  ///
  /// Example:
  /// ```dart
  /// final data = await SaveManager.instance.load();
  /// if (data != null) {
  ///   // Restore game state
  /// } else {
  ///   // No save found or corrupted
  /// }
  /// ```
  Future<SaveData?> load() async {
    try {
      final json = await _repository.load(_kSaveKey);

      if (json == null) {
        developer.log(
          '[SaveManager] No save data found',
          name: 'SaveManager',
          level: 500, // FINE
        );
        return null;
      }

      final saveData = SaveData.fromJson(json);

      // Validate loaded data
      if (!saveData.isValid()) {
        developer.log(
          '[SaveManager] Loaded save data is corrupted',
          name: 'SaveManager',
          level: 900, // WARNING
        );

        // Attempt recovery
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
        level: 1000, // ERROR
      );

      return null;
    }
  }

  /// Checks if a save file exists.
  ///
  /// Returns `true` if save data exists, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (await SaveManager.instance.hasSave()) {
  ///   // Show "Continue" button
  /// }
  /// ```
  Future<bool> hasSave() async {
    try {
      final data = await _repository.load(_kSaveKey);
      return data != null;
    } catch (e) {
      developer.log(
        '[SaveManager] Error checking for save',
        name: 'SaveManager',
        error: e,
        level: 900, // WARNING
      );
      return false;
    }
  }

  /// Deletes all save data.
  ///
  /// Returns `true` if deletion was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// await SaveManager.instance.deleteSave();
  /// ```
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
        level: 1000, // ERROR
      );
      return false;
    }
  }

  /// Auto-saves game data with debouncing.
  ///
  /// This method is non-blocking and debounced to prevent excessive saves.
  /// If called multiple times within [_kAutoSaveDebounceInterval], only
  /// the last call will trigger a save.
  ///
  /// Requires [_cachedSaveData] to be set (call [save] at least once first).
  ///
  /// Example:
  /// ```dart
  /// // Call periodically or after important actions
  /// SaveManager.instance.autoSave();
  /// ```
  void autoSave() {
    // Cancel previous timer
    _autoSaveTimer?.cancel();

    // Check if we have data to save
    if (_cachedSaveData == null) {
      developer.log(
        '[SaveManager] Auto-save skipped: no cached data',
        name: 'SaveManager',
        level: 500, // FINE
      );
      return;
    }

    // Check debounce interval
    if (_lastSaveTime != null) {
      final timeSinceLastSave = DateTime.now().difference(_lastSaveTime!);
      if (timeSinceLastSave < _kAutoSaveDebounceInterval) {
        developer.log(
          '[SaveManager] Auto-save debounced (${timeSinceLastSave.inSeconds}s since last save)',
          name: 'SaveManager',
          level: 500, // FINE
        );
        return;
      }
    }

    // Schedule auto-save
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      developer.log('[SaveManager] Auto-save triggered', name: 'SaveManager');

      // Update timestamp
      final updatedData = _cachedSaveData!.copyWith(timestamp: DateTime.now());

      await save(updatedData);
    });
  }

  /// Gets save metadata (last save time, play time, save count).
  ///
  /// Returns metadata map or `null` if no metadata exists.
  Future<Map<String, dynamic>?> getSaveMetadata() async {
    try {
      return await _repository.load(_kMetadataKey);
    } catch (e) {
      developer.log(
        '[SaveManager] Error loading metadata',
        name: 'SaveManager',
        error: e,
        level: 900, // WARNING
      );
      return null;
    }
  }

  /// Updates save metadata with current information.
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
      // Non-critical, just log
      developer.log(
        '[SaveManager] Failed to update metadata',
        name: 'SaveManager',
        error: e,
        level: 500, // FINE
      );
    }
  }

  /// Attempts to recover a corrupted save by creating a backup.
  Future<void> _recoverCorruptedSave(Map<String, dynamic> corruptedData) async {
    try {
      // Save corrupted data as backup
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
        level: 900, // WARNING
      );
    }
  }

  /// Disposes resources (cancel timers).
  ///
  /// Should be called when the game is closing.
  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
}
