/// Engine-wide gameplay defaults — the Dart port of `EngineConstants.cs`.
/// These are the DECLARED defaults of data-class fields; content overrides them
/// per id, so a value here is a baseline, never a fallback.
abstract final class EngineConstants {
  static const double defaultMaxHealth = 5;

  /// Tiles per second.
  static const double baseMoveSpeed = 3;
  static const double baseAcceleration = 15.625;
  static const double baseFriction = 25;

  /// Dot product below which movement counts as backpedaling (perpendicular
  /// movement stays at full speed). Dimensionless.
  static const double backpedalDotThreshold = -0.1;

  /// The weakest hit in the world still has to be visible — the floor of
  /// `HealthRules.impactIntensity`'s [0, 1] output.
  static const double impactIntensityFloor = 0.35;

  /// Health regenerates in half-point steps: the hearts display draws half
  /// hearts, so a rule stated as "half a heart every hour" must be payable.
  static const double healthRegenStep = 0.5;
}
