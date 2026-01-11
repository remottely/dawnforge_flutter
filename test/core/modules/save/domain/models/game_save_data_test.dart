// import 'package:dawnforge/gameplay/core/modules/save/domain/models/game_save_data.dart';
// import 'package:test/test.dart';

// void main() {
//   group('GameSaveData', () {
//     test('newGame() creates valid initial state', () {
//       final data = GameSaveData.newGame(
//         playerType: 'knight',
//         playerName: 'Hero',
//       );

//       expect(data.version, GameSaveData.kCurrentVersion);
//       expect(data.player.playerType, 'knight');
//       expect(data.player.playerName, 'Hero');
//       expect(data.world.currentDay, 1);
//       expect(data.farm.farmLayout, 'standard');
//       expect(data.isValid(), isTrue);
//     });

//     test('toJson() and fromJson() round-trip correctly', () {
//       final original = GameSaveData.newGame(
//         playerType: 'sunny',
//         playerName: 'Test',
//       );

//       final json = original.toJson();
//       final restored = GameSaveData.fromJson(json);

//       expect(restored.version, original.version);
//       expect(restored.player.playerType, original.player.playerType);
//       expect(restored.player.playerName, original.player.playerName);
//       expect(restored.world.currentDay, original.world.currentDay);
//       expect(restored.isValid(), isTrue);
//     });

//     test('migration from version 1 to 2 works', () {
//       // Simulate old v1 save format
//       final oldJson = {
//         'version': 1,
//         'timestamp': DateTime.now().toIso8601String(),
//         'playerData': {
//           'playerType': 'knight',
//           'level': 5,
//           'health': 100.0,
//           'maxHealth': 100.0,
//           'money': 1000,
//           'positionX': 0.0,
//           'positionY': 0.0,
//           'currentMapId': 'farm',
//           'direction': 'down',
//           'stamina': 100.0,
//           'maxStamina': 100.0,
//           'energy': 100.0,
//           'maxEnergy': 100.0,
//           'experience': 0,
//           'experienceToNextLevel': 100,
//           'farmingLevel': 1,
//           'miningLevel': 1,
//           'foragingLevel': 1,
//           'fishingLevel': 1,
//           'combatLevel': 1,
//         },
//         'worldData': {
//           'currentDay': 10,
//           'currentSeason': 'spring',
//           'currentYear': 1,
//           'timeOfDaySeconds': 21600,
//           'weather': 'sunny',
//           'activeEvents': [],
//           'completedEvents': [],
//           'unlockedMaps': {'farm': true},
//           'timeScale': 1.0,
//           'isPaused': false,
//         },
//         'inventoryData': {
//           'inventorySlots': [],
//           'equipment': {},
//           'containers': {},
//           'quickBarSlots': [],
//           'maxInventorySlots': 36,
//         },
//       };

//       final migrated = GameSaveData.fromJson(oldJson);

//       expect(migrated.version, GameSaveData.kCurrentVersion);
//       expect(migrated.player.level, 5); // Preserved from v1 playerData
//       expect(migrated.world.currentDay, 10);
//       expect(migrated.isValid(), isTrue);
//     });

//     test('isValid() detects corrupted data', () {
//       final valid = GameSaveData.newGame(playerType: 'knight');
//       expect(valid.isValid(), isTrue);

//       // Invalid player
//       final invalidPlayer = valid.copyWith(
//         player: valid.player.copyWith(health: -10),
//       );
//       expect(invalidPlayer.isValid(), isFalse);

//       // Invalid world
//       final invalidWorld = valid.copyWith(
//         world: valid.world.copyWith(currentDay: 0),
//       );
//       expect(invalidWorld.isValid(), isFalse);

//       // Future timestamp (corrupted)
//       final futureTimestamp = valid.copyWith(
//         timestamp: DateTime.now().add(const Duration(hours: 1)),
//       );
//       expect(futureTimestamp.isValid(), isFalse);
//     });

//     test('getSummary() provides human-readable info', () {
//       final data = GameSaveData.newGame(
//         playerType: 'knight',
//         playerName: 'TestHero',
//       );

//       final summary = data.getSummary();

//       expect(summary, contains('TestHero'));
//       expect(summary, contains('Level 1'));
//       expect(
//         summary,
//         contains('Day: 1 of Spring'),
//       ); // Correct format from getSummary()
//       expect(summary, contains('Spring'));
//     });

//     test('copyWith() creates modified copy', () {
//       final original = GameSaveData.newGame(playerType: 'knight');
//       final modified = original.copyWith(
//         player: original.player.copyWith(level: 10),
//         world: original.world.copyWith(currentDay: 15),
//       );

//       expect(modified.player.level, 10);
//       expect(modified.world.currentDay, 15);
//       expect(modified.inventory, same(original.inventory));
//       expect(modified.farm, same(original.farm));
//     });
//   });
// }
