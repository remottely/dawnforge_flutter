import 'package:dawnforge/game/features/world/entities/world_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SoilState', () {
    group('canPlantCrop', () {
      test('tilled → true', () {
        expect(SoilState.tilled.canPlantCrop, isTrue);
      });

      test('watered → true', () {
        expect(SoilState.watered.canPlantCrop, isTrue);
      });

      test('untilled → false', () {
        expect(SoilState.untilled.canPlantCrop, isFalse);
      });

      test('fertilized → false (not wired into planting rules yet)', () {
        expect(SoilState.fertilized.canPlantCrop, isFalse);
      });
    });

    group('canPlantTree', () {
      test('untilled → true (trees need raw soil)', () {
        expect(SoilState.untilled.canPlantTree, isTrue);
      });

      test('every prepared state → false', () {
        expect(SoilState.tilled.canPlantTree, isFalse);
        expect(SoilState.watered.canPlantTree, isFalse);
        expect(SoilState.fertilized.canPlantTree, isFalse);
      });
    });

    group('needsWater', () {
      test('tilled → true', () {
        expect(SoilState.tilled.needsWater, isTrue);
      });

      test('watered → false', () {
        expect(SoilState.watered.needsWater, isFalse);
      });

      test('untilled → false (nothing to water yet)', () {
        expect(SoilState.untilled.needsWater, isFalse);
      });
    });

    group('serialization', () {
      test('every value round-trips through JSON', () {
        for (final state in SoilState.values) {
          expect(SoilState.fromJson(state.toJson()), state);
        }
      });

      test('toJson uses the enum name', () {
        expect(SoilState.watered.toJson(), 'watered');
      });

      test('unknown value → throws (soil state must never be guessed)', () {
        expect(() => SoilState.fromJson('molten'), throwsArgumentError);
      });
    });

    test('every value exposes a display name', () {
      for (final state in SoilState.values) {
        expect(state.displayName, isNotEmpty);
      }
    });
  });
}
