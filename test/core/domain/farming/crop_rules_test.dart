import 'package:dawnforge/src/core/domain/farming/crop_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.4(c): the pure arithmetic of a crop's life.
void main() {
  test('a crop grows exactly when watered', () {
    expect(CropRules.shouldGrow(wasWatered: true), isTrue);
    expect(CropRules.shouldGrow(wasWatered: false), isFalse);
  });

  test('a crop dies once it has waited long enough', () {
    expect(CropRules.shouldDie(1, 2), isFalse);
    expect(CropRules.shouldDie(2, 2), isTrue);
  });

  test('an immortal crop has no dead row to draw', () {
    expect(CropRules.realStageCount(CropStage.budding, isImmortal: true), 3);
    expect(CropRules.realStageCount(CropStage.harvestable, isImmortal: false), 6);
  });

  test('the frame is the variant block, then the stage into it', () {
    expect(CropRules.calculateTargetFrame(0, 3, CropStage.planted), 0);
    expect(CropRules.calculateTargetFrame(0, 3, CropStage.budding), 2);
    expect(CropRules.calculateTargetFrame(1, 3, CropStage.sprout), 4);
  });

  test('flat is authored OR not yet out of the ground', () {
    expect(
      CropRules.shouldBeFlat(
        authoredFlat: false,
        hasGroundStage: true,
        currentStage: CropStage.planted,
        groundStage: CropStage.planted,
      ),
      isTrue,
    );
    expect(
      CropRules.shouldBeFlat(
        authoredFlat: false,
        hasGroundStage: true,
        currentStage: CropStage.sprout,
        groundStage: CropStage.planted,
      ),
      isFalse,
    );
    expect(
      CropRules.shouldBeFlat(
        authoredFlat: true,
        hasGroundStage: false,
        currentStage: CropStage.harvestable,
        groundStage: CropStage.planted,
      ),
      isTrue,
      reason: 'the designer said flat, at every stage',
    );
  });

  test('harvestable is at peak, with something to give, by hand', () {
    expect(
      CropRules.isHarvestable(
        currentStage: CropStage.budding,
        peakStage: CropStage.budding,
        hasDrops: true,
        isHandHarvestable: true,
      ),
      isTrue,
    );
    expect(
      CropRules.isHarvestable(
        currentStage: CropStage.sprout,
        peakStage: CropStage.budding,
        hasDrops: true,
        isHandHarvestable: true,
      ),
      isFalse,
    );
    expect(
      CropRules.isHarvestable(
        currentStage: CropStage.budding,
        peakStage: CropStage.budding,
        hasDrops: true,
        isHandHarvestable: false,
      ),
      isFalse,
      reason: 'a palm is felled, never picked',
    );
  });
}
