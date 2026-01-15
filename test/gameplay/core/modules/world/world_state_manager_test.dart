import 'package:flutter_test/flutter_test.dart';
import 'package:dawnforge/game/core/modules/world/world_state_manager.dart';
import 'package:dawnforge/game/core/modules/world/map_state_model.dart';
import 'package:dawnforge/game/core/modules/world/season.dart';

void main() {
  late WorldStateManager manager;

  setUp(() {
    // Get singleton instance and reset before each test
    manager = WorldStateManager.instance;
    manager.reset();
  });

  group('WorldStateManager Tests', () {
    test('test_singleton_returns_same_instance', () {
      // Arrange & Act
      final instance1 = WorldStateManager.instance;
      final instance2 = WorldStateManager.instance;

      // Assert
      expect(instance1, equals(instance2));
      expect(identical(instance1, instance2), isTrue);
    });

    test('test_advance_day_increments_correctly', () {
      // Arrange
      expect(manager.currentDay, equals(1));

      // Act
      manager.advanceDay();

      // Assert
      expect(manager.currentDay, equals(2));

      // Act again
      manager.advanceDay();
      manager.advanceDay();

      // Assert
      expect(manager.currentDay, equals(4));
    });

    test('test_season_changes_every_28_days', () {
      // Test Spring (days 1-28)
      for (int day = 1; day <= 28; day++) {
        expect(
          manager.getSeasonForDay(day),
          equals(Season.spring),
          reason: 'Day $day should be Spring',
        );
      }

      // Test Summer (days 29-56)
      for (int day = 29; day <= 56; day++) {
        expect(
          manager.getSeasonForDay(day),
          equals(Season.summer),
          reason: 'Day $day should be Summer',
        );
      }

      // Test Fall (days 57-84)
      for (int day = 57; day <= 84; day++) {
        expect(
          manager.getSeasonForDay(day),
          equals(Season.fall),
          reason: 'Day $day should be Fall',
        );
      }

      // Test Winter (days 85-112)
      for (int day = 85; day <= 112; day++) {
        expect(
          manager.getSeasonForDay(day),
          equals(Season.winter),
          reason: 'Day $day should be Winter',
        );
      }

      // Test cycle repeats (day 113 should be Spring again)
      expect(
        manager.getSeasonForDay(113),
        equals(Season.spring),
        reason: 'Day 113 should cycle back to Spring',
      );

      // Test real scenario - advance through seasons
      manager.reset();
      expect(manager.currentSeason, equals(Season.spring));

      // Advance 28 days to reach Summer
      for (int i = 0; i < 28; i++) {
        manager.advanceDay();
      }
      expect(manager.currentDay, equals(29));
      expect(manager.currentSeason, equals(Season.summer));

      // Advance 28 more days to reach Fall
      for (int i = 0; i < 28; i++) {
        manager.advanceDay();
      }
      expect(manager.currentDay, equals(57));
      expect(manager.currentSeason, equals(Season.fall));
    });

    test('test_map_state_cache_works', () {
      // Arrange
      final testMapId = 'test_map_1';
      final mapState = MapState(
        decorationsModified: ['decoration_1', 'decoration_2'],
        farmTiles: ['tile_1'],
        enemiesDefeated: ['enemy_boss_1'],
        customData: {'visited': true, 'treasureFound': false},
      );

      // Act - Set map state
      manager.setMapState(testMapId, mapState);

      // Assert - Get map state
      final retrievedState = manager.getMapState(testMapId);
      expect(retrievedState, isNotNull);
      expect(
        retrievedState!.decorationsModified,
        equals(mapState.decorationsModified),
      );
      expect(retrievedState.farmTiles, equals(mapState.farmTiles));
      expect(retrievedState.enemiesDefeated, equals(mapState.enemiesDefeated));
      expect(retrievedState.customData, equals(mapState.customData));

      // Test non-existent map
      expect(manager.getMapState('non_existent_map'), isNull);
    });

    test('test_unload_inactive_maps_removes_old_maps', () {
      // Arrange - Add 3 maps
      manager.setMapState('map_1', MapState());
      manager.setMapState('map_2', MapState());
      manager.setMapState('map_3', MapState());
      expect(manager.activeMapCount, equals(3));

      // Act - Mark one as current and unload inactive
      manager.setCurrentMap('map_2');
      manager.unloadInactiveMaps();

      // Assert - Only current map remains
      expect(manager.activeMapCount, equals(1));
      expect(manager.getMapState('map_1'), isNull);
      expect(manager.getMapState('map_2'), isNotNull);
      expect(manager.getMapState('map_3'), isNull);

      // Test unload all when no current map
      manager.reset();
      manager.setMapState('map_a', MapState());
      manager.setMapState('map_b', MapState());
      expect(manager.activeMapCount, equals(2));

      manager.unloadInactiveMaps();
      expect(manager.activeMapCount, equals(0));
    });

    test('test_serialization_roundtrip', () {
      // Arrange - Setup state
      manager.advanceDay();
      manager.advanceDay();
      manager.advanceDay(); // Day 4
      manager.setCurrentMap('test_map');
      manager.setMapState(
        'test_map',
        MapState(
          decorationsModified: ['decoration_1'],
          farmTiles: ['tile_1', 'tile_2'],
        ),
      );

      // Act - Serialize
      final json = manager.toJson();

      // Reset and deserialize
      manager.reset();
      expect(manager.currentDay, equals(1)); // Verify reset worked

      manager.fromJson(json);

      // Assert - Verify state restored
      expect(manager.currentDay, equals(4));
      expect(manager.currentMapId, equals('test_map'));
      expect(manager.activeMapCount, equals(1));

      final restoredMapState = manager.getMapState('test_map');
      expect(restoredMapState, isNotNull);
      expect(restoredMapState!.decorationsModified, equals(['decoration_1']));
      expect(restoredMapState.farmTiles, equals(['tile_1', 'tile_2']));
    });
  });
}
