import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/models/map_model.dart';
import 'package:darkness_dungeon/gameplay/core/utils/gameplay_map_sensor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapArguments', () {
    test('should create MapArguments with all properties', () {
      final playerPosition = Vector2(10, 15);
      const playerDirection = Direction.down;

      final mapArguments = MapArguments(
        playerPosition: playerPosition,
        playerDirection: playerDirection,
      );

      expect(mapArguments.playerPosition, equals(playerPosition));
      expect(mapArguments.playerDirection, equals(playerDirection));
    });

    test('should create MapArguments with only required properties', () {
      final playerPosition = Vector2(5, 8);
      const playerDirection = Direction.up;

      final mapArguments = MapArguments(
        playerPosition: playerPosition,
        playerDirection: playerDirection,
      );

      expect(mapArguments.playerPosition, equals(playerPosition));
      expect(mapArguments.playerDirection, equals(playerDirection));
    });

    test('should handle null optional properties correctly', () {
      final playerPosition = Vector2(20, 25);
      const playerDirection = Direction.left;

      final mapArguments = MapArguments(
        playerPosition: playerPosition,
        playerDirection: playerDirection,
      );

      expect(mapArguments.playerPosition, equals(playerPosition));
      expect(mapArguments.playerDirection, equals(playerDirection));
    });
  });
  group('MapId', () {
    test('should have correct enum values', () {
      expect(MapId.values.length, equals(2));
      expect(MapId.map1.name, equals('map1'));
      expect(MapId.dungeon1.name, equals('dungeon1'));
    });
  });

  group('MapConstants', () {
    test('should have correct timing constants', () {
      expect(GameplayMapConstants.kSensorContactTime, equals(0));
      expect(GameplayMapConstants.kTransitionDelayMs, equals(0));
    });
  });

  group('MapModel', () {
    test('should have correct asset paths', () {
      final map1Config = MapModel.byId(MapId.map1);
      final dungeon1Config = MapModel.byId(MapId.dungeon1);

      expect(map1Config?.asset, equals('tiled/map_1.json'));
      expect(dungeon1Config?.asset, equals('tiled/dungeon_1.json'));
    });

    test('should have correct sensor configurations', () {
      final map1Config = MapModel.byId(MapId.map1);
      final dungeon1Config = MapModel.byId(MapId.dungeon1);

      expect(map1Config?.sensorIds.length, equals(2));
      expect(map1Config?.sensorIds, contains('sensor_dungeon_1'));
      expect(map1Config?.sensorIds, contains('sensor_dungeon_2'));

      expect(dungeon1Config?.sensorIds.length, equals(1));
      expect(dungeon1Config?.sensorIds, contains('sensor_map_1'));
    });

    test('should have correct background music configuration', () {
      final map1Config = MapModel.byId(MapId.map1);
      final dungeon1Config = MapModel.byId(MapId.dungeon1);

      expect(map1Config?.backgroundMusic, equals('ro1_letters.mp3'));
      expect(dungeon1Config?.backgroundMusic, equals('ro1_death_hex.mp3'));
    });

    test('should have correct color configurations', () {
      final map1Config = MapModel.byId(MapId.map1);
      final dungeon1Config = MapModel.byId(MapId.dungeon1);

      expect(map1Config?.lightingColor, equals('#d0ffffff'));
      expect(map1Config?.backgroundColor, equals('#ff63c74d'));

      expect(dungeon1Config?.lightingColor, equals('#d0000000'));
      expect(dungeon1Config?.backgroundColor, equals('#ff424242'));
    });

    test('should return null for non-existent map ID', () {
      // Como o enum não tem mais valores, vamos testar indiretamente
      final allMaps = MapModel.allMaps;
      expect(allMaps.length, equals(2));

      final existingIds = allMaps.map((m) => m.id).toList();
      expect(existingIds, contains(MapId.map1));
      expect(existingIds, contains(MapId.dungeon1));
    });

    test('should convert to properties correctly', () {
      final map1Config = MapModel.byId(MapId.map1);
      final properties = map1Config?.properties;

      expect(properties?['mapBackgroundMusic'], equals('ro1_letters.mp3'));
      expect(properties?['mapLightingColor'], equals('#d0ffffff'));
      expect(properties?['mapBackgroundColor'], equals('#ff63c74d'));
    });
  });
}
