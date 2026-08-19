import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_builders.dart';

void main() {
  group('FarmObject', () {
    group('TileObject contract', () {
      test('type is farm and movement is never blocked', () {
        final object = aFarmObject();

        expect(object.type, TileObjectType.farm);
        expect(object.blocksMovement, isFalse);
        expect(object.isInteractable, isTrue);
      });

      test('name falls back to the soil state when there is no crop', () {
        expect(
          aFarmObject(soilState: SoilState.tilled).name,
          SoilState.tilled.displayName,
        );
      });

      test('name is the crop name once something is planted', () {
        final object = aFarmObject(crop: aCrop(name: 'Radish'));

        expect(object.name, 'Radish');
      });

      test('visualData carries the soil state and omits an absent crop', () {
        final empty = aFarmObject(soilState: SoilState.tilled);

        expect(empty.visualData['soilState'], 'tilled');
        expect(empty.visualData.containsKey('crop'), isFalse);
      });
    });

    group('till', () {
      test('untilled → tilled', () {
        expect(aFarmObject().till().soilState, SoilState.tilled);
      });

      test('does not disturb a planted crop', () {
        final crop = aCrop();

        expect(aFarmObject(crop: crop).till().crop, crop);
      });
    });

    group('water', () {
      test('sets watered and records the day', () {
        final watered = aFarmObject(soilState: SoilState.tilled).water(5);

        expect(watered.soilState, SoilState.watered);
        expect(watered.lastWateredDay, 5);
      });
    });

    group('needsWatering', () {
      test('never watered and merely tilled → true', () {
        expect(
          aFarmObject(soilState: SoilState.tilled).needsWatering(1),
          isTrue,
        );
      });

      test('never watered and untilled → false', () {
        expect(aFarmObject().needsWatering(1), isFalse);
      });

      test('watered today → false', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 3,
        );

        expect(object.needsWatering(3), isFalse);
      });

      test('watered on a previous day → true', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 3,
        );

        expect(object.needsWatering(4), isTrue);
      });
    });

    group('plant', () {
      test('tilled and empty → crop is planted', () {
        final object = aFarmObject(soilState: SoilState.tilled);

        expect(object.plant(aCrop()).crop, isNotNull);
      });

      test('watered and empty → crop is planted', () {
        final object = aFarmObject(soilState: SoilState.watered);

        expect(object.plant(aCrop()).crop, isNotNull);
      });

      test('untilled → rejected, object unchanged', () {
        final object = aFarmObject();

        expect(object.plant(aCrop()), same(object));
      });

      test('already occupied → rejected', () {
        final object = aFarmObject(
          soilState: SoilState.tilled,
          crop: aCrop(name: 'First'),
        );

        expect(object.plant(aCrop(name: 'Second')).crop!.name, 'First');
      });
    });

    group('plantTree', () {
      test('untilled and empty → tree is planted', () {
        expect(aFarmObject().plantTree(aTree()).crop, isNotNull);
      });

      test('tilled soil → rejected (trees need raw soil)', () {
        final object = aFarmObject(soilState: SoilState.tilled);

        expect(object.plantTree(aTree()), same(object));
      });
    });

    group('canPlantCrop / canPlantTree / canHarvest', () {
      test('canPlantCrop requires empty tile AND prepared soil', () {
        expect(aFarmObject(soilState: SoilState.tilled).canPlantCrop, isTrue);
        expect(aFarmObject().canPlantCrop, isFalse);
        expect(
          aFarmObject(soilState: SoilState.tilled, crop: aCrop()).canPlantCrop,
          isFalse,
        );
      });

      test('canPlantTree requires empty tile AND untilled soil', () {
        expect(aFarmObject().canPlantTree, isTrue);
        expect(aFarmObject(crop: aTree()).canPlantTree, isFalse);
      });

      test('canHarvest requires a crop at the harvestable stage', () {
        expect(aFarmObject().canHarvest, isFalse);
        expect(aFarmObject(crop: aCrop()).canHarvest, isFalse);
        expect(
          aFarmObject(crop: aCrop(stage: CropStageType.harvestable)).canHarvest,
          isTrue,
        );
      });
    });

    group('harvest', () {
      test('crop not ready → object unchanged', () {
        final object = aFarmObject(
          soilState: SoilState.tilled,
          crop: aCrop(stage: CropStageType.flowering),
        );

        expect(object.harvest(), same(object));
      });

      test('non-regrowing crop → tile is emptied', () {
        final object = aFarmObject(
          soilState: SoilState.tilled,
          crop: aCrop(stage: CropStageType.harvestable),
        );

        final harvested = object.harvest();

        expect(harvested.crop, isNull);
        expect(harvested.isEmpty, isTrue);
      });

      test('soil state survives the harvest', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 2,
          crop: aCrop(stage: CropStageType.harvestable),
        );

        final harvested = object.harvest();

        expect(harvested.soilState, SoilState.watered);
        expect(harvested.lastWateredDay, 2);
      });

      test('regrowing crop → stays on the tile, rolled back', () {
        final object = aFarmObject(
          soilState: SoilState.tilled,
          crop: aRegrowingCrop(
            stage: CropStageType.harvestable,
            regrowStageRollback: 2,
          ),
        );

        final harvested = object.harvest();

        expect(harvested.crop, isNotNull);
        expect(harvested.crop!.stage, CropStageType.flowering);
        expect(harvested.crop!.regrowData.isRegrowing, isTrue);
      });
    });

    group('advanceDay', () {
      test('crop watered on the ending day → grows', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 3,
          crop: aCrop(stage: CropStageType.planted, daysToMature: 6),
        );

        final advanced = object.advanceDay(3);

        expect(advanced.crop!.stage, CropStageType.sprout);
      });

      test('growing consumes the water — soil returns to tilled', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 3,
          crop: aCrop(),
        );

        final advanced = object.advanceDay(3);

        expect(advanced.soilState, SoilState.tilled);
      });

      // COMPORTAMENTO ATUAL, INCORRETO — ver refactoring/03-fase-3 §3.7.
      // `advanceDay` passa `lastWateredDay: null` para o `copyWith`, mas o
      // `copyWith` usa `lastWateredDay ?? this.lastWateredDay` e o null é
      // ignorado: o campo fica com o dia antigo, mentindo sobre o estado.
      // Não quebra o jogo hoje porque `wasWateredThatDay` compara com o dia
      // que terminou, mas o dado está errado. Ao corrigir, troque para
      // `expect(advanced.lastWateredDay, isNull)`.
      test(
        'growing does NOT clear lastWateredDay (copyWith cannot set null)',
        () {
          final object = aFarmObject(
            soilState: SoilState.watered,
            lastWateredDay: 3,
            crop: aCrop(),
          );

          final advanced = object.advanceDay(3);

          expect(advanced.lastWateredDay, 3);
        },
      );

      test('a stale lastWateredDay does not let the crop grow twice', () {
        var object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 3,
          crop: aCrop(stage: CropStageType.planted, daysToMature: 6),
        );

        object = object.advanceDay(3);
        final stageAfterFirstDay = object.crop!.stage;

        object = object.advanceDay(4);

        expect(object.crop!.stage, stageAfterFirstDay);
      });

      test('not watered → nothing changes at all', () {
        final object = aFarmObject(
          soilState: SoilState.tilled,
          crop: aCrop(stage: CropStageType.planted),
        );

        expect(object.advanceDay(3), same(object));
      });

      test('watered on an earlier day → crop does not grow', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 1,
          crop: aCrop(stage: CropStageType.planted),
        );

        final advanced = object.advanceDay(3);

        expect(advanced.crop!.stage, CropStageType.planted);
      });

      test('watered empty soil → water is consumed, no crop involved', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 3,
        );

        final advanced = object.advanceDay(3);

        expect(advanced.soilState, SoilState.tilled);
        expect(advanced.crop, isNull);
      });

      test('tree grows without water and keeps its soil untouched', () {
        final object = aFarmObject(
          crop: aTree(stage: CropStageType.planted, daysToMature: 6),
        );

        final advanced = object.advanceDay(99);

        expect(advanced.crop!.stage, CropStageType.sprout);
        expect(advanced.soilState, SoilState.untilled);
      });
    });

    group('copyWith', () {
      test('setCrop: true is required to clear the crop', () {
        final object = aFarmObject(crop: aCrop());

        expect(object.copyWith(crop: null).crop, isNotNull);
        expect(object.copyWith(crop: null, setCrop: true).crop, isNull);
      });
    });

    group('serialization', () {
      test('round-trips an empty tilled tile', () {
        final object = aFarmObject(
          soilState: SoilState.tilled,
          lastWateredDay: 4,
        );

        expect(FarmObject.fromJson(object.toJson()), object);
      });

      test('round-trips a planted tile including the crop', () {
        final object = aFarmObject(
          soilState: SoilState.watered,
          lastWateredDay: 2,
          crop: aCrop(stage: CropStageType.budding, daysPlanted: 3),
        );

        expect(FarmObject.fromJson(object.toJson()), object);
      });
    });

    group('equality', () {
      test('same values → equal', () {
        expect(
          aFarmObject(soilState: SoilState.tilled),
          aFarmObject(soilState: SoilState.tilled),
        );
      });

      test('different soil state → not equal', () {
        expect(
          aFarmObject(soilState: SoilState.tilled),
          isNot(aFarmObject(soilState: SoilState.watered)),
        );
      });
    });
  });
}
