import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';
import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_data_builders.dart';

void main() {
  group('CropEntity', () {
    group('growthProgress', () {
      test('halfway to maturity → 0.5', () {
        final crop = aCrop(daysPlanted: 5, daysToMature: 10);

        expect(crop.growthProgress, 0.5);
      });

      test('past maturity → clamped to 1.0', () {
        final crop = aCrop(daysPlanted: 30, daysToMature: 10);

        expect(crop.growthProgress, 1.0);
      });

      test('daysToMature of zero → 1.0 instead of dividing by zero', () {
        final crop = aCrop(daysPlanted: 0, daysToMature: 0);

        expect(crop.growthProgress, 1.0);
      });
    });

    group('isMature', () {
      test('daysPlanted reaches daysToMature → true', () {
        expect(aCrop(daysPlanted: 7, daysToMature: 7).isMature, isTrue);
      });

      test('one day short → false', () {
        expect(aCrop(daysPlanted: 6, daysToMature: 7).isMature, isFalse);
      });

      test('is independent of stage — only stage gates harvesting', () {
        final crop = aCrop(
          daysPlanted: 10,
          daysToMature: 7,
          stage: CropStageType.sprout,
        );

        expect(crop.isMature, isTrue);
        expect(crop.canHarvest, isFalse);
      });
    });

    group('advanceDay', () {
      test('always increments daysPlanted', () {
        final crop = aCrop(daysPlanted: 3);

        expect(crop.advanceDay().daysPlanted, 4);
      });

      test('daysToMature 6 → one stage per day (ceil(6/6) = 1)', () {
        var crop = aCrop(daysToMature: 6, stage: CropStageType.planted);

        crop = crop.advanceDay();
        expect(crop.stage, CropStageType.sprout);

        crop = crop.advanceDay();
        expect(crop.stage, CropStageType.seedling);
      });

      test('daysToMature 12 → two days per stage (ceil(12/6) = 2)', () {
        var crop = aCrop(daysToMature: 12, stage: CropStageType.planted);

        crop = crop.advanceDay();
        expect(crop.stage, CropStageType.planted, reason: 'still in stage');

        crop = crop.advanceDay();
        expect(crop.stage, CropStageType.sprout);
      });

      test('stage step rounds up — daysToMature 7 still takes 2 days', () {
        var crop = aCrop(daysToMature: 7, stage: CropStageType.planted);

        crop = crop.advanceDay();
        expect(crop.stage, CropStageType.planted);

        crop = crop.advanceDay();
        expect(crop.stage, CropStageType.sprout);
      });

      test(
        'daysToMature below the stage count → at least one day per stage',
        () {
          var crop = aCrop(daysToMature: 1, stage: CropStageType.planted);

          crop = crop.advanceDay();

          expect(crop.stage, CropStageType.sprout);
        },
      );

      test('advancing enough days reaches harvestable', () {
        var crop = aCrop(daysToMature: 6, stage: CropStageType.planted);

        for (var i = 0; i < 6; i++) {
          crop = crop.advanceDay();
        }

        expect(crop.stage, CropStageType.harvestable);
      });

      test('already harvestable → stage stays, days keep counting', () {
        final crop = aCrop(
          stage: CropStageType.harvestable,
          daysPlanted: 7,
          daysToMature: 7,
        );

        final advanced = crop.advanceDay();

        expect(advanced.stage, CropStageType.harvestable);
        expect(advanced.daysPlanted, 8);
      });

      test(
        'regrowing crop uses regrowStepDays instead of the initial pace',
        () {
          // regrowStepDays 3 → three days per stage while regrowing,
          // regardless of daysToMature.
          var crop = aRegrowingCrop(
            stage: CropStageType.sprout,
            daysToMature: 7,
            regrowStepDays: 3,
            isRegrowing: true,
          );

          crop = crop.advanceDay();
          expect(crop.stage, CropStageType.sprout);

          crop = crop.advanceDay();
          expect(crop.stage, CropStageType.sprout);

          crop = crop.advanceDay();
          expect(crop.stage, CropStageType.seedling);
        },
      );

      test('daysInStage resets when the stage advances', () {
        var crop = aCrop(daysToMature: 12, stage: CropStageType.planted);

        crop = crop.advanceDay();
        expect(crop.regrowData.daysInStage, 1);

        crop = crop.advanceDay();
        expect(crop.regrowData.daysInStage, 0);
        expect(crop.stage, CropStageType.sprout);
      });

      test('returns a new instance — the original is untouched', () {
        final crop = aCrop(daysPlanted: 0);

        final advanced = crop.advanceDay();

        expect(crop.daysPlanted, 0);
        expect(advanced, isNot(same(crop)));
      });
    });

    group('regrowAfterHarvest', () {
      test('non-regrowing crop → null', () {
        expect(aCrop().regrowAfterHarvest(), isNull);
      });

      test('rolls the stage back by regrowStageRollback', () {
        final crop = aRegrowingCrop(
          stage: CropStageType.harvestable,
          regrowStageRollback: 2,
        );

        final regrown = crop.regrowAfterHarvest()!;

        expect(regrown.stage, CropStageType.flowering);
      });

      test('rollback below sprout is clamped to sprout', () {
        final crop = aRegrowingCrop(
          stage: CropStageType.harvestable,
          regrowStageRollback: 99,
        );

        final regrown = crop.regrowAfterHarvest()!;

        expect(regrown.stage, CropStageType.sprout);
      });

      test('marks the crop as regrowing and clears intra-stage progress', () {
        final crop = aRegrowingCrop(daysInStage: 5);

        final regrown = crop.regrowAfterHarvest()!;

        expect(regrown.regrowData.isRegrowing, isTrue);
        expect(regrown.regrowData.daysInStage, 0);
      });

      test('rewinds daysPlanted to the start of the new stage', () {
        final crop = aRegrowingCrop(
          stage: CropStageType.harvestable,
          daysToMature: 6,
          regrowStageRollback: 2,
        );

        final regrown = crop.regrowAfterHarvest()!;

        // flowering is index 4 of 6 stage-steps → floor(6 * 4 / 6) = 4
        expect(regrown.stage, CropStageType.flowering);
        expect(regrown.daysPlanted, 4);
      });

      test('preserves identity and yield', () {
        final crop = aRegrowingCrop();

        final regrown = crop.regrowAfterHarvest()!;

        expect(regrown.id, crop.id);
        expect(regrown.harvestItemId, crop.harvestItemId);
        expect(regrown.yieldAmount, crop.yieldAmount);
      });
    });

    group('shouldUseYSorting', () {
      test('null ySortingFromStage → never sorts', () {
        final crop = aCrop(stage: CropStageType.harvestable);

        expect(crop.shouldUseYSorting, isFalse);
      });

      test('stage before the threshold → false', () {
        final crop = aCrop(
          stage: CropStageType.sprout,
          ySortingFromStage: CropStageType.budding,
        );

        expect(crop.shouldUseYSorting, isFalse);
      });

      test('stage at the threshold → true', () {
        final crop = aCrop(
          stage: CropStageType.budding,
          ySortingFromStage: CropStageType.budding,
        );

        expect(crop.shouldUseYSorting, isTrue);
      });

      test('stage past the threshold → true', () {
        final crop = aCrop(
          stage: CropStageType.harvestable,
          ySortingFromStage: CropStageType.budding,
        );

        expect(crop.shouldUseYSorting, isTrue);
      });
    });

    group('serialization', () {
      test('round-trips every field', () {
        final crop = aCrop(
          id: HandItemId.strawberry,
          name: 'Strawberry',
          stage: CropStageType.flowering,
          daysPlanted: 3,
          daysToMature: 9,
          yieldAmount: 4,
          harvestItemId: HandItemId.strawberry_loot_item,
          requiredSeason: SeasonType.summer,
          ySortingFromStage: CropStageType.budding,
          regrowData: const CropRegrowData(
            isRegrow: true,
            regrowStageRollback: 2,
            regrowStepDays: 3,
            isRegrowing: true,
            daysInStage: 1,
          ),
        );

        final restored = CropEntity.fromJson(crop.toJson());

        expect(restored, crop);
      });

      test('null ySortingFromStage round-trips as null', () {
        final crop = aCrop();

        final restored = CropEntity.fromJson(crop.toJson());

        expect(restored.ySortingFromStage, isNull);
      });

      test('a tree round-trips as a tree', () {
        final restored = CropEntity.fromJson(aTree().toJson());

        expect(restored.isTree, isTrue);
      });

      test('missing isTree defaults to false (backwards compatible)', () {
        final json = aCrop().toJson()..remove('isTree');

        expect(CropEntity.fromJson(json).isTree, isFalse);
      });
    });

    group('equality', () {
      test('same values → equal', () {
        expect(aCrop(daysPlanted: 2), aCrop(daysPlanted: 2));
      });

      test('different growth state → not equal', () {
        expect(aCrop(daysPlanted: 2), isNot(aCrop(daysPlanted: 3)));
      });
    });
  });
}
