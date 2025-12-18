// import 'dart:developer' as developer;

// import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/save/game_state_collector.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/save/player_progress_manager.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/save/save_manager.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/time/time_manager.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
// import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_model.dart';

// final class PlayerSaveAdapter {
//   PlayerSaveAdapter._();

//   static Future<bool> saveGame(DDBasePlayerModel player) async {
//     try {
//       developer.log('[PlayerSaveAdapter] Initiating game save...');

//       final playerJson = player.toJson();

//       final worldData = {
//         'world': WorldStateManager.instance.toJson(),
//         'time': TimeManager.instance.toJson(),
//         'progress': PlayerProgressManager.instance.toJson(),
//       };

//       final saveData = SaveData(
//         version: SaveData.kCurrentVersion,
//         timestamp: DateTime.now(),
//         playerData: playerJson,
//         worldData: worldData,
//         inventoryData: {},
//       );

//       final success = await SaveManager.instance.save(saveData);

//       if (success) {
//         developer.log('[PlayerSaveAdapter] Game saved successfully');
//       } else {
//         developer.log('[PlayerSaveAdapter] Save failed', level: 900);
//       }

//       return success;
//     } catch (e, stackTrace) {
//       developer.log(
//         '[PlayerSaveAdapter] Error during save',
//         error: e,
//         stackTrace: stackTrace,
//         level: 1000,
//       );
//       return false;
//     }
//   }

//   static Future<DDBasePlayerModel?> loadGame() async {
//     try {
//       developer.log('[PlayerSaveAdapter] Initiating game load...');

//       final saveData = await SaveManager.instance.load();

//       if (saveData == null) {
//         developer.log('[PlayerSaveAdapter] No save data found', level: 500);
//         return null;
//       }

//       if (!GameStateCollector.restoreGameState(saveData)) {
//         developer.log(
//           '[PlayerSaveAdapter] Failed to restore manager state',
//           level: 900,
//         );
//         return null;
//       }

//       final player = saveDataToPlayer(saveData);

//       if (player == null) {
//         developer.log(
//           '[PlayerSaveAdapter] Failed to restore player',
//           level: 900,
//         );
//         return null;
//       }

//       developer.log(
//         '[PlayerSaveAdapter] Game loaded successfully: '
//         '${player.toJson()['playerType']}',
//       );

//       return player;
//     } catch (e, stackTrace) {
//       developer.log(
//         '[PlayerSaveAdapter] Error during load',
//         error: e,
//         stackTrace: stackTrace,
//         level: 1000,
//       );
//       return null;
//     }
//   }

//   static Future<bool> hasSavedGame() async {
//     return await SaveManager.instance.hasSave();
//   }

//   static Future<bool> deleteSavedGame() async {
//     developer.log('[PlayerSaveAdapter] Deleting saved game...');
//     return await SaveManager.instance.deleteSave();
//   }

//   static SaveData playerToSaveData(DDBasePlayerModel player) {
//     final playerJson = player.toJson();

//     final worldData = {
//       'world': WorldStateManager.instance.toJson(),
//       'time': TimeManager.instance.toJson(),
//       'progress': PlayerProgressManager.instance.toJson(),
//     };

//     return SaveData(
//       version: SaveData.kCurrentVersion,
//       timestamp: DateTime.now(),
//       playerData: playerJson,
//       worldData: worldData,
//       inventoryData: {},
//     );
//   }

//   static DDBasePlayerModel? saveDataToPlayer(SaveData saveData) {
//     try {
//       final playerData = saveData.playerData;

//       if (playerData.isEmpty) {
//         developer.log('[PlayerSaveAdapter] Player data is empty', level: 900);
//         return null;
//       }

//       final playerType = playerData['playerType'] as String?;

//       switch (playerType) {
//         case 'sunny':
//           return SunnyPlayerModel.fromJson(playerData);
//         default:
//           developer.log(
//             '[PlayerSaveAdapter] Unknown player type: $playerType',
//             level: 900,
//           );
//           return null;
//       }
//     } catch (e, stackTrace) {
//       developer.log(
//         '[PlayerSaveAdapter] Error converting SaveData to Player',
//         error: e,
//         stackTrace: stackTrace,
//         level: 1000,
//       );
//       return null;
//     }
//   }

//   static bool validateCurrentState(DDBasePlayerModel player) {
//     try {
//       final playerJson = player.toJson();
//       if (playerJson.isEmpty) {
//         developer.log(
//           '[PlayerSaveAdapter] Player serialization produced empty data',
//           level: 900,
//         );
//         return false;
//       }

//       if (!GameStateCollector.validateCurrentState()) {
//         developer.log(
//           '[PlayerSaveAdapter] Manager state validation failed',
//           level: 900,
//         );
//         return false;
//       }

//       developer.log('[PlayerSaveAdapter] State validation passed');
//       return true;
//     } catch (e, stackTrace) {
//       developer.log(
//         '[PlayerSaveAdapter] Error during state validation',
//         error: e,
//         stackTrace: stackTrace,
//         level: 1000,
//       );
//       return false;
//     }
//   }

//   static Future<String?> getSaveSummary() async {
//     try {
//       final saveData = await SaveManager.instance.load();
//       if (saveData == null) return null;

//       final playerData = saveData.playerData;
//       final playerType = playerData['playerType'] as String? ?? 'Unknown';
//       final timestamp = saveData.timestamp;

//       final worldState = GameStateCollector.getCurrentStateSummary();

//       return '''
// Save Summary:
// - Player Type: ${playerType.toUpperCase()}
// - Saved: ${timestamp.toLocal()}
// - Age: ${DateTime.now().difference(timestamp).inHours}h ago

// $worldState
//       '''
//           .trim();
//     } catch (e) {
//       developer.log(
//         '[PlayerSaveAdapter] Error getting save summary',
//         error: e,
//         level: 900,
//       );
//       return null;
//     }
//   }
// }
