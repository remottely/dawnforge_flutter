import 'package:dawnforge/game/systems/world/map_state_model.dart';
import 'package:dawnforge/game/systems/world/season.dart';
import 'package:dawnforge/game/systems/world/world_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/manager_reset.dart';

void main() {
  late WorldStateManager manager;

  setUp(() async {
    await resetAllManagers();
    manager = WorldStateManager.instance;
  });

  group('WorldStateManager', () {
    test('starts on day 1 of spring with no map loaded', () {
      expect(manager.currentDay, 1);
      expect(manager.currentSeason, Season.spring);
      expect(manager.currentMapId, isNull);
      expect(manager.activeMapCount, 0);
    });

    group('advanceDay', () {
      test('increments the day counter', () {
        manager.advanceDay();

        expect(manager.currentDay, 2);
      });

      test('the season holds for the first 28 days', () {
        for (var i = 0; i < 27; i++) {
          manager.advanceDay();
        }

        expect(manager.currentDay, 28);
        expect(manager.currentSeason, Season.spring);
      });

      test('day 29 flips to summer', () {
        for (var i = 0; i < 28; i++) {
          manager.advanceDay();
        }

        expect(manager.currentDay, 29);
        expect(manager.currentSeason, Season.summer);
      });
    });

    group('getSeasonForDay', () {
      test('maps each season to its 28-day block', () {
        expect(manager.getSeasonForDay(1), Season.spring);
        expect(manager.getSeasonForDay(28), Season.spring);
        expect(manager.getSeasonForDay(29), Season.summer);
        expect(manager.getSeasonForDay(56), Season.summer);
        expect(manager.getSeasonForDay(57), Season.fall);
        expect(manager.getSeasonForDay(85), Season.winter);
        expect(manager.getSeasonForDay(112), Season.winter);
      });

      test('wraps into the next year', () {
        expect(manager.getSeasonForDay(113), Season.spring);
      });
    });

    group('map tracking', () {
      test('setCurrentMap records the active map', () {
        manager.setCurrentMap('farm_map');

        expect(manager.currentMapId, 'farm_map');
      });

      test('map state round-trips by id', () {
        const state = MapState(enemiesDefeated: ['goblin_1']);

        manager.setMapState('cave_map', state);

        expect(manager.getMapState('cave_map')!.enemiesDefeated, ['goblin_1']);
      });

      test('an unknown map id → null', () {
        expect(manager.getMapState('nowhere'), isNull);
      });

      test('setting the same id twice replaces the state', () {
        manager
          ..setMapState('cave_map', const MapState(enemiesDefeated: ['a']))
          ..setMapState('cave_map', const MapState(enemiesDefeated: ['b']));

        expect(manager.activeMapCount, 1);
        expect(manager.getMapState('cave_map')!.enemiesDefeated, ['b']);
      });
    });

    group('unloadInactiveMaps', () {
      test('keeps only the current map', () {
        manager
          ..setMapState('farm_map', const MapState())
          ..setMapState('cave_map', const MapState())
          ..setMapState('town_map', const MapState())
          ..setCurrentMap('cave_map')
          ..unloadInactiveMaps();

        expect(manager.activeMapCount, 1);
        expect(manager.getMapState('cave_map'), isNotNull);
        expect(manager.getMapState('farm_map'), isNull);
      });

      test('with no current map, everything is dropped', () {
        manager
          ..setMapState('farm_map', const MapState())
          ..setMapState('cave_map', const MapState())
          ..unloadInactiveMaps();

        expect(manager.activeMapCount, 0);
      });

      test('with nothing cached it is harmless', () {
        manager.setCurrentMap('farm_map');

        expect(manager.unloadInactiveMaps, returnsNormally);
      });
    });

    group('serialization', () {
      test('round-trips the calendar and the active map', () {
        manager
          ..advanceDay()
          ..advanceDay()
          ..setCurrentMap('farm_map')
          ..setMapState('farm_map', const MapState(farmTiles: ['0,0']));

        final json = manager.toJson();
        manager.reset();
        manager.fromJson(json);

        expect(manager.currentDay, 3);
        expect(manager.currentMapId, 'farm_map');
        expect(manager.getMapState('farm_map')!.farmTiles, ['0,0']);
      });

      test('a season survives the round-trip', () {
        for (var i = 0; i < 30; i++) {
          manager.advanceDay();
        }
        final json = manager.toJson();
        manager.reset();

        manager.fromJson(json);

        expect(manager.currentSeason, Season.summer);
      });

      test('an empty payload falls back to the initial state', () {
        manager.advanceDay();

        manager.fromJson(<String, dynamic>{});

        expect(manager.currentDay, 1);
        expect(manager.currentSeason, Season.spring);
        expect(manager.currentMapId, isNull);
      });

      test('loading clears previously cached maps', () {
        manager.setMapState('stale_map', const MapState());

        manager.fromJson(<String, dynamic>{'currentDay': 5});

        expect(manager.getMapState('stale_map'), isNull);
      });
    });

    group('reset', () {
      test('returns everything to the initial state', () {
        manager
          ..advanceDay()
          ..setCurrentMap('farm_map')
          ..setMapState('farm_map', const MapState())
          ..reset();

        expect(manager.currentDay, 1);
        expect(manager.currentSeason, Season.spring);
        expect(manager.currentMapId, isNull);
        expect(manager.activeMapCount, 0);
      });
    });
  });

  group('Season', () {
    test('every value round-trips', () {
      for (final season in Season.values) {
        expect(Season.fromJson(season.toJson()), season);
      }
    });

    test('unknown value → throws', () {
      expect(() => Season.fromJson('monsoon'), throwsArgumentError);
    });

    test('every value exposes a display name', () {
      for (final season in Season.values) {
        expect(season.displayName, isNotEmpty);
      }
    });

    // Ver refactoring/03-fase-3 §3.4: existem DUAS enums de estação no
    // projeto. Esta (`Season`, em systems/world) não tem `any`/`unknown`;
    // `SeasonType` (em features/inventory) tem. Os nomes das 4 estações
    // coincidem, o que é o que torna a unificação viável sem migrar save.
    test('the four calendar names match SeasonType, enabling the merge', () {
      expect(Season.values.map((s) => s.name).toList(), [
        'spring',
        'summer',
        'fall',
        'winter',
      ]);
    });
  });

  group('MapState', () {
    test('defaults to empty collections', () {
      const state = MapState();

      expect(state.decorationsModified, isEmpty);
      expect(state.farmTiles, isEmpty);
      expect(state.enemiesDefeated, isEmpty);
      expect(state.customData, isEmpty);
    });

    test('round-trips through JSON', () {
      const state = MapState(
        decorationsModified: ['chest_1'],
        farmTiles: ['0,0', '1,1'],
        enemiesDefeated: ['goblin_1'],
        customData: {'visited': true},
      );

      final restored = MapState.fromJson(state.toJson());

      expect(restored.decorationsModified, state.decorationsModified);
      expect(restored.farmTiles, state.farmTiles);
      expect(restored.enemiesDefeated, state.enemiesDefeated);
      expect(restored.customData, state.customData);
    });

    test('missing fields fall back to empty collections', () {
      final restored = MapState.fromJson(<String, dynamic>{});

      expect(restored.decorationsModified, isEmpty);
      expect(restored.customData, isEmpty);
    });

    test('copyWith replaces only what is given', () {
      const state = MapState(farmTiles: ['0,0']);

      final updated = state.copyWith(enemiesDefeated: ['goblin_1']);

      expect(updated.farmTiles, ['0,0']);
      expect(updated.enemiesDefeated, ['goblin_1']);
    });
  });
}
