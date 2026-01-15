// import 'package:dawnforge/core/utils/logger/game_logger.dart';

// import 'package:dawnforge/features/core/modules/save/player_progress_manager.dart';
// import 'package:dawnforge/features/core/modules/save/save_data_model.dart';
// import 'package:dawnforge/features/core/modules/world/world_state_manager.dart';
// import 'package:dawnforge/features/farm/farm_service_locator.dart'
//     as farm_di;
// import 'package:dawnforge/features/farm/usecases/load_farm_use_case.dart';
// import 'package:dawnforge/features/farm/usecases/save_farm_use_case.dart';
// import 'package:dawnforge/features/inventory/config/inventory_service_locator.dart'
//     as inv_di;
// import 'package:dawnforge/features/inventory/managers/equipment_manager.dart';
// import 'package:dawnforge/features/inventory/managers/inventory_manager.dart';
// import 'package:dawnforge/features/inventory/services/item_factory_service.dart';
// import 'package:dawnforge/features/time/time_constants.dart';
// import 'package:dawnforge/features/time/time_manager.dart' as new_time;

// final class GameStateCollector {
//   GameStateCollector._();

//   static SaveData collectCurrentGameState() {
//     GameLogger.info('[GameStateCollector] Collecting current game state');

//     final worldState = WorldStateManager.instance.toJson();
//     final timeState = new_time.TimeManager.instance.toJson();
//     final progressState = PlayerProgressManager.instance.toJson();
//     final inventoryState = getIt<InventoryManager>().toJson();
//     final equipmentState = EquipmentManager.instance.toJson();

//     // Farm state using SaveFarmUseCase (E2)
//     final saveFarmUseCase = farm_di.getIt<SaveFarmUseCase>();
//     final farmData = saveFarmUseCase.call();

//     final worldData = {
//       'world': worldState,
//       'time': timeState,
//       'progress': progressState,
//     };

//     final inventoryData = {
//       'inventory': inventoryState,
//       'equipment': equipmentState,
//     };

//     final saveData = SaveData(
//       version: SaveData.kCurrentVersion,
//       timestamp: DateTime.now(),
//       playerData: {'_placeholder': true},
//       worldData: worldData,
//       inventoryData: inventoryData,
//       farmData: farmData,
//     );

//     GameLogger.info(
//       '[GameStateCollector] Game state collected: '
//       'Day ${WorldStateManager.instance.currentDay}, '
//       'Time ${new_time.TimeManager.instance.currentHour}:${new_time.TimeManager.instance.currentMinute}, '
//       '${PlayerProgressManager.instance.getAllFlags().length} flags, '
//       'Items: ${getIt<InventoryManager>().usedSlots}, '
//       'Equipment: ${EquipmentManager.instance.getAllEquippedItems().length}',
//     );

//     return saveData;
//   }

//   static bool restoreGameState(SaveData saveData) {
//     try {
//       GameLogger.info('[GameStateCollector] Restoring game state');

//       if (!saveData.isValid()) {
//         GameLogger.warning('[GameStateCollector] Cannot restore from invalid save data');
//         return false;
//       }

//       final worldData = saveData.worldData;
//       final inventoryData = saveData.inventoryData;
//       final farmData = saveData.farmData;

//       final worldState = worldData['world'] as Map<String, dynamic>?;
//       if (worldState != null) {
//         WorldStateManager.instance.fromJson(worldState);
//         GameLogger.info('[GameStateCollector] World state restored');
//       } else {
//         GameLogger.warning('[GameStateCollector] No world state data found');
//       }

//       final timeState = worldData['time'] as Map<String, dynamic>?;
//       if (timeState != null) {
//         new_time.TimeManager.instance.fromJson(timeState);
//         GameLogger.info('[GameStateCollector] Time state restored');
//       } else {
//         GameLogger.warning('[GameStateCollector] No time state data found');
//       }

//       final progressState = worldData['progress'] as Map<String, dynamic>?;
//       if (progressState != null) {
//         PlayerProgressManager.instance.fromJson(progressState);
//         GameLogger.info('[GameStateCollector] Progress state restored');
//       } else {
//         GameLogger.warning('[GameStateCollector] No progress state data found');
//       }

//       final inventoryState =
//           inventoryData['inventory'] as Map<String, dynamic>?;
//       if (inventoryState != null) {
//         getIt<InventoryManager>().fromJson(
//           inventoryState,
//           inv_di.getIt<ItemFactoryService>().createItem,
//         );
//         GameLogger.info('[GameStateCollector] Inventory state restored');
//       } else {
//         GameLogger.warning('[GameStateCollector] No inventory state data found');
//       }

//       final equipmentState =
//           inventoryData['equipment'] as Map<String, dynamic>?;
//       if (equipmentState != null) {
//         EquipmentManager.instance.fromJson(
//           equipmentState,
//           inv_di.getIt<ItemFactoryService>().createItem,
//         );
//         GameLogger.info('[GameStateCollector] Equipment state restored');
//       } else {
//         GameLogger.warning('[GameStateCollector] No equipment state data found');
//       }
// // Farm state using LoadFarmUseCase (E2)
//       if (farmData != null) {
//         final loadFarmUseCase = farm_di.getIt<LoadFarmUseCase>();
//         loadFarmUseCase.call(farmData);
//         GameLogger.info('[GameStateCollector] Farm state restored');
//       } else {
//         GameLogger.warning('[GameStateCollector] No farm state data found');
//       }

//       GameLogger.info(
//         '[GameStateCollector] Game state restored successfully: '
//         'Day ${WorldStateManager.instance.currentDay}, '
//         'Time ${new_time.TimeManager.instance.currentHour}:${new_time.TimeManager.instance.currentMinute}, '
//         '${PlayerProgressManager.instance.getAllFlags().length} flags, '
//         'Items: ${getIt<InventoryManager>().usedSlots}, '
//         'Equipment: ${EquipmentManager.instance.getAllEquippedItems().length}',
//       );

//       return true;
//     } catch (e) {
//       GameLogger.error('[GameStateCollector] Error restoring game state');
//       // Note: getIt<FarmManager>().reset() should be called if needed
//       return false;
//     }
//   }

//   static void resetAllManagers() {
//     GameLogger.info('[GameStateCollector] Resetting all managers');

//     WorldStateManager.instance.reset();
//     new_time.TimeManager.instance.reset();
//     PlayerProgressManager.instance.reset();
//     getIt<InventoryManager>().reset();
//     EquipmentManager.instance.reset();

//     GameLogger.info('[GameStateCollector] All managers reset complete');
//   }

//   static bool validateCurrentState() {
//     try {
//       final worldDay = WorldStateManager.instance.currentDay;
//       if (worldDay < 1) {
//         GameLogger.warning('[GameStateCollector] Invalid world state: day < 1');
//         return false;
//       }

//       final currentTimeMinutes =
//           new_time.TimeManager.instance.currentTime.totalMinutes;
//       if (currentTimeMinutes < 0 ||
//           currentTimeMinutes >= TimeConstants.kHoursPerDay * 60) {
//         GameLogger.warning('[GameStateCollector] Invalid time state: time out of range');
//         return false;
//       }

//       GameLogger.info('[GameStateCollector] Current state is valid');
//       return true;
//     } catch (e) {
//       GameLogger.error('[GameStateCollector] Error validating state');
//       return false;
//     }
//   }

//   static String getCurrentStateSummary() {
//     final world = WorldStateManager.instance;
//     final time = new_time.TimeManager.instance;
//     final progress = PlayerProgressManager.instance;
//     final inventory = getIt<InventoryManager>();
//     final equipment = EquipmentManager.instance;

//     return '''
// Game State Summary:
// - Day: ${world.currentDay} (${world.currentSeason.displayName})
// - Time: ${time.currentHour.toString().padLeft(2, '0')}:${time.currentMinute.toString().padLeft(2, '0')}
// - Current Map: ${world.currentMapId ?? 'None'}
// - Active Maps: ${world.activeMapCount}
// - Flags: ${progress.getAllFlags().length}
// - Achievements: ${progress.getAllAchievements().length}
// - Play Time: ${progress.totalPlayTimeSeconds ~/ 3600}h ${(progress.totalPlayTimeSeconds % 3600) ~/ 60}m
// - Enemies Defeated: ${progress.enemiesDefeated}
// - Items Crafted: ${progress.itemsCrafted}
// - Distance Traveled: ${progress.distanceTraveled}
// - Inventory Slots Used: ${inventory.usedSlots}/${inventory.maxSlots}
// - Equipment Slots Used: ${equipment.getAllEquippedItems().length}/8
// - Total Damage: ${equipment.getTotalDamage()}
// - Total DPS: ${equipment.getTotalDps().toStringAsFixed(1)}
//     '''
//         .trim();
//   }
// }
