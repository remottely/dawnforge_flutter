import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_builders.dart';

void main() {
  group('GridTile', () {
    group('occupancy', () {
      test('no object → empty', () {
        const tile = GridTile(x: 0, y: 0);

        expect(tile.isEmpty, isTrue);
        expect(tile.isOccupied, isFalse);
      });

      test('with an object → occupied', () {
        final tile = aFarmTile();

        expect(tile.isEmpty, isFalse);
        expect(tile.isOccupied, isTrue);
      });
    });

    group('delegated object properties', () {
      test('empty tile blocks nothing and is not interactable', () {
        const tile = GridTile(x: 0, y: 0);

        expect(tile.blocksMovement, isFalse);
        expect(tile.isInteractable, isFalse);
      });

      test('farm object makes the tile interactable but passable', () {
        final tile = aFarmTile();

        expect(tile.blocksMovement, isFalse);
        expect(tile.isInteractable, isTrue);
      });
    });

    group('placeObject', () {
      test('puts the object on the tile', () {
        const tile = GridTile(x: 2, y: 3);

        final placed = tile.placeObject(aFarmObject());

        expect(placed.object, isNotNull);
        expect(placed.x, 2);
        expect(placed.y, 3);
      });

      test('replaces whatever was there before', () {
        final tile = aFarmTile(soilState: SoilState.untilled);

        final replaced = tile.placeObject(
          aFarmObject(soilState: SoilState.watered),
        );

        expect((replaced.object! as FarmObject).soilState, SoilState.watered);
      });
    });

    // COMPORTAMENTO ATUAL, INCORRETO — ver refactoring/03-fase-3 §3.7.
    // `copyWith` usa `object ?? this.object`, então é impossível voltar o
    // campo para null. `removeObject()` não remove nada. Ao corrigir, estes
    // testes passam a esperar `isNull` / `isEmpty`.
    group('removeObject (broken — copyWith cannot set null)', () {
      test('does NOT remove the object', () {
        final tile = aFarmTile();

        expect(tile.removeObject().object, isNotNull);
      });

      test('does NOT clear the metadata either', () {
        final tile = aFarmTile(metadata: {'lastTilledDay': 2});

        expect(tile.removeObject().metadata, isNotNull);
      });
    });

    group('metadata', () {
      test('setMetadata on a tile without metadata creates the map', () {
        const tile = GridTile(x: 0, y: 0);

        final updated = tile.setMetadata('lastTilledDay', 3);

        expect(updated.getMetadata<int>('lastTilledDay'), 3);
      });

      test('setMetadata preserves the existing keys', () {
        final tile = const GridTile(
          x: 0,
          y: 0,
        ).setMetadata('a', 1).setMetadata('b', 2);

        expect(tile.getMetadata<int>('a'), 1);
        expect(tile.getMetadata<int>('b'), 2);
      });

      test('setMetadata overwrites an existing key', () {
        final tile = const GridTile(
          x: 0,
          y: 0,
        ).setMetadata('a', 1).setMetadata('a', 9);

        expect(tile.getMetadata<int>('a'), 9);
      });

      test('getMetadata on a missing key → null', () {
        const tile = GridTile(x: 0, y: 0);

        expect(tile.getMetadata<int>('nope'), isNull);
      });

      test('removeMetadata drops the key', () {
        final tile = const GridTile(
          x: 0,
          y: 0,
        ).setMetadata('a', 1).setMetadata('b', 2);

        final updated = tile.removeMetadata('a');

        expect(updated.getMetadata<int>('a'), isNull);
        expect(updated.getMetadata<int>('b'), 2);
      });

      test('removeMetadata on a tile without metadata → same instance', () {
        const tile = GridTile(x: 0, y: 0);

        expect(tile.removeMetadata('a'), same(tile));
      });

      // COMPORTAMENTO ATUAL, INCORRETO — mesma causa do `removeObject` acima.
      // `removeMetadata` calcula `newMetadata.isEmpty ? null : newMetadata`,
      // mas o `copyWith` descarta o null e devolve o mapa antigo intacto:
      // remover a última chave não remove nada. Ao corrigir (Fase 3.7), este
      // teste passa a esperar `isNull`.
      test('removing the LAST key does not clear metadata (copyWith null)', () {
        final tile = const GridTile(x: 0, y: 0).setMetadata('only', 1);

        expect(tile.removeMetadata('only').getMetadata<int>('only'), 1);
      });

      test('setMetadata does not mutate the original tile', () {
        final original = const GridTile(x: 0, y: 0).setMetadata('a', 1);

        original.setMetadata('b', 2);

        expect(original.getMetadata<int>('b'), isNull);
      });
    });

    group('serialization', () {
      test('round-trips coordinates, object and metadata', () {
        final tile = aFarmTile(
          x: 4,
          y: 7,
          soilState: SoilState.watered,
          lastWateredDay: 2,
          metadata: {'lastTilledDay': 1},
        );

        final restored = GridTile.fromJson(
          tile.toJson(),
          (json) => json == null ? null : FarmObject.fromJson(json),
        );

        expect(restored, tile);
      });

      test('an empty tile round-trips with a null object', () {
        const tile = GridTile(x: 1, y: 1);

        final restored = GridTile.fromJson(
          tile.toJson(),
          (json) => json == null ? null : FarmObject.fromJson(json),
        );

        expect(restored.object, isNull);
        expect(restored, tile);
      });
    });

    group('equality', () {
      test('same coordinates and contents → equal', () {
        expect(aFarmTile(x: 1, y: 2), aFarmTile(x: 1, y: 2));
      });

      test('different coordinates → not equal', () {
        expect(aFarmTile(x: 1, y: 2), isNot(aFarmTile(x: 2, y: 1)));
      });

      test('different object state → not equal', () {
        expect(
          aFarmTile(soilState: SoilState.tilled),
          isNot(aFarmTile(soilState: SoilState.watered)),
        );
      });
    });
  });

  group('TileObjectType', () {
    test('every value round-trips', () {
      for (final type in TileObjectType.values) {
        expect(TileObjectType.fromJson(type.toJson()), type);
      }
    });

    test('unknown value → unknown instead of throwing', () {
      expect(TileObjectType.fromJson('spaceship'), TileObjectType.unknown);
    });
  });

  group('CropRegrowData', () {
    test('resetState clears the transient regrow progress', () {
      const data = CropRegrowData(
        isRegrow: true,
        regrowStageRollback: 2,
        regrowStepDays: 3,
        isRegrowing: true,
        daysInStage: 5,
      );

      final reset = data.resetState();

      expect(reset.isRegrowing, isFalse);
      expect(reset.daysInStage, 0);
    });

    test('resetState keeps the rules intact', () {
      const data = CropRegrowData(
        isRegrow: true,
        regrowStageRollback: 2,
        regrowStepDays: 3,
        isRegrowing: true,
        daysInStage: 5,
      );

      final reset = data.resetState();

      expect(reset.isRegrow, isTrue);
      expect(reset.regrowStageRollback, 2);
      expect(reset.regrowStepDays, 3);
    });

    test('round-trips through JSON', () {
      const data = CropRegrowData(
        isRegrow: true,
        regrowStageRollback: 1,
        regrowStepDays: 2,
        isRegrowing: false,
        daysInStage: 3,
      );

      expect(CropRegrowData.fromJson(data.toJson()), data);
    });
  });
}
