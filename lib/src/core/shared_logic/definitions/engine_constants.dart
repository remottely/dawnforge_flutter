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

  // ==== Procedural world (FP3.4) — values shared with the Godot spec ====

  /// Highest mountain elevation the surface generator may emit (levels 2..4
  /// map to heights 1..[mountainMaxHeight]).
  static const int mountainMaxHeight = 3;

  /// Debug pin: a non-zero value makes every fresh world identical. 0 rolls a
  /// seed per world (`ProceduralWorldManager.resolveNewWorldSeed`).
  static const int proceduralWorldSeed = 0;

  /// Frequency of the surface height-noise field, in cycles per tile.
  static const double proceduralNoiseFrequency = 0.03;

  /// Ascending threshold count of the grayscale level scan — 5 levels: water,
  /// terrain, and mountain heights 1..3.
  static const int proceduralTerrainCutCount = 4;

  /// The quantile table samples the height noise on a
  /// [proceduralDensitySampleSide]² grid, [proceduralDensitySampleStride]
  /// tiles apart — the stride sits past the noise's feature wavelength, so
  /// consecutive samples are uncorrelated and the table describes the field,
  /// not one neighborhood of it.
  static const int proceduralDensitySampleSide = 128;
  static const int proceduralDensitySampleStride = 13;
}
