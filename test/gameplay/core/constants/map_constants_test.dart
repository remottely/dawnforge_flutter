import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_transition_sensor.dart';
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

  group('GameplayMapConfig', () {
    test('should have correct property keys', () {
      expect(GameplayMapConfig.kNextMapPropertyKey, equals('nextMap'));
      expect(
        GameplayMapConfig.kPlayerPositionPropertyKey,
        equals('playerPosition'),
      );
      expect(
        GameplayMapConfig.kPlayerDirectionPropertyKey,
        equals('playerDirection'),
      );
    });
  });
}
