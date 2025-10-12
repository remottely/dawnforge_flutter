import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/map_constants.dart';
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
