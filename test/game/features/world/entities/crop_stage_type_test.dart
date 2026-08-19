import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CropStageType', () {
    group('ordering', () {
      test('planted is first and harvestable is last', () {
        expect(CropStageType.values.first, CropStageType.planted);
        expect(CropStageType.values.last, CropStageType.harvestable);
      });

      test('there are 7 stages (growth math depends on this)', () {
        expect(CropStageType.values.length, 7);
      });
    });

    group('nextStage', () {
      test('planted → sprout', () {
        expect(CropStageType.planted.nextStage, CropStageType.sprout);
      });

      test('walks the whole chain in order', () {
        var stage = CropStageType.planted;
        final walked = <CropStageType>[stage];

        while (stage.nextStage != null) {
          stage = stage.nextStage!;
          walked.add(stage);
        }

        expect(walked, CropStageType.values);
      });

      test('harvestable → null (nothing beyond the final stage)', () {
        expect(CropStageType.harvestable.nextStage, isNull);
      });
    });

    group('predicates', () {
      test('canHarvest and isHarvestable only on harvestable', () {
        for (final stage in CropStageType.values) {
          final expected = stage == CropStageType.harvestable;
          expect(stage.canHarvest, expected, reason: '$stage');
          expect(stage.isHarvestable, expected, reason: '$stage');
        }
      });

      test('isPlanted only on planted', () {
        expect(CropStageType.planted.isPlanted, isTrue);
        expect(CropStageType.sprout.isPlanted, isFalse);
      });

      test('isGrowing spans sprout..fruiting, excluding both ends', () {
        expect(CropStageType.planted.isGrowing, isFalse);
        expect(CropStageType.sprout.isGrowing, isTrue);
        expect(CropStageType.fruiting.isGrowing, isTrue);
        expect(CropStageType.harvestable.isGrowing, isFalse);
      });

      test('isDead is always false (dead stage not implemented yet)', () {
        for (final stage in CropStageType.values) {
          expect(stage.isDead, isFalse, reason: '$stage');
        }
      });
    });

    group('fromProgress', () {
      test('maps each threshold to its stage', () {
        expect(CropStageType.fromProgress(0.0), CropStageType.planted);
        expect(CropStageType.fromProgress(0.20), CropStageType.sprout);
        expect(CropStageType.fromProgress(0.40), CropStageType.seedling);
        expect(CropStageType.fromProgress(0.55), CropStageType.budding);
        expect(CropStageType.fromProgress(0.70), CropStageType.flowering);
        expect(CropStageType.fromProgress(0.85), CropStageType.fruiting);
        expect(CropStageType.fromProgress(1.0), CropStageType.harvestable);
      });

      test('just below a threshold stays on the previous stage', () {
        expect(CropStageType.fromProgress(0.199), CropStageType.planted);
        expect(CropStageType.fromProgress(0.999), CropStageType.fruiting);
      });

      test('progress beyond 1.0 → harvestable', () {
        expect(CropStageType.fromProgress(2.5), CropStageType.harvestable);
      });

      test('negative progress → planted', () {
        expect(CropStageType.fromProgress(-1.0), CropStageType.planted);
      });
    });

    group('getSpriteFrameIndex', () {
      test('frame index matches the stage ordinal', () {
        for (final stage in CropStageType.values) {
          expect(stage.getSpriteFrameIndex(), stage.index, reason: '$stage');
        }
      });
    });

    group('serialization', () {
      test('every value round-trips', () {
        for (final stage in CropStageType.values) {
          expect(CropStageType.fromJson(stage.toJson()), stage);
        }
      });

      test('fromJson with unknown value → throws', () {
        expect(() => CropStageType.fromJson('rotten'), throwsArgumentError);
      });

      group('fromJsonNullable', () {
        test('valid name → the stage', () {
          expect(
            CropStageType.fromJsonNullable('budding'),
            CropStageType.budding,
          );
        });

        test('surrounding whitespace is tolerated', () {
          expect(
            CropStageType.fromJsonNullable('  budding  '),
            CropStageType.budding,
          );
        });

        test('null, empty and "none" → null', () {
          expect(CropStageType.fromJsonNullable(null), isNull);
          expect(CropStageType.fromJsonNullable(''), isNull);
          expect(CropStageType.fromJsonNullable('   '), isNull);
          expect(CropStageType.fromJsonNullable('none'), isNull);
          expect(CropStageType.fromJsonNullable('NONE'), isNull);
        });

        test('unknown value → null instead of throwing', () {
          expect(CropStageType.fromJsonNullable('rotten'), isNull);
        });
      });
    });

    test('every value exposes a display name', () {
      for (final stage in CropStageType.values) {
        expect(stage.displayName, isNotEmpty, reason: '$stage');
      }
    });
  });
}
