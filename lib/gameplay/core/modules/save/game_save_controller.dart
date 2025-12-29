import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/farm/managers/farm_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/services/item_factory_service.dart';

final class GameSaveController {
  GameSaveController._();

  static final instance = GameSaveController._();

  Future<bool> saveGame() async {
    try {
      developer.log('[GameSaveController] Starting game save...');

      final playerData = _collectPlayerData();
      final worldData = _collectWorldData();
      final inventoryData = _collectInventoryData();
      final farmData = _collectFarmData();

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

      _restorePlayerData(saveData.playerData);
      _restoreWorldData(saveData.worldData);
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
      FarmManager.instance.reset();
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
    return playerState.toJson();
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
    final farm = FarmManager.instance;
    return farm.toJson();
  }

  void _restorePlayerData(Map<String, dynamic> data) {
    try {
      final playerState = PlayerStateManager.instance;
      playerState.fromJson(data);
      developer.log('[GameSaveController] Player state restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring player data: $e');
    }
  }

  void _restoreWorldData(Map<String, dynamic> data) {
    try {
      final worldState = WorldStateManager.instance;
      worldState.fromJson(data);
      developer.log('[GameSaveController] World state restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring world data: $e');
    }
  }

  void _restoreInventoryData(Map<String, dynamic> data) {
    try {
      final inventory = InventoryManager.instance;
      inventory.fromJson(data, getIt<ItemFactoryService>().createItem);
      developer.log('[GameSaveController] Inventory restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring inventory data: $e');
    }
  }

  void _restoreFarmData(Map<String, dynamic>? data) {
    try {
      if (data == null) {
        developer.log('[GameSaveController] No farm data to restore');
        return;
      }

      final farm = FarmManager.instance;
      farm.fromJson(data);
      developer.log('[GameSaveController] Farm state restored');
    } catch (e) {
      developer.log('[GameSaveController] Error restoring farm data: $e');
    }
  }
}
