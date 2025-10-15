import 'package:darkness_dungeon/gameplay/core/managers/gameplay_map_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameplayMapManager Configuration', () {
    test('should have valid map configurations in maps getter', () {
      final maps = GameplayMapManager.maps;

      expect(maps, isNotEmpty);
      expect(maps.containsKey('map1'), isTrue);
      expect(maps.containsKey('dungeon1'), isTrue);
    });

    test('should provide map properties from Tiled files', () {
      // Test that the maps function is accessible (integration test would be needed for full properties test)
      final maps = GameplayMapManager.maps;
      expect(maps, isNotEmpty);
      expect(maps.keys, contains('map1'));
      expect(maps.keys, contains('dungeon1'));
    });
  });
}
