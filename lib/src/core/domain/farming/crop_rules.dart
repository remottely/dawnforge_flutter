import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// The pure arithmetic of a crop's life — the Dart port of `CropRules.cs`.
/// Stages are [CropStage] here rather than the spec's ints; the comparisons
/// read the index, which IS the growth order.
abstract final class CropRules {
  /// A crop grows over a day exactly when it was watered that day.
  static bool shouldGrow({required bool wasWatered}) => wasWatered;

  /// A crop left at its peak dies once it has waited long enough.
  static bool shouldDie(int daysUnharvested, int daysToDieIfUnharvested) =>
      daysUnharvested >= daysToDieIfUnharvested;

  /// How many rows of the sheet one variant block spans: one per stage up to
  /// the peak, plus the DEAD row when the crop can die. An immortal palm has
  /// no dead row to draw, so its sheet is three rows a block, not four.
  static int realStageCount(CropStage peakStage, {required bool isImmortal}) =>
      peakStage.index + 1 + (isImmortal ? 0 : 1);

  /// Which row of the sheet a crop shows: [blockIndex] variant blocks down,
  /// then [currentStage] rows into that block.
  static int calculateTargetFrame(
    int blockIndex,
    int realStageCount,
    CropStage currentStage,
  ) =>
      blockIndex * realStageCount + currentStage.index;

  /// A crop lies flat either because the designer said so for every stage, or
  /// because it has not yet outgrown its ground stage. The authored flag is
  /// the first half of the rule and not an input the stage may overwrite.
  static bool shouldBeFlat({
    required bool authoredFlat,
    required bool hasGroundStage,
    required CropStage currentStage,
    required CropStage groundStage,
  }) =>
      authoredFlat ||
      (hasGroundStage && currentStage.index <= groundStage.index);

  /// Whether a hand may take from this crop right now: at its peak, with
  /// something to give, and authored to allow it.
  static bool isHarvestable({
    required CropStage currentStage,
    required CropStage peakStage,
    required bool hasDrops,
    required bool isHandHarvestable,
  }) =>
      currentStage == peakStage && hasDrops && isHandHarvestable;
}
