import 'package:dawnforge/game/systems/map/map_data.dart';
import 'package:dawnforge/game/systems/map/map_def.dart';
import 'package:dawnforge/game/systems/map/map_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Invariantes do registro de mapas.
///
/// Substitui `test/gameplay/core/managers/gameplay_map_manager_test.dart`, que
/// afirmava a existência de `lake_1` e `dungeon_1` — mapas removidos há várias
/// versões. Aqui só asseguramos o que precisa ser verdade para **qualquer**
/// conjunto de mapas, para o teste não voltar a apodrecer quando o conteúdo
/// mudar.
void main() {
  group('MapDef.kAllMaps', () {
    test('at least one map is registered', () {
      expect(MapDef.kAllMaps, isNotEmpty);
    });

    test('every map has a non-empty id', () {
      for (final map in MapDef.kAllMaps) {
        expect(map.id.trim(), isNotEmpty);
      }
    });

    test('map ids are unique', () {
      final ids = MapDef.kAllMaps.map((map) => map.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('every map points at a .json Tiled asset', () {
      for (final map in MapDef.kAllMaps) {
        expect(map.asset, endsWith('.json'), reason: map.id);
      }
    });

    test('every asset path embeds its own map id', () {
      for (final map in MapDef.kAllMaps) {
        expect(
          map.asset,
          contains(map.id),
          reason: '${map.id} loads ${map.asset} — likely a copy/paste slip',
        );
      }
    });

    test('asset paths are unique', () {
      final assets = MapDef.kAllMaps.map((map) => map.asset).toList();

      expect(assets.toSet().length, assets.length);
    });

    test('every map declares background music, lighting and background', () {
      for (final map in MapDef.kAllMaps) {
        expect(map.backgroundMusic.trim(), isNotEmpty, reason: map.id);
        expect(map.lightingColor.trim(), isNotEmpty, reason: map.id);
        expect(map.backgroundColor.trim(), isNotEmpty, reason: map.id);
      }
    });

    test('an initial player position, when set, is an "x,y" pair', () {
      for (final map in MapDef.kAllMaps) {
        final position = map.initialPlayerPosition;
        if (position == null) continue;

        final parts = position.split(',');
        expect(parts.length, 2, reason: '${map.id} → "$position"');
        for (final part in parts) {
          expect(double.tryParse(part), isNotNull, reason: map.id);
        }
      }
    });

    test('a sensor id names the map it leads to', () {
      final knownIds = MapDef.kAllMaps.map((map) => map.id).toSet();

      for (final map in MapDef.kAllMaps) {
        for (final sensorId in map.sensorIds) {
          final target = sensorId.replaceFirst('sensor_', '');

          expect(
            knownIds,
            contains(target),
            reason:
                '${map.id} has sensor "$sensorId" pointing at "$target", '
                'which is not a registered map',
          );
        }
      }
    });
  });

  group('MapData.properties', () {
    test('carries music, lighting and background colour', () {
      const map = MapData(
        id: 'test_map',
        asset: 'tiled/maps/test_map.json',
        sensorIds: [],
        backgroundMusic: 'music.ogg',
        lightingColor: '#000000',
        backgroundColor: '#FFFFFF',
      );

      expect(map.properties[MapDef.kBackgroundMusicPropertyKey], 'music.ogg');
      expect(map.properties[MapDef.kLightingColorPropertyKey], '#000000');
      expect(map.properties[MapDef.kBackgroundColorPropertyKey], '#FFFFFF');
    });

    test('omits the initial position when it is not set', () {
      const map = MapData(
        id: 'test_map',
        asset: 'tiled/maps/test_map.json',
        sensorIds: [],
        backgroundMusic: 'music.ogg',
        lightingColor: '#000000',
        backgroundColor: '#FFFFFF',
      );

      expect(
        map.properties.containsKey(MapDef.kInitialPlayerPositionPropertyKey),
        isFalse,
      );
    });

    test('includes the initial position when it is set', () {
      const map = MapData(
        id: 'test_map',
        asset: 'tiled/maps/test_map.json',
        sensorIds: [],
        backgroundMusic: 'music.ogg',
        lightingColor: '#000000',
        backgroundColor: '#FFFFFF',
        initialPlayerPosition: '4,4',
      );

      expect(map.properties[MapDef.kInitialPlayerPositionPropertyKey], '4,4');
    });
  });

  group('MapManager.allMaps', () {
    test('exposes a builder for every registered map', () {
      expect(
        MapManager.allMaps.keys.toSet(),
        MapDef.kAllMaps.map((map) => map.id).toSet(),
      );
    });

    test('is not empty', () {
      expect(MapManager.allMaps, isNotEmpty);
    });
  });
}
