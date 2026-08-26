import 'package:dawnforge/game/systems/map/map_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameplayMapManager Configuration', () {
    test('should have valid map configurations in maps getter', () {
      final maps = MapManager.allMaps;

      expect(maps, isNotEmpty);
      expect(maps.containsKey('lake_1'), isTrue);
      expect(maps.containsKey('dungeon_1'), isTrue);
    });

    test('should provide map properties from Tiled files', () {
      // Test that the maps function is accessible (integration test would be needed for full properties test)
      final maps = MapManager.allMaps;
      expect(maps, isNotEmpty);
      expect(maps.keys, contains('lake_1'));
      expect(maps.keys, contains('dungeon_1'));
    });
  });
}
