/// ALL global tuning values live here — no magic numbers in engine code
/// (CLAUDE.md, Godot repo §6 Constants). One file, no dual-language twin needed.
abstract final class GameConstants {
  /// The active game's identity. Read by the pipeline's runtime twin too.
  static const String gameName = 'dawnforge';

  /// The actor the player IS. An id rather than a content path (rule 29): the
  /// engine may name the entry it spawns, never the folder it was authored in.
  static const String playerActorId = 'actor_player';

  /// The group an actor authors to say a person is behind it — the pack
  /// writes `groups: [player]`. The spec asks `is_in_group(&"player")`, which is
  /// the same question against the same authored list — membership is content,
  /// never a type check on the host (rule 33's spirit: what a thing is allowed
  /// to be is authored, not coded).
  static const String playerGroup = 'player';

  /// The tool an empty player hand IS — `t{tier}_item_tool_melee_hand`, the
  /// `INNATE` entry every tier of the pack carries. Bare hands are a real tool
  /// with real reach, which is what makes a player who has crafted nothing yet
  /// able to touch the world at all.
  static String innateHandItemId(int tier) => 't${tier}_item_tool_melee_hand';

  /// Slots in one row of any container's grid, and therefore one hotbar page's
  /// width. The spec's `EngineConstants.SLOTS_PER_ROW`; the player's authored
  /// `inventory_size` is a whole number of these.
  static const int slotsPerRow = 5;

  /// Side of one grid tile, in world units (pixels at scale 1).
  static const int tileDimension = 16;

  /// Side of one streaming chunk, in TILES (same derivation as the Godot
  /// `game_constants.gd`: half the tile dimension — 8 tiles at a 16px tile).
  static const int proceduralChunkSize = tileDimension ~/ 2;

  /// Fixed simulation step, in seconds. The sim advances only in whole steps
  /// (SimClock accumulates variable frame dt) — study risk #5: the simulation is
  /// multiplayer-shaped, so it ticks on a deterministic clock from day one.
  static const double simFixedStep = 1.0 / 60.0;

  /// Cap on catch-up steps per frame, so a long pause (debugger, window drag)
  /// does not fire a burst of thousands of sim ticks. The remainder is carried,
  /// never dropped silently — SimClock reports what it skipped.
  static const int simMaxStepsPerFrame = 5;
}
