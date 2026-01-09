// import 'package:darkness_dungeon/gameplay/core/modules/save/domain/models/player_save_data.dart';
// import 'package:test/test.dart';

// void main() {
//   group('PlayerSaveData', () {
//     test('initial() creates valid default state', () {
//       final data = PlayerSaveData.initial(playerType: 'knight');

//       expect(data.playerType, 'knight');
//       expect(data.level, 1);
//       expect(data.health, 100.0);
//       expect(data.maxHealth, 100.0);
//       expect(data.coins, 500);
//       expect(data.isValid(), isTrue);
//     });

//     test('fromJson() deserializes correctly', () {
//       final json = {
//         'playerType': 'sunny',
//         'playerName': 'Test Player',
//         'level': 5,
//         'health': 80.0,
//         'maxHealth': 120.0,
//         'coins': 1000,
//         'positionX': 10.0,
//         'positionY': 20.0,
//         'currentMapId': 'town',
//         'direction': 'up',
//         'stamina': 90.0,
//         'maxStamina': 100.0,
//         'energy': 95.0,
//         'maxEnergy': 100.0,
//         'experience': 250,
//         'experienceToNextLevel': 500,
//         'farmingLevel': 2,
//         'miningLevel': 1,
//         'foragingLevel': 1,
//         'fishingLevel': 1,
//         'combatLevel': 3,
//       };

//       final data = PlayerSaveData.fromJson(json);

//       expect(data.playerType, 'sunny');
//       expect(data.playerName, 'Test Player');
//       expect(data.level, 5);
//       expect(data.health, 80.0);
//       expect(data.coins, 1000);
//       expect(data.isValid(), isTrue);
//     });

//     test('toJson() serializes correctly', () {
//       final data = PlayerSaveData.initial(
//         playerType: 'knight',
//         playerName: 'Hero',
//       );

//       final json = data.toJson();

//       expect(json['playerType'], 'knight');
//       expect(json['playerName'], 'Hero');
//       expect(json['level'], 1);
//       expect(json['health'], 100.0);
//       expect(json['coins'], 500);
//     });

//     test('isValid() detects invalid states', () {
//       // Health exceeds max health
//       final invalidHealth = PlayerSaveData.initial(
//         playerType: 'knight',
//       ).copyWith(health: 150.0, maxHealth: 100.0);
//       expect(invalidHealth.isValid(), isFalse);

//       // Negative coins
//       final negativeCoins = PlayerSaveData.initial(
//         playerType: 'knight',
//       ).copyWith(coins: -10);
//       expect(negativeCoins.isValid(), isFalse);

//       // Invalid level
//       final invalidLevel = PlayerSaveData.initial(
//         playerType: 'knight',
//       ).copyWith(level: 0);
//       expect(invalidLevel.isValid(), isFalse);

//       // Valid data
//       final valid = PlayerSaveData.initial(playerType: 'knight');
//       expect(valid.isValid(), isTrue);
//     });

//     test('copyWith() creates modified copy', () {
//       final original = PlayerSaveData.initial(playerType: 'knight');
//       final modified = original.copyWith(level: 10, coins: 5000);

//       expect(modified.level, 10);
//       expect(modified.coins, 5000);
//       expect(modified.playerType, original.playerType);
//       expect(modified.health, original.health);
//     });

//     test('equality works correctly', () {
//       final data1 = PlayerSaveData.initial(playerType: 'knight');
//       final data2 = PlayerSaveData.initial(playerType: 'knight');
//       final data3 = data1.copyWith(level: 2);

//       expect(data1, equals(data2));
//       expect(data1, isNot(equals(data3)));
//     });

//     test('fromJson() handles missing fields with defaults', () {
//       final json = {'playerType': 'knight'};

//       final data = PlayerSaveData.fromJson(json);

//       expect(data.playerType, 'knight');
//       expect(data.level, 1); // Default
//       expect(data.health, 100.0); // Default
//       expect(data.coins, 500); // Default
//       expect(data.isValid(), isTrue);
//     });
//   });
// }
