
import 'package:darkness_dungeon/core/utils/logger/game_logger.dart';

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
      GameLogger.info('[GameSaveController] Starting game save...');

      final playerData = _collectPlayerData();
      final life = (playerData['playerModel'] as Map?)?['life'];
      if (life == null || (life is num && life <= 0)) {
        GameLogger.warning('[GameSaveController] ❌ Aborting save: player life is null/<=0 (life=$life). Avoid overwriting good saves after death.');
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
        GameLogger.info('[GameSaveController] ✅ Game saved successfully!');
      } else {
        GameLogger.error('[GameSaveController] ❌ Failed to save game');
      }

      return success;
    } catch (e) {
      GameLogger.error('[GameSaveController] Error saving game: $e');
      return false;
    }
  }

  Future<bool> loadGame() async {
    try {
      GameLogger.info('[GameSaveController] Starting game load...');

      final saveData = await SaveManager.instance.load();

      if (saveData == null) {
          GameLogger.warning('[GameSaveController] No save file found');
        return false;
      }

      GameLogger.info('[GameSaveController] Save data loaded, restoring components...');

      _restorePlayerData(saveData.playerData);
      _restoreWorldData(saveData.worldData);
      _restoreTimeData(saveData.worldData['time'] as Map<String, dynamic>?);
      _restoreInventoryData(saveData.inventoryData);
      _restoreFarmData(saveData.worldData['farmData'] as Map<String, dynamic>?);

      GameLogger.info('[GameSaveController] ✅ Game loaded successfully!');
      return true;
    } catch (e) {
      GameLogger.error('[GameSaveController] Error loading game: $e');
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
      GameLogger.info('[GameSaveController] 🗑️ Clearing game and save...');

      PlayerStateManager.instance.reset();
      InventoryManager.instance.clear();
      getIt<FarmManager>().reset();
      WorldStateManager.instance.reset();

      GameLogger.info('[GameSaveController] ✅ All managers reset');

      final deleted = await SaveManager.instance.deleteSave();

      if (deleted) {
          GameLogger.info('[GameSaveController] ✅ Save file deleted');
      } else {
          GameLogger.warning('[GameSaveController] ⚠️ No save file to delete');
      }

      return true;
    } catch (e) {
      GameLogger.error('[GameSaveController] Error clearing game and save: $e');
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

    GameLogger.info('[GameSaveController] Collecting player data: model=${playerState.lastPlayerModel != null ? playerState.lastPlayerModel.runtimeType : "null"}, stamina=$stamina, life=$life, coins=$coins, raw=$playerModelJson');

    if (life == null || (life is num && life <= 0)) {
      GameLogger.warning('[GameSaveController] ⚠️ Player life is null/<=0 during save, skipping validation? raw=$playerModelJson');
    }

    if (coins is num && coins < 0) {
      GameLogger.warning('[GameSaveController] ⚠️ Player coins negative during save, raw=$playerModelJson');
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
      GameLogger.info('[GameSaveController] Restoring player data: ${data.keys.toList()}, coinsField=${(data['playerModel'] as Map?)?['coins']}');
      final playerState = PlayerStateManager.instance;
      playerState.fromJson(data);
      GameLogger.info('[GameSaveController] ✅ Player state restored: model=${playerState.lastPlayerModel != null ? playerState.lastPlayerModel.runtimeType : "null"}, stamina=${playerState.lastPlayerModel?.stamina}, life=${playerState.lastPlayerModel?.life}, coins=${playerState.lastPlayerModel?.coins}');

      final restoredLife = playerState.lastPlayerModel?.life;
      if (restoredLife == null || restoredLife <= 0) {
        GameLogger.warning('[GameSaveController] ⚠️ Restored player life is null/<=0. payload=${data['playerModel']}');
      }
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring player data: $e');
    }
  }

  void _restoreWorldData(Map<String, dynamic> data) {
    try {
      GameLogger.info('[GameSaveController] Restoring world data: ${data.keys.toList()}');
      final worldState = WorldStateManager.instance;
      worldState.fromJson(data);
      GameLogger.info('[GameSaveController] ✅ World state restored');
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring world data: $e');
    }
  }

  void _restoreTimeData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        GameLogger.warning('[GameSaveController] No time state data found');
        return;
      }

      new_time.TimeManager.instance.fromJson(data);
      GameLogger.info('[GameSaveController] ✅ Time state restored');
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring time state: $e');
    }
  }

  void _restoreInventoryData(Map<String, dynamic> data) {
    try {
      GameLogger.info('[GameSaveController] Restoring inventory data: ${data.keys.toList()}');
      final inventory = InventoryManager.instance;
      inventory.fromJson(data, getIt<ItemFactoryService>().createItem);
      GameLogger.info('[GameSaveController] ✅ Inventory restored');
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring inventory data: $e');
    }
  }

  void _restoreFarmData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        GameLogger.warning('[GameSaveController] ⚠️ No farm data to restore');
        return;
      }

      GameLogger.info('[GameSaveController] Restoring farm data: ${data.keys.toList()}');
      final loadFarmUseCase = farm_di.getIt<LoadFarmUseCase>();
      loadFarmUseCase.call(data);
      GameLogger.info('[GameSaveController] ✅ Farm state restored');
    } catch (e) {
      GameLogger.error('[GameSaveController] ❌ Error restoring farm data: $e');
    }
  }
}
