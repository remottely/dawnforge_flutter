import 'dart:async';
import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/save/domain/interfaces/i_saveable.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/farm_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/game_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/inventory_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/player_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/world_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_repository.dart';

/// Result of a save operation.
final class SaveResult {
  final bool success;
  final String? errorMessage;
  final DateTime? timestamp;

  const SaveResult({required this.success, this.errorMessage, this.timestamp});

  const SaveResult.success(DateTime timestamp)
    : success = true,
      errorMessage = null,
      timestamp = timestamp;

  const SaveResult.failure(String error)
    : success = false,
      errorMessage = error,
      timestamp = null;
}

/// Result of a load operation.
final class LoadResult {
  final bool success;
  final GameSaveData? data;
  final String? errorMessage;

  const LoadResult({required this.success, this.data, this.errorMessage});

  const LoadResult.success(GameSaveData data)
    : success = true,
      data = data,
      errorMessage = null;

  const LoadResult.failure(String error)
    : success = false,
      data = null,
      errorMessage = error;
}

/// Clean Architecture use case for save/load operations.
///
/// This service orchestrates all save/load operations following
/// Clean Architecture principles:
/// - **Domain Layer**: Uses typed domain models (GameSaveData, etc.)
/// - **Use Case Layer**: This service (business logic)
/// - **Infrastructure Layer**: SaveRepository (persistence)
///
/// **Benefits:**
/// - Testable (can mock SaveRepository)
/// - Platform-agnostic
/// - Type-safe
/// - Single responsibility
/// - Easy to extend
///
/// **Example:**
/// ```dart
/// final service = SaveService();
///
/// // Save game
/// final saveResult = await service.saveGame(
///   playerManager: playerStateManager,
///   worldManager: worldStateManager,
///   inventoryManager: inventoryManager,
///   farmManager: farmManager,
/// );
///
/// if (saveResult.success) {
///   print('Game saved at ${saveResult.timestamp}');
/// }
///
/// // Load game
/// final loadResult = await service.loadGame();
/// if (loadResult.success) {
///   // Restore managers from loadResult.data
/// }
/// ```
final class SaveService {
  final SaveRepository _repository;
  final String _saveKey;

  /// Auto-save debounce duration.
  static const Duration kAutoSaveDebounce = Duration(seconds: 30);

  Timer? _autoSaveTimer;
  DateTime? _lastSaveTime;

  SaveService({SaveRepository? repository, String saveKey = 'main_save'})
    : _repository = repository ?? SaveRepository(),
      _saveKey = saveKey;

  /// Saves complete game state.
  ///
  /// Collects data from all managers and persists to storage.
  ///
  /// **Parameters:**
  /// - [playerManager]: Manager implementing ISaveable<PlayerSaveData>
  /// - [worldManager]: Manager implementing ISaveable<WorldSaveData>
  /// - [inventoryManager]: Manager implementing ISaveable<InventorySaveData>
  /// - [farmManager]: Manager implementing ISaveable<FarmSaveData>
  /// - [progressData]: Optional progress/achievement data
  ///
  /// **Returns:** SaveResult with success status and timestamp
  Future<SaveResult> saveGame({
    required ISaveable<PlayerSaveData> playerManager,
    required ISaveable<WorldSaveData> worldManager,
    required ISaveable<InventorySaveData> inventoryManager,
    required ISaveable<FarmSaveData> farmManager,
    Map<String, dynamic>? progressData,
  }) async {
    try {
      developer.log('[SaveService] Starting save operation...');

      // 1. Collect data from all managers
      final player = playerManager.toSaveData();
      final world = worldManager.toSaveData();
      final inventory = inventoryManager.toSaveData();
      final farm = farmManager.toSaveData();

      // 2. Create GameSaveData
      final gameSaveData = GameSaveData(
        version: GameSaveData.kCurrentVersion,
        timestamp: DateTime.now(),
        player: player,
        world: world,
        inventory: inventory,
        farm: farm,
        progress: progressData ?? {},
      );

      // 3. Validate before saving
      if (!gameSaveData.isValid()) {
        developer.log(
          '[SaveService] Save data validation failed',
          level: 900, // WARNING
        );
        return const SaveResult.failure('Save data validation failed');
      }

      // 4. Persist to storage
      final success = await _repository.save(_saveKey, gameSaveData.toJson());

      if (success) {
        _lastSaveTime = gameSaveData.timestamp;
        developer.log(
          '[SaveService] ✅ Game saved successfully at ${gameSaveData.timestamp}',
        );
        developer.log('[SaveService] ${gameSaveData.getSummary()}');
        return SaveResult.success(gameSaveData.timestamp);
      } else {
        developer.log('[SaveService] ❌ Save operation failed', level: 1000);
        return const SaveResult.failure('Failed to write save data to storage');
      }
    } catch (e, stackTrace) {
      developer.log(
        '[SaveService] Error during save',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return SaveResult.failure('Save error: $e');
    }
  }

  /// Loads complete game state.
  ///
  /// Reads from storage and returns strongly-typed GameSaveData.
  /// Managers should call their respective fromSaveData methods.
  ///
  /// **Returns:** LoadResult with success status and game data
  ///
  /// **Example:**
  /// ```dart
  /// final result = await service.loadGame();
  /// if (result.success && result.data != null) {
  ///   playerManager.fromSaveData(result.data!.player);
  ///   worldManager.fromSaveData(result.data!.world);
  ///   // ... restore other managers
  /// }
  /// ```
  Future<LoadResult> loadGame() async {
    try {
      developer.log('[SaveService] Starting load operation...');

      // 1. Load from storage
      final json = await _repository.load(_saveKey);

      if (json == null) {
        developer.log('[SaveService] No save file found', level: 500);
        return const LoadResult.failure('No save file found');
      }

      // 2. Deserialize to GameSaveData
      final gameSaveData = GameSaveData.fromJson(json);

      // 3. Validate loaded data
      if (!gameSaveData.isValid()) {
        developer.log(
          '[SaveService] Loaded save data is corrupted',
          level: 900,
        );
        // Attempt to backup corrupted save
        await _backupCorruptedSave(json);
        return const LoadResult.failure('Save data is corrupted');
      }

      developer.log('[SaveService] ✅ Game loaded successfully');
      developer.log('[SaveService] ${gameSaveData.getSummary()}');

      return LoadResult.success(gameSaveData);
    } catch (e, stackTrace) {
      developer.log(
        '[SaveService] Error during load',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return LoadResult.failure('Load error: $e');
    }
  }

  /// Checks if a save file exists.
  Future<bool> hasSave() async {
    try {
      return await _repository.exists(_saveKey);
    } catch (e) {
      developer.log('[SaveService] Error checking save existence', error: e);
      return false;
    }
  }

  /// Deletes the save file.
  Future<bool> deleteSave() async {
    try {
      developer.log('[SaveService] Deleting save file...');
      final success = await _repository.delete(_saveKey);
      if (success) {
        developer.log('[SaveService] ✅ Save file deleted');
        _lastSaveTime = null;
      }
      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[SaveService] Error deleting save',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  /// Auto-saves with debouncing to prevent excessive saves.
  ///
  /// Call this periodically (e.g., after important actions).
  /// Only saves if enough time has passed since last save.
  ///
  /// **Non-blocking**: Uses timer to defer save operation.
  void scheduleAutoSave({
    required ISaveable<PlayerSaveData> playerManager,
    required ISaveable<WorldSaveData> worldManager,
    required ISaveable<InventorySaveData> inventoryManager,
    required ISaveable<FarmSaveData> farmManager,
    Map<String, dynamic>? progressData,
  }) {
    // Cancel previous timer
    _autoSaveTimer?.cancel();

    // Check debounce interval
    if (_lastSaveTime != null) {
      final timeSinceLastSave = DateTime.now().difference(_lastSaveTime!);
      if (timeSinceLastSave < kAutoSaveDebounce) {
        developer.log(
          '[SaveService] Auto-save debounced (${timeSinceLastSave.inSeconds}s since last save)',
          level: 500,
        );
        return;
      }
    }

    // Schedule auto-save
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () async {
      developer.log('[SaveService] Auto-save triggered');
      await saveGame(
        playerManager: playerManager,
        worldManager: worldManager,
        inventoryManager: inventoryManager,
        farmManager: farmManager,
        progressData: progressData,
      );
    });
  }

  /// Gets save file metadata without loading full game state.
  Future<Map<String, dynamic>?> getSaveMetadata() async {
    try {
      final json = await _repository.load(_saveKey);
      if (json == null) return null;

      return {
        'version': json['version'],
        'timestamp': json['timestamp'],
        'playerType': (json['player'] as Map?)?['playerType'],
        'playerLevel': (json['player'] as Map?)?['level'],
        'currentDay': (json['world'] as Map?)?['currentDay'],
        'money': (json['player'] as Map?)?['money'],
      };
    } catch (e) {
      developer.log('[SaveService] Error getting metadata', error: e);
      return null;
    }
  }

  /// Backs up a corrupted save file for debugging.
  Future<void> _backupCorruptedSave(Map<String, dynamic> data) async {
    try {
      final backupKey =
          'backup_corrupted_${DateTime.now().millisecondsSinceEpoch}';
      await _repository.save(backupKey, data);
      developer.log('[SaveService] Corrupted save backed up to: $backupKey');
    } catch (e) {
      developer.log('[SaveService] Failed to backup corrupted save', error: e);
    }
  }

  /// Disposes resources (timers).
  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
}
