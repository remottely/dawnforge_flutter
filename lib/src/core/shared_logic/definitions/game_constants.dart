/// ALL global tuning values live here — no magic numbers in engine code
/// (CLAUDE.md, Godot repo §6 Constants). One file, no dual-language twin needed.
abstract final class GameConstants {
  /// The active game's identity. Read by the pipeline's runtime twin too.
  static const String gameName = 'dawnforge';

  /// Side of one grid tile, in world units (pixels at scale 1).
  static const int tileDimension = 16;

  /// Fixed simulation step, in seconds. The sim advances only in whole steps
  /// (SimClock accumulates variable frame dt) — study risk #5: the simulation is
  /// multiplayer-shaped, so it ticks on a deterministic clock from day one.
  static const double simFixedStep = 1.0 / 60.0;

  /// Cap on catch-up steps per frame, so a long pause (debugger, window drag)
  /// does not fire a burst of thousands of sim ticks. The remainder is carried,
  /// never dropped silently — SimClock reports what it skipped.
  static const int simMaxStepsPerFrame = 5;
}
