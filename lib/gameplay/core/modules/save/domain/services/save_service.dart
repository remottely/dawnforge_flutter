import 'dart:async';
import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/save/domain/interfaces/i_saveable.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/farm_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/game_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/inventory_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/player_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/world_save_data.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_repository.dart';

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

final class SaveService {
  final SaveRepository _repository;
  final String _saveKey;

  static const Duration kAutoSaveDebounce = Duration(seconds: 30);

  Timer? _autoSaveTimer;
  DateTime? _lastSaveTime;

  SaveService({SaveRepository? repository, String saveKey = 'main_save'})
    : _repository = repository ?? SaveRepository(),
      _saveKey = saveKey;

  Future<SaveResult> saveGame({
    required ISaveable<PlayerSaveData> playerManager,
    required ISaveable<WorldSaveData> worldManager,
    required ISaveable<InventorySaveData> inventoryManager,
    required ISaveable<FarmSaveData> farmManager,
    Map<String, dynamic>? progressData,
  }) async {
    try {
      developer.log('[SaveService] Starting save operation...');

      final player = playerManager.toSaveData();
      final world = worldManager.toSaveData();
      final inventory = inventoryManager.toSaveData();
      final farm = farmManager.toSaveData();

      final gameSaveData = GameSaveData(
        version: GameSaveData.kCurrentVersion,
        timestamp: DateTime.now(),
        player: player,
        world: world,
        inventory: inventory,
        farm: farm,
        progress: progressData ?? {},
      );

      if (!gameSaveData.isValid()) {
        developer.log('[SaveService] Save data validation failed', level: 900);
        return const SaveResult.failure('Save data validation failed');
      }

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

  Future<LoadResult> loadGame() async {
    try {
      developer.log('[SaveService] Starting load operation...');

      final json = await _repository.load(_saveKey);

      if (json == null) {
        developer.log('[SaveService] No save file found', level: 500);
        return const LoadResult.failure('No save file found');
      }

      final gameSaveData = GameSaveData.fromJson(json);

      if (!gameSaveData.isValid()) {
        developer.log(
          '[SaveService] Loaded save data is corrupted',
          level: 900,
        );

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

  Future<bool> hasSave() async {
    try {
      return await _repository.exists(_saveKey);
    } catch (e) {
      developer.log('[SaveService] Error checking save existence', error: e);
      return false;
    }
  }

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

  void scheduleAutoSave({
    required ISaveable<PlayerSaveData> playerManager,
    required ISaveable<WorldSaveData> worldManager,
    required ISaveable<InventorySaveData> inventoryManager,
    required ISaveable<FarmSaveData> farmManager,
    Map<String, dynamic>? progressData,
  }) {
    _autoSaveTimer?.cancel();

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
        'coins': (json['player'] as Map?)?['coins'],
      };
    } catch (e) {
      developer.log('[SaveService] Error getting metadata', error: e);
      return null;
    }
  }

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

  void dispose() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
}
