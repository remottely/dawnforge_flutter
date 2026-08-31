/// Shared enums, ported from the Godot repo's `Enums.cs` (and `ItemData.cs` for
/// `MaterialType`). **The wire format is the AUTHORED NAME** — content JSON
/// carries the SCREAMING_SNAKE name the `.md` pack writes (`HOE`,
/// `WATERING_CAN`), matched case-insensitively ignoring underscores; an int
/// index is also accepted for save-file compactness. Declaration order still
/// mirrors the Godot int values, so a new member is appended, never inserted.
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

/// Which way an actor faces — a 2-directional system (sprites flip, never
/// rotate).
enum ActorDirection {
  right, // 0 — the default
  left, // 1
}

/// Where a recipe is made. `none` is the authored answer for something made
/// by HAND rather than at a station — it is a real value and not a missing
/// one, which is why it heads the list exactly as the spec's does.
enum WorkstationType {
  none, // 0
  workshop, // 1 — tools and weapons
  smelter, // 2 — raw resources into processed materials
  forge, // 3 — armour and protective equipment
  seedStation, // 4 — plants into seeds
  kitchen, // 5 — cooking
  forgeAlmanac, // 6
}

/// What an item is made of (repair costs, sounds, salvage).
enum MaterialType {
  stone, // 0
  metal, // 1
  wood, // 2
  fabric, // 3
  leather, // 4
  crystal, // 5
  none, // 6
}
