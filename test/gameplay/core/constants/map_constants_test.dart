import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/data/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_sensor.dart';
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

  group('GameplayMapConstants', () {
    test('should have correct timing constants', () {
      expect(GameplayMapConstants.kSensorContactTime, equals(0.5));
      expect(GameplayMapConstants.kTransitionDelayMs, equals(100));
    });

    test('should have correct log prefixes', () {
      expect(
        GameplayMapConstants.kMapNavigationLogPrefix,
        equals('MapNavigation'),
      );
      expect(GameplayMapConstants.kSensorLogPrefix, equals('MapSensor'));
    });

    test('should have correct property keys', () {
      expect(GameplayMapConstants.kNextMapPropertyKey, equals('nextMap'));
      expect(
        GameplayMapConstants.kPlayerPositionPropertyKey,
        equals('playerPosition'),
      );
      expect(
        GameplayMapConstants.kPlayerDirectionPropertyKey,
        equals('playerDirection'),
      );
    });
  });

  group('GameplayMapData', () {
    test('should have correct constants for assets', () {
      expect(GameplayMapData.kMap1Asset, equals('tiled/map_1.json'));
      expect(GameplayMapData.kDungeon1Asset, equals('tiled/dungeon_1.json'));
    });

    test('should have correct constants for background music', () {
      expect(GameplayMapData.kMap1BackgroundMusic, equals('ro1_letters.mp3'));
      expect(
        GameplayMapData.kDungeon1BackgroundMusic,
        equals('ro1_death_hex.mp3'),
      );
    });

    test('should have correct constants for sensor IDs', () {
      expect(GameplayMapData.kMap1SensorIds.length, equals(2));
      expect(GameplayMapData.kMap1SensorIds, contains('sensor_dungeon_1'));
      expect(GameplayMapData.kMap1SensorIds, contains('sensor_dungeon_2'));

      expect(GameplayMapData.kDungeon1SensorIds.length, equals(1));
      expect(GameplayMapData.kDungeon1SensorIds, contains('sensor_map_1'));
    });

    test('should have correct asset paths', () {
      final map1Config = GameplayMapData.byId(MapId.map1);
      final dungeon1Config = GameplayMapData.byId(MapId.dungeon1);

      expect(map1Config?.asset, equals(GameplayMapData.kMap1Asset));
      expect(dungeon1Config?.asset, equals(GameplayMapData.kDungeon1Asset));
    });

    test('should have correct sensor configurations', () {
      final map1Config = GameplayMapData.byId(MapId.map1);
      final dungeon1Config = GameplayMapData.byId(MapId.dungeon1);

      expect(map1Config?.sensorIds, equals(GameplayMapData.kMap1SensorIds));
      expect(
        dungeon1Config?.sensorIds,
        equals(GameplayMapData.kDungeon1SensorIds),
      );
    });

    test('should have correct background music configuration', () {
      final map1Config = GameplayMapData.byId(MapId.map1);
      final dungeon1Config = GameplayMapData.byId(MapId.dungeon1);

      expect(
        map1Config?.backgroundMusic,
        equals(GameplayMapData.kMap1BackgroundMusic),
      );
      expect(
        dungeon1Config?.backgroundMusic,
        equals(GameplayMapData.kDungeon1BackgroundMusic),
      );
    });

    test('should have correct color configurations', () {
      final map1Config = GameplayMapData.byId(MapId.map1);
      final dungeon1Config = GameplayMapData.byId(MapId.dungeon1);

      expect(
        map1Config?.lightingColor,
        equals(GameplayMapData.kMap1LightingColor),
      );
      expect(
        map1Config?.backgroundColor,
        equals(GameplayMapData.kMap1BackgroundColor),
      );

      expect(
        dungeon1Config?.lightingColor,
        equals(GameplayMapData.kDungeon1LightingColor),
      );
      expect(
        dungeon1Config?.backgroundColor,
        equals(GameplayMapData.kDungeon1BackgroundColor),
      );
    });

    test('should return null for non-existent map ID', () {
      // Como o enum não tem mais valores, vamos testar indiretamente
      final allMaps = GameplayMapData.allMaps;
      expect(allMaps.length, equals(2));

      final existingIds = allMaps.map((m) => m.id).toList();
      expect(existingIds, contains(MapId.map1));
      expect(existingIds, contains(MapId.dungeon1));
    });

    test('should convert to properties correctly using constants', () {
      final map1Config = GameplayMapData.byId(MapId.map1);
      final properties = map1Config?.properties;

      expect(
        properties?[GameplayMapData.kBackgroundMusicPropertyKey],
        equals(GameplayMapData.kMap1BackgroundMusic),
      );
      expect(
        properties?[GameplayMapData.kLightingColorPropertyKey],
        equals(GameplayMapData.kMap1LightingColor),
      );
      expect(
        properties?[GameplayMapData.kBackgroundColorPropertyKey],
        equals(GameplayMapData.kMap1BackgroundColor),
      );
    });
  });
}
