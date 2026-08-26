/// Pure domain rule for the regeneration every vital shares — the Dart port of
/// `VitalRegenRules.cs`.
///
/// `step` is the smallest amount ever paid out, and the reason the accumulator
/// exists at all: every vital raises a floating number for what it restores,
/// so a pool creeping up by a thousandth of a point per frame would bury the
/// screen. Stamina and mana pay in whole points; health pays in halves,
/// because the hearts display draws half hearts.
abstract final class VitalRegenRules {
  /// Accumulates regeneration over time, returning
  /// `(amount to apply this tick, new accumulator)`. The C# version packed
  /// this pair into a `Vector2` because GDScript cannot bind out-parameters;
  /// Dart returns a record.
  static (double amount, double remainder) accumulateRegen(
    double regenerationRate,
    double delta,
    double accumulator,
    double step,
  ) {
    if (step <= 0) {
      throw ArgumentError.value(
        step,
        'step',
        'a step of zero or less never pays out and loops forever',
      );
    }
    final next = accumulator + regenerationRate * delta;
    if (next >= step) {
      final amount = (next / step).floorToDouble() * step;
      return (amount, next - amount);
    }
    return (0, next);
  }
}
