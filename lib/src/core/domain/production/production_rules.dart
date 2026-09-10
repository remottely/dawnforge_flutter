import 'dart:math';

/// The tick arithmetic of a running batch — the Dart port of
/// `ProductionRules.cs`. Five one-line answers, each pure, each the sentence
/// `WorkstationComponent` reads instead of writing its own.
///
/// They are kept as rules and not folded into the component for the reason
/// every `*Rules` class here exists: the component owns the SEQUENCE (consume,
/// tick, spill, clear), and the sequence is the part that needs a world to
/// test. The arithmetic needs nothing, so it lives where a test can hand it a
/// number.
abstract final class ProductionRules {
  /// How much of one unit [delta] seconds finish, at [effectiveTime] seconds
  /// per unit. [effectiveTime] is never zero: `ItemCraftableData` asserts
  /// `craft_time > 0` and `PropWorkstationData` asserts its multiplier `> 0`,
  /// so the quotient they make is plain arithmetic here (rule 5 — the
  /// invariants guard, not the point of use).
  static double progressIncrement(double delta, double effectiveTime) =>
      delta / effectiveTime;

  /// Whether a unit's progress has reached the end.
  static bool isItemComplete(double progress) => progress >= 1.0;

  /// Which unit of the batch is on the bench, counted from one for a
  /// player: the third of five is `3`, not `2`.
  static int currentItemNumber(int totalItems, int remainingQuantity) =>
      totalItems - remainingQuantity + 1;

  /// Whether the batch has nothing left to make.
  static bool isBatchComplete(int remainingQuantity) => remainingQuantity <= 0;

  /// What is left of an allocated line after one unit ate [perUnitAmount]
  /// of it. Floored at zero: a line cannot owe.
  static int reduceAllocatedAmount(int currentAmount, int perUnitAmount) =>
      max(0, currentAmount - perUnitAmount);
}
