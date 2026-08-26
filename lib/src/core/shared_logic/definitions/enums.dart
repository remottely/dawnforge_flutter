/// Shared enums, ported from the Godot repo's `Enums.cs`. **Declaration order is
/// the wire format**: content JSON stores the int index (same as `.tres` did), so
/// a new member is appended, never inserted — reordering silently re-means every
/// authored file.
library;

/// Which tool kind an item acts as / a ground answers to (rule 33).
enum ToolType {
  shovel, // 0
  axe, // 1
  hoe, // 2
  wateringCan, // 3
  fishingRod, // 4
  pickaxe, // 5
  sword, // 6
  bow, // 7
  staff, // 8
  sledgehammer, // 9
  sickle, // 10
  innate, // 11
  scanner, // 12
}

/// How an actor's AI relates to players.
enum AIBehavior {
  offensive, // 0 — proactively attacks players
  neutral, // 1 — attacks only when attacked
  peaceful, // 2 — flees when attacked
}

/// Combat style priority for offensive actors with both melee and ranged weapons.
enum AICombatStyle {
  meleePrimary, // 0 — prefers melee, ranged only when target is far
  rangedPrimary, // 1 — prefers ranged, melee only when target is too close
}
