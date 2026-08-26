/// Engine-wide gameplay defaults — the Dart port of `EngineConstants.cs`.
/// These are the DECLARED defaults of data-class fields; content overrides them
/// per id, so a value here is a baseline, never a fallback.
abstract final class EngineConstants {
  static const double defaultMaxHealth = 5;

  /// Tiles per second.
  static const double baseMoveSpeed = 3;
  static const double baseAcceleration = 15.625;
  static const double baseFriction = 25;
}
