import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/farm_service_locator.dart'
    as farm_di;
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/usecases/load_farm_use_case.dart';
import 'package:darkness_dungeon/gameplay/farm/usecases/save_farm_use_case.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/services/item_factory_service.dart';
import 'package:darkness_dungeon/gameplay/time/time_manager.dart' as new_time;

final class GameSaveController {
  GameSaveController._();

  static final instance = GameSaveController._();

  Future<bool> saveGame() async {
    try {
      developer.log('[GameSaveController] Starting game save...');

      final playerData = _collectPlayerData();
      final life = (playerData['playerModel'] as Map?)?['life'];
      if (life == null || (life is num && life <= 0)) {
        developer.log(
          '[GameSaveController] ❌ Aborting save: player life is null/<=0 (life=$life). Avoid overwriting good saves after death.',
          level: 1000,
        );
        return false;
      }
      final worldData = _collectWorldData();
      final inventoryData = _collectInventoryData();
      final farmData = _collectFarmData();

      worldData['time'] = new_time.TimeManager.instance.toJson();

      worldData['farmData'] = farmData;

      final saveData = SaveData(
        version: SaveData.kCurrentVersion,
        timestamp: DateTime.now(),
        playerData: playerData,
        worldData: worldData,
        inventoryData: inventoryData,
      );

      final success = await SaveManager.instance.save(saveData);

      if (success) {
        developer.log('[GameSaveController] ✅ Game saved successfully!');
      } else {
        developer.log('[GameSaveController] ❌ Failed to save game');
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] Error saving game',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> loadGame() async {
    try {
      developer.log('[GameSaveController] Starting game load...');

      final saveData = await SaveManager.instance.load();

      if (saveData == null) {
        developer.log('[GameSaveController] No save file found');
        return false;
      }

      developer.log(
        '[GameSaveController] Save data loaded, restoring components...',
      );

      _restorePlayerData(saveData.playerData);
      _restoreWorldData(saveData.worldData);
      _restoreTimeData(saveData.worldData['time'] as Map<String, dynamic>?);
      _restoreInventoryData(saveData.inventoryData);
      _restoreFarmData(saveData.worldData['farmData'] as Map<String, dynamic>?);

      developer.log('[GameSaveController] ✅ Game loaded successfully!');
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] Error loading game',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> hasSave() async {
    return await SaveManager.instance.hasSave();
  }

  Future<bool> deleteSave() async {
    return await SaveManager.instance.deleteSave();
  }

  Future<bool> clearGameAndSave() async {
    try {
      developer.log('[GameSaveController] 🗑️ Clearing game and save...');

      PlayerStateManager.instance.reset();
      InventoryManager.instance.clear();
      getIt<FarmManager>().reset();
      WorldStateManager.instance.reset();

      developer.log('[GameSaveController] ✅ All managers reset');

      final deleted = await SaveManager.instance.deleteSave();

      if (deleted) {
        developer.log('[GameSaveController] ✅ Save file deleted');
      } else {
        developer.log('[GameSaveController] ⚠️ No save file to delete');
      }

      developer.log(
        '[GameSaveController] ✅ Game and save cleared successfully!',
      );
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] Error clearing game and save',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Map<String, dynamic> _collectPlayerData() {
    final playerState = PlayerStateManager.instance;
    final playerData = playerState.toJson();

    final playerModelJson = (playerData['playerModel'] as Map?) ?? const {};
    final coins = playerModelJson['coins'];
    final life = playerModelJson['life'];
    final stamina = playerModelJson['stamina'];

    developer.log(
      '[GameSaveController] Collecting player data: '
      'model=${playerState.lastPlayerModel != null ? playerState.lastPlayerModel.runtimeType : "null"}, '
      'stamina=$stamina, life=$life, coins=$coins, raw=$playerModelJson',
    );

    if (life == null || (life is num && life <= 0)) {
      developer.log(
        '[GameSaveController] ⚠️ Player life is null/<=0 during save, skipping validation? raw=$playerModelJson',
        level: 900,
      );
    }

    if (coins is num && coins < 0) {
      developer.log(
        '[GameSaveController] ⚠️ Player coins negative during save, raw=$playerModelJson',
        level: 900,
      );
    }

    return playerData;
  }

  Map<String, dynamic> _collectWorldData() {
    final worldState = WorldStateManager.instance;
    return worldState.toJson();
  }

  Map<String, dynamic> _collectInventoryData() {
    final inventory = InventoryManager.instance;
    return inventory.toJson();
  }

  Map<String, dynamic> _collectFarmData() {
    final saveFarmUseCase = farm_di.getIt<SaveFarmUseCase>();
    return saveFarmUseCase.call();
  }

  void _restorePlayerData(Map<String, dynamic> data) {
    try {
      developer.log(
        '[GameSaveController] Restoring player data: ${data.keys.toList()}, '
        'coinsField=${(data['playerModel'] as Map?)?['coins']}',
      );
      final playerState = PlayerStateManager.instance;
      playerState.fromJson(data);
      
      developer.log(
        '[GameSaveController] ✅ Player state restored: '
        'model=${playerState.lastPlayerModel != null ? playerState.lastPlayerModel.runtimeType : "null"}, '
        'stamina=${playerState.lastPlayerModel?.stamina}, '
        'life=${playerState.lastPlayerModel?.life}, '
        'coins=${playerState.lastPlayerModel?.coins}',
      );

      final restoredLife = playerState.lastPlayerModel?.life;
      if (restoredLife == null || restoredLife <= 0) {
        developer.log(
          '[GameSaveController] ⚠️ Restored player life is null/<=0. payload=${data['playerModel']}',
          level: 900,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] ❌ Error restoring player data: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _restoreWorldData(Map<String, dynamic> data) {
    try {
      developer.log(
        '[GameSaveController] Restoring world data: ${data.keys.toList()}',
      );
      final worldState = WorldStateManager.instance;
      worldState.fromJson(data);
      developer.log('[GameSaveController] ✅ World state restored');
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] ❌ Error restoring world data: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _restoreTimeData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        developer.log('[GameSaveController] No time state data found');
        return;
      }

      new_time.TimeManager.instance.fromJson(data);
      developer.log('[GameSaveController] ✅ Time state restored');
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] ❌ Error restoring time state: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _restoreInventoryData(Map<String, dynamic> data) {
    try {
      developer.log(
        '[GameSaveController] Restoring inventory data: ${data.keys.toList()}',
      );
      final inventory = InventoryManager.instance;
      inventory.fromJson(data, getIt<ItemFactoryService>().createItem);
      developer.log('[GameSaveController] ✅ Inventory restored');
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] ❌ Error restoring inventory data: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _restoreFarmData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        developer.log('[GameSaveController] ⚠️ No farm data to restore');
        return;
      }

      developer.log(
        '[GameSaveController] Restoring farm data: ${data.keys.toList()}',
      );
      final loadFarmUseCase = farm_di.getIt<LoadFarmUseCase>();
      loadFarmUseCase.call(data);
      developer.log('[GameSaveController] ✅ Farm state restored');
    } catch (e, stackTrace) {
      developer.log(
        '[GameSaveController] ❌ Error restoring farm data: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
