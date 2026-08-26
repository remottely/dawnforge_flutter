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

  /// Chunk rings kept loaded around the player's chunk (2 = center chunk +
  /// 24 neighbors, a 5x5 window — 40x40 tiles at chunk size 8).
  static const int proceduralChunkLoadRadius = 2;

  /// Chunk rings beyond which tracked chunks unload. Must exceed
  /// [proceduralChunkLoadRadius] — the gap is hysteresis, so walking along a
  /// chunk border never load/unload-thrashes.
  static const int proceduralChunkUnloadRadius = 3;

  /// Extra streaming reach past the visible screen, as a fraction of each
  /// edge (0.2 = 20% beyond every border) — content must exist before the
  /// camera can show it, at every zoom.
  static const double proceduralStreamScreenMargin = 0.2;

  /// Per-frame time budget (µs) for streaming column work during gameplay.
  /// The unload and load loops share it: each always completes at least one
  /// column (the window must advance every frame) and stops once the frame's
  /// streaming time crosses this line. Budgeting by TIME bounds the worst
  /// frame — a pure-water column is near-free, a coast column is not.
  static const int proceduralStreamFrameBudgetUsec = 1200;

  /// Chunk columns per frame while the initial window is still materializing
  /// — the loading screen hides the burst, so boot fills fast.
  static const int proceduralBootColumnsPerFrame = 32;

  /// Ground-layer chunk bakes per render frame — the same per-frame cap the
  /// Godot map view spends on its block bakes: it buys a fast fill and pays
  /// for it in framerate only while the fill lasts.
  static const int groundBakeChunksPerFrame = 16;

  /// Half-extent of an actor's collision body, in tiles (0.25 = an 8px-square
  /// "feet" box at a 16px tile). Top-down bodies are smaller than a tile so a
  /// one-tile gap is passable. Placeholder until the per-actor collision
  /// shape fields (`collision_padding`, shape type) are ported with FP4.
  static const double actorBodyHalfExtentTiles = 0.25;
}
