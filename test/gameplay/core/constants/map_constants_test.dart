import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/map_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapArguments', () {
    test('should create MapArguments with all properties', () {
      final playerPosition = Vector2(10, 15);
      const playerDirection = Direction.down;
      const backgroundMusic = 'dungeon_ambient.ogg';
      const lightingColor = Color(0xFF000066);
      const backgroundColor = Color(0xFF1A1A2E);

      final mapArguments = MapArguments(
        playerPosition: playerPosition,
        playerDirection: playerDirection,
        backgroundMusic: backgroundMusic,
        lightingColor: lightingColor,
        backgroundColor: backgroundColor,
      );

      expect(mapArguments.playerPosition, equals(playerPosition));
      expect(mapArguments.playerDirection, equals(playerDirection));
      expect(mapArguments.backgroundMusic, equals(backgroundMusic));
      expect(mapArguments.lightingColor, equals(lightingColor));
      expect(mapArguments.backgroundColor, equals(backgroundColor));
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
      expect(mapArguments.backgroundMusic, isNull);
      expect(mapArguments.lightingColor, isNull);
      expect(mapArguments.backgroundColor, isNull);
    });

    test('should handle null optional properties correctly', () {
      final playerPosition = Vector2(20, 25);
      const playerDirection = Direction.left;

      final mapArguments = MapArguments(
        playerPosition: playerPosition,
        playerDirection: playerDirection,
        backgroundMusic: null,
        lightingColor: null,
        backgroundColor: null,
      );

      expect(mapArguments.playerPosition, equals(playerPosition));
      expect(mapArguments.playerDirection, equals(playerDirection));
      expect(mapArguments.backgroundMusic, isNull);
      expect(mapArguments.lightingColor, isNull);
      expect(mapArguments.backgroundColor, isNull);
    });

    test('should work with realistic game colors', () {
      // Dungeon colors
      const dungeonLighting = Color(0xFF000033); // Dark blue
      const dungeonBackground = Color(0xFF0A0A0A); // Almost black

      // Forest colors
      const forestLighting = Color(0xFF003300); // Dark green
      const forestBackground = Color(0xFF1A2A1A); // Moss green

      // Lava cave colors
      const lavaLighting = Color(0xFF330000); // Dark red
      const lavaBackground = Color(0xFF2A1A1A); // Reddish brown

      final dungeonArgs = MapArguments(
        playerPosition: Vector2(10, 10),
        playerDirection: Direction.down,
        lightingColor: dungeonLighting,
        backgroundColor: dungeonBackground,
      );

      final forestArgs = MapArguments(
        playerPosition: Vector2(15, 20),
        playerDirection: Direction.right,
        lightingColor: forestLighting,
        backgroundColor: forestBackground,
      );

      final lavaArgs = MapArguments(
        playerPosition: Vector2(5, 25),
        playerDirection: Direction.left,
        lightingColor: lavaLighting,
        backgroundColor: lavaBackground,
      );

      // Verify dungeon colors
      expect(dungeonArgs.lightingColor, equals(dungeonLighting));
      expect(dungeonArgs.backgroundColor, equals(dungeonBackground));

      // Verify forest colors
      expect(forestArgs.lightingColor, equals(forestLighting));
      expect(forestArgs.backgroundColor, equals(forestBackground));

      // Verify lava colors
      expect(lavaArgs.lightingColor, equals(lavaLighting));
      expect(lavaArgs.backgroundColor, equals(lavaBackground));
    });
  });
  group('MapBiomeId', () {
    test('should have correct enum values', () {
      expect(MapBiomeId.values.length, equals(3));
      expect(MapBiomeId.none.name, equals('none'));
      expect(MapBiomeId.map1.name, equals('map1'));
      expect(MapBiomeId.dungeon1.name, equals('dungeon1'));
    });
  });

  group('MapConstants', () {
    test('should have correct asset paths', () {
      expect(MapConstants.kMap1Asset, equals('tiled/map_1.json'));
      expect(MapConstants.kDungeon1Asset, equals('tiled/dungeon_1.json'));
    });

    test('should have correct timing constants', () {
      expect(MapConstants.kSensorContactTime, equals(0.5));
      expect(MapConstants.kTransitionDelayMs, equals(100));
    });

    test('should have correct sensor configurations', () {
      expect(MapConstants.kMap1SensorIds.length, equals(2));
      expect(MapConstants.kMap1SensorIds, contains('sensor_dungeon_1'));
      expect(MapConstants.kMap1SensorIds, contains('sensor_dungeon_2'));

      expect(MapConstants.kDungeon1SensorIds.length, equals(1));
      expect(MapConstants.kDungeon1SensorIds, contains('sensor_map_1'));
    });
  });
}
