import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/save/player_progress_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/time/time_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';

final class GameStateCollector {
  GameStateCollector._();

  static SaveData collectCurrentGameState() {
    developer.log('[GameStateCollector] Collecting current game state');

    final worldState = WorldStateManager.instance.toJson();
    final timeState = TimeManager.instance.toJson();
    final progressState = PlayerProgressManager.instance.toJson();
    final inventoryState = InventoryManager.instance.toJson();
    final equipmentState = EquipmentManager.instance.toJson();

    final worldData = {
      'world': worldState,
      'time': timeState,
      'progress': progressState,
    };

    final inventoryData = {
      'inventory': inventoryState,
      'equipment': equipmentState,
    };

    final saveData = SaveData(
      version: SaveData.kCurrentVersion,
      timestamp: DateTime.now(),
      playerData: {'_placeholder': true},
      worldData: worldData,
      inventoryData: inventoryData,
    );

    developer.log(
      '[GameStateCollector] Game state collected: '
      'Day ${WorldStateManager.instance.currentDay}, '
      'Time ${TimeManager.instance.currentHour}:${TimeManager.instance.currentMinute}, '
      '${PlayerProgressManager.instance.getAllFlags().length} flags, '
      'Items: ${InventoryManager.instance.usedSlots}, '
      'Equipment: ${EquipmentManager.instance.getAllEquippedItems().length}',
    );

    return saveData;
  }

  static bool restoreGameState(SaveData saveData) {
    try {
      developer.log('[GameStateCollector] Restoring game state');

      if (!saveData.isValid()) {
        developer.log(
          '[GameStateCollector] Cannot restore from invalid save data',
          level: 900,
        );
        return false;
      }

      final worldData = saveData.worldData;
      final inventoryData = saveData.inventoryData;

      final worldState = worldData['world'] as Map<String, dynamic>?;
      if (worldState != null) {
        WorldStateManager.instance.fromJson(worldState);
        developer.log('[GameStateCollector] World state restored');
      } else {
        developer.log(
          '[GameStateCollector] No world state data found',
          level: 500,
        );
      }

      final timeState = worldData['time'] as Map<String, dynamic>?;
      if (timeState != null) {
        TimeManager.instance.fromJson(timeState);
        developer.log('[GameStateCollector] Time state restored');
      } else {
        developer.log(
          '[GameStateCollector] No time state data found',
          level: 500,
        );
      }

      final progressState = worldData['progress'] as Map<String, dynamic>?;
      if (progressState != null) {
        PlayerProgressManager.instance.fromJson(progressState);
        developer.log('[GameStateCollector] Progress state restored');
      } else {
        developer.log(
          '[GameStateCollector] No progress state data found',
          level: 500,
        );
      }

      final inventoryState =
          inventoryData['inventory'] as Map<String, dynamic>?;
      if (inventoryState != null) {
        InventoryManager.instance.fromJson(
          inventoryState,
          ItemFactoryService.createItem,
        );
        developer.log('[GameStateCollector] Inventory state restored');
      } else {
        developer.log(
          '[GameStateCollector] No inventory state data found',
          level: 500,
        );
      }

      final equipmentState =
          inventoryData['equipment'] as Map<String, dynamic>?;
      if (equipmentState != null) {
        EquipmentManager.instance.fromJson(
          equipmentState,
          ItemFactoryService.createItem,
        );
        developer.log('[GameStateCollector] Equipment state restored');
      } else {
        developer.log(
          '[GameStateCollector] No equipment state data found',
          level: 500,
        );
      }

      developer.log(
        '[GameStateCollector] Game state restored successfully: '
        'Day ${WorldStateManager.instance.currentDay}, '
        'Time ${TimeManager.instance.currentHour}:${TimeManager.instance.currentMinute}, '
        '${PlayerProgressManager.instance.getAllFlags().length} flags, '
        'Items: ${InventoryManager.instance.usedSlots}, '
        'Equipment: ${EquipmentManager.instance.getAllEquippedItems().length}',
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameStateCollector] Error restoring game state',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  static void resetAllManagers() {
    developer.log('[GameStateCollector] Resetting all managers');

    WorldStateManager.instance.reset();
    TimeManager.instance.reset();
    PlayerProgressManager.instance.reset();
    InventoryManager.instance.reset();
    EquipmentManager.instance.reset();

    developer.log('[GameStateCollector] All managers reset complete');
  }

  static bool validateCurrentState() {
    try {
      final worldDay = WorldStateManager.instance.currentDay;
      if (worldDay < 1) {
        developer.log(
          '[GameStateCollector] Invalid world state: day < 1',
          level: 900,
        );
        return false;
      }

      final currentTime = TimeManager.instance.currentTime;
      if (currentTime < 0 || currentTime >= 86400) {
        developer.log(
          '[GameStateCollector] Invalid time state: time out of range',
          level: 900,
        );
        return false;
      }

      developer.log('[GameStateCollector] Current state is valid');
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameStateCollector] Error validating state',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  static String getCurrentStateSummary() {
    final world = WorldStateManager.instance;
    final time = TimeManager.instance;
    final progress = PlayerProgressManager.instance;
    final inventory = InventoryManager.instance;
    final equipment = EquipmentManager.instance;

    return '''
Game State Summary:
- Day: ${world.currentDay} (${world.currentSeason.displayName})
- Time: ${time.currentHour.toString().padLeft(2, '0')}:${time.currentMinute.toString().padLeft(2, '0')} (${time.currentTimeOfDay.displayName})
- Current Map: ${world.currentMapId ?? 'None'}
- Active Maps: ${world.activeMapCount}
- Flags: ${progress.getAllFlags().length}
- Achievements: ${progress.getAllAchievements().length}
- Play Time: ${progress.totalPlayTimeSeconds ~/ 3600}h ${(progress.totalPlayTimeSeconds % 3600) ~/ 60}m
- Enemies Defeated: ${progress.enemiesDefeated}
- Items Crafted: ${progress.itemsCrafted}
- Distance Traveled: ${progress.distanceTraveled}
- Inventory Slots Used: ${inventory.usedSlots}/${inventory.maxSlots}
- Equipment Slots Used: ${equipment.getAllEquippedItems().length}/8
- Total Damage: ${equipment.getTotalDamage()}
- Total DPS: ${equipment.getTotalDps().toStringAsFixed(1)}
    '''
        .trim();
  }
}
