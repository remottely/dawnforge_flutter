# Engine surface — 560 files there, 112 here, family by family

> **How to use this document.** Three side-lane documents already measure this port from
> the outside: `AUTOMATION_DEBT` counts the scripts, `TEST_TRACEABILITY` counts the tests,
> `PACK_IMPORT_MAP` counts the authored content. Nothing counted **the engine itself** —
> how many classes the spec's `src/core/` carries per family and how many exist here. This
> is that census, and it is the number the port plan's phase gates are implicitly about.
>
> **Scope:** file counts and per-file presence by family, for the two spec trees this
> track reproduces (`shared/` and `world2d/`), plus what each missing family is owed to.
>
> **Explicitly out:** lines of code, which measures typing and not work; and behaviour,
> which is the port plan's. A file present here with a spec twin's name is counted as
> present even when it ports a fraction of the twin — the same honest-upper-bound rule
> `TEST_TRACEABILITY_2026-09-10.md` uses for "named in `test/`". **Present is an upper
> bound; absent is a lower bound on what is left.**
>
> **Measured at `0.68.0`** against `tessera 0.440.4`. The port side is counted with
> `git ls-files`, so uncommitted work in a parallel session is deliberately excluded —
> FP4.5(e)'s `InteractableComponent` and `PropInteractableData` are in the working tree
> and NOT in these numbers.
>
> Related: `FLUTTER_PORT_PLAN_2026-08-25.md` (every family below names the FP step that
> owns it), `PACK_IMPORT_MAP_2026-09-10.md` §2b (the data-class family measured from the
> content side — 932 authored keys with nothing to read them), `INPUT_PARITY_2026-09-10.md`.

## Progress

| ID | Family | Owed | Owner |
|:--|:---|--:|:---|
| ES1 | `domain/` — the pure rules | 25 | spread across FP4.4, FP7.1, FP7.7, FP7.8 |
| ES2 | `components/` | 61 | the system each one serves |
| ES3 | `resources/` — the data classes | 58 | `PACK_IMPORT_MAP` §2b, field by field |
| ES4 | `registries/` | 7 | FP6, FP7.5, FP7.6, FP7.7 |
| ES5 | `systems/` | 107 | every phase; 16 of them are the multiplayer shape (`D-9`) |
| ES6 | `ui/` | 83 | FP5, and it is FP5's true size |
| ES7 | `base/` + `world_objects/` — the hosts | 69 | FP7.12, FP7.7 |
| ES8 | `utils/` | 27 | opportunistic, with whoever needs one |
| ES9 | `debug/` | 6 | AD4, FP3.6 |
| ES10 | the census as a script | — | `AUTOMATION_DEBT` AD4, `--check` shaped |

---

## 1. The census

The spec's engine is `tessera/src/core/`, split into `shared/` (everything both
dimensions use), `world2d/` (the flat game this track reproduces) and `world3d/` (the
voxel game, which study §3 cut). `.uid` sidecars are excluded; `.gd` and `.cs` are
counted alike, because which language a spec file is written in is an artefact of that
repo's own migration and says nothing about the port.

| Family | `shared/` | `world2d/` | **Spec** | **Here** | Ratio |
|:---|--:|--:|--:|--:|--:|
| `components/` | 39 | 35 | **74** | 13 | 18% |
| `domain/` | 40 | — | **40** | 13 | 33% |
| `registries/` | 12 | — | **12** | 7 | 58% |
| `resources/` | 78 | — | **78** | 20 | 26% |
| `shared_logic/` | 15 | — | **15** | 5 | 33% |
| `systems/` | 70 | 54 | **124** | 17 | 14% |
| `ui/` | 70 | 17 | **87** | 4 | 5% |
| `utils/` | 19 | 12 | **31** | 4 | 13% |
| `world_objects/` + `base/` | 13 | 72 | **85** | 16 | 19% |
| `factories/` | — | 4 | **4** | 4 | **100%** |
| `debug/` | 5 | 1 | **6** | 0 | 0% |
| `world/` | — | 4 | **4** | 0 | 0% |
| `render/` | — | — | **0** | **8** | port only |
| **Total** | **361** | **199** | **560** | **112** | **20%** |

The port's 112 includes one generated file (`component_keys.dart`, pipeline step 10). The
spec's `world2d/world/` row is 0 here rather than folded: this port's `systems/world/` is
the twin of `world2d/systems/world/`, which is already inside the `systems/` row.

`world3d/` is a further 42 files and never crosses (study §3, decision D3).

**One family is at parity and it is the smallest one.** `factories/` is 4 and 4 — which
is the shape rule 1 predicts: there are exactly four kinds of world object, so there are
exactly four factories, and that number does not grow with content. Every other family
grows with the game.

**One family exists only here.** `render/` is 8 files and 1,081 lines with no spec
counterpart, because in Godot a node draws itself and in Flame something has to draw it.
That is decision D2 billed in files, and §6 is where it gets expensive.

---

## 2. ES1 — `domain/`, the cheapest ports in the tree

FP7.7's own text calls these *"every one pure C#, the cheapest ports in the tree"*, and it
is right: a `*Rules` class takes data and returns a decision, imports nothing, and its test
is the port's specification. **40 there, 12 with a twin here, 28 without one — and of
those 28, one never crosses and two are already ported under other names, so 25 are
genuinely owed.** The arithmetic is spelled out because the raw subtraction lies twice.

**Ported** (11 in `lib/src/core/domain/` plus `AimSnapshot`, which lives under
`base/world_objects/items_hand/` here rather than in `domain/`): `CropRules`,
`DirectionRules`, `DropRules`, `HealthRules`, `HeldItemRules`, `InventoryRules`,
`InventorySortRules`, `MovementRules`, `ProductionRules`, `VitalRegenRules`,
`WorldObjectDeathRules`, `aim_snapshot`.

**Owed, filed under the step that gives each one a caller:**

| Step | Rules owed |
|:---|:---|
| FP4.4 farming | `SoilTileRules` |
| FP7.1 time | — (the clock is a system, not a rule) |
| FP7.7 combat and AI | `AIWanderRules`, `ChaseRules`, `FleeRules`, `KeepDistanceRules`, `ThreatDetectionRules`, `PathfindingRules`, `DodgeRules`, `HerdRules`, `GrazingRules`, `BreedingRules`, `CombatSelectionRules`, `ArmorRules`, `ActionMotionRules`, `ActionMotionStep`, `ActionSpeedRules`, `EnergyRules`, `StaminaRules`, `ManaRules`, `combo_tracker`, `ImpactDebrisRules` |
| FP7.8 thermal | `ThermalRules` (nine pure functions) |
| FP7.15 visual | `FloatingNumberRules`, `VitalNotificationRules` |
| FP7.2 spawning | `FlightRules` |
| never crosses | `IslandSpawnRules` — the island mode, §7 |
| unowned | `PlacementRules`, `tool_refusal_rules` — see below |

**Two owed rules already have their behaviour here, under a different shape.** The spec
keeps placement and tool refusal as pure rules in `domain/`; this port put them in
`base/world_objects/helpers/` as `WorldPlacementHelper` and `WorldObjectToolHelper` /
`WorldObjectPermissionHelper` (0.29.0, 0.36.0). Neither is wrong and the spec keeps
helpers in that same folder too — but it means the census reads them as owed when the
decision is *already made differently*. Recorded here so the next session does not port a
second copy: **`PlacementRules` and `tool_refusal_rules` are ported under other names and
should be struck from ES1's count when this table is next re-measured.** With
`IslandSpawnRules` struck for the other reason, the honest owed figure is **25**, not 28.

**Two rules here have no spec twin at all:** `CraftingRules` and `WorldCollisionRules`.
Both are this port's own vocabulary, the way `ActionOutcome` and `BuildPreview` were
(FP4.3b, 0.38.0–0.40.0).

## 3. ES2 — `components/`

**74 there, 13 here.** The gap is not one job: a component arrives with the system that
reads it, which is why this family tracks the phase map almost exactly.

| Owner | Components owed |
|:---|:---|
| FP4.5(e) | `interactable_component` (**in the working tree at `0.68.0`, uncommitted**) |
| FP4.4 | `tillable_component`, `waterable_component` |
| FP5.1 | `health_bar_component`, `energy_bar_component`, `mana_bar_component`, `action_speed_bar_component`, `i_component_stat_bar`, `label_component`, `hover_component`, `player_hover_component`, `balloon_component` |
| FP6 | `actor_lifecycle_component` |
| FP7.1 | `actor_void_component` |
| FP7.2 | `respawn_component`, `respawn_anchor_component`, `i_component_breeding`, `i_component_grazing`, `i_component_squad`, `actor_production_component` |
| FP7.7 | `action_cooldown_component`, `action_cost_purse`, `dodge_component`, `energy_component`, `stamina_component`, `mana_component`, `i_component_combo`, `i_component_vital` arms, `armor_visual_component`, `armor_durability_component`, `pathfinding_component`, `threat_detection_component`, `damage_feedback_component`, `vital_feedback_component`, `hit_animation_component`, `hand_visual`, `held_item_float_component`, `held_item_selection_component`, `player_cursor_component`, `speed_buff_component` |
| FP7.8 | `thermal_component`, `i_component_thermal` |
| FP7.11 | `cosmetics_visual_component`, `attachment_component` |
| FP7.12 | `storage_ui_component`, `player_gift_component` |
| FP7.13 | `physics_movable_component`, `player_pull_component` |
| FP7.15 | `animation_component`, `glow_component`, `sway_animation_component`, `foot_smoke_component`, `footstep_component`, `light_occluder_component`, `quest_target_shine_component`, `workstation_effects_component` |
| the render layer answers it | `camera_component`, `collision_component`, `contact_area_component`, `grid_occupant_component` — this port keeps collision and occupancy in `GridManager` and `ActorOccupancyHelper` rather than on the host, which is §6's subject |
| the island mode, never crossing | `island_spawner_component`, `island_ground_spawner_component`, `island_npc_spawner_component` |

## 4. ES3 — `resources/`, and why this row is already measured elsewhere

**78 there, 20 here.** Do not plan this family from this table. `PACK_IMPORT_MAP` §2b
measures the same gap from the side that decides it — **932 authored keys across eight
blocks that no data class here declares** — and the correct unit of work is a field, not
a file. A data class exists here the moment one field of it is read, so a file present in
this census can still be 40 keys short, and 525 of those 932 keys sit behind a single
renderer.

The one thing this census adds: at most 20 of the 78 have a Dart file, so **at least 58
have none at all** — they are not partial ports, they are absent — which is what makes §2b's key count a
backlog rather than a diff.

## 5. ES4–ES9 — the remaining families, in one pass

**ES4 `registries/` — 12 there, 7 here, the closest family to done.** Ported:
`RegistryBase`, `ActorRegistry`, `GroundRegistry`, `ItemRegistry`, `PropRegistry`. This
port also has `BiomeRegistry` and `LoadoutRegistry` (0.50.0) where the spec keeps that
data elsewhere. Owed: `QuestRegistry` and `AchievementRegistry` (FP7.6), `SkillTreeRegistry`
(FP7.5), `StateRegistry` (FP7.7's `StateMachineBuilder`), `WorldObjectRegistry`, and
`FallbackRegistry` + `IFallbackWindowOwner` — which is `ES-D1` and the most interesting
two files in this document.

**ES5 `systems/` — 124 there, 17 here.** The subfolder split says where the work is:
`visual` 27 (FP7.15), `managers` 17, `network` **16**, `world` 14, `progression` 8,
`audio` 10 (FP7.9), `spawning` 4, `collision` 3, `timing` 3, `drop` 6, `input` 3, the rest
in ones and twos. This port has `data` 1, `drop` 2, `eventing` 2, `input` 1,
`localization` 1, `managers` 2, `progression` 1, `spawning` 1, `timing` 1, `world` 4.
`localization/` has no spec twin because Godot's `TranslationServer` is an engine
service and Flutter's is not.

**The 16 network files are the study's D4 in file form.** Nothing here ports them and
nothing should yet — "singleplayer-first, multiplayer-shaped" means the shape is kept, not
the transport. But `D-9` in the port plan already found that one of the three things D4
promised keeps that shape (input as intents) has no subject in the code (`L-018`), and
this census is the second half of that evidence: **the shape is being kept by intention
alone, against a sibling that has 16 files of it.**

**ES6 `ui/` — 87 there, 4 here, the largest gap and the smallest ratio (5%).** This is
FP5's true size, and it is worth writing next to FP5's gate, which reads as one HUD and
one menu. The spec's split is `interface` + `widgets` + `minigames` (FP7.10) + `animation`
+ `interactable` (FP5.1's hover indicator) + `helpers`, twice — once shared, once for the
flat game.

**ES7 `base/` + `world_objects/` — 85 there, 16 here.** The hosts. FP7.12 names the prop
families still missing by name and FP7.7 names the actor ones; this row adds no new work,
it sizes the two that are already written.

**ES8 `utils/` — 31 there, 4 here.** The one family with no owner, and correctly so: a
util crosses when something needs it. Listed here only so it is not mistaken for debt.

**ES9 `debug/` — 6 there, 0 here as a folder.** Not empty in substance: `debug_overlay.dart`
(FP3.6) lives in `render/`. The spec's six are `PerformanceMonitor`, `SessionLog`,
`AIDebugMonitor`, `NetworkDebugMonitor`, `ui_capture`, `fatal`. `SessionLog` and
`ui_capture` are harness-adjacent and belong with `AUTOMATION_DEBT` AD4; the other four
follow the system they watch.

**ES10 — the census as a script.** This table is hand-counted, which means it is wrong the
day after it is written. `report_port_surface.py` regenerates §1 from both trees and belongs
in `AUTOMATION_DEBT` AD4 beside `report_runway.py`. Whether it merely reports or refuses is
**not a new fork** — it inherits `TT-D1`'s answer, because a ratchet over a count is one
mechanism and this repo should not grow two.

---

## 6. What this census says that the plan did not

**A fifth of the engine is here, and the fifth that is here is the load-bearing fifth.**
Factories at 100%, registries at 58%, domain at 33% — the families that decide *how* things
are built and *what* the rules are — against ui at 5% and systems at 14%, the families that
decide how much game there is. That is exactly the shape study §9 clause 3 predicted and
the first time it has been measured rather than asserted.

**`render/` is the port's own family and it is inside FP8.1's gate.** The study's actual
gate (`FLUTTER_PORT_PLAN` FP8.1) is that a second content pack boots and
`git diff --stat lib/src/core/` prints nothing. `lib/src/core/render/` is inside that path
and holds 1,081 lines that exist only because Flame does not draw for you. Every FP7.15
item touches it, and a second pack with a different sprite layout may well have to. **The
gate could fail for a reason that has nothing to do with content-driven architecture**, and
the honest answer is to know that before running the probe rather than after. `L-021`.

---

## 7. What never crosses

| What | Count | Why |
|:---|--:|:---|
| `world3d/` entirely | 42 | study §3 cut the voxel dimension; decision D3 |
| the island mode's spawners and rules | ~6 | `ResourceRespawnManager`, `IslandSpawnRules`, the three island spawner components — the spec's second world mode, which this track never builds (FP7.2's plan correction says procedural mode never respawns) |
| `templates/` | 0 | empty in the spec too |
| the `.uid` sidecars | — | Godot's import bookkeeping |
| `.tscn` scene files | — | Godot's own composition format. Flame composes in Dart, which is why `render/` exists at all |

## 8. What an item owes

Same six obligations as the sibling documents, plus one this census makes possible:

1. its row in §Progress moved, with the version;
2. the family's count in §1 re-measured — never adjusted by hand, since ES10 exists to
   regenerate it;
3. a test (`TEST_TRACEABILITY`'s policy: a port writes its test with it);
4. both changelogs (rule 34), and a manual page when the player can see it;
5. `PACK_IMPORT_MAP` §2b's key count re-run when the item is a data class, because a
   file landing does not mean its fields did;
6. **the file struck from ES1's owed list if it turns out to be ported under another
   name** — §2 found two, and finding a third is a real outcome of doing the work.

---

## Decision register

`ES-D` prefix, per `L-013`. Neither fork is decided by this pass.

### `ES-D1` — rule 5's one controlled exception

Blocks ES4 and FP6.2's loader. `FallbackRegistry.cs` opens with
*"CONTROLLED EXCEPTION — The only permitted deviation from the Zero Fallbacks rule"*: when a
save references an entity id that no longer exists after a rename, fuzzy id matching runs
instead of a crash, **only** inside `SaveManager.load_game()`, and the scope is enforced in
code rather than documented — the flag can only be set by an `IFallbackWindowOwner` that
confirms it is loading, and `SaveManager` resets it in a `finally`.

`CLAUDE.md` rule 5 here has no exception clause at all. FP6 will meet the same problem the
spec met, so the fork is: port the exception with its enforcement, or refuse it.

**Recommendation: refuse it, and write the refusal into the study's scope cuts.** The
spec's reason is *"crashing the game would destroy the player's save"* — and rule 32 here
says the opposite in writing: nothing has shipped, no save migration is owed, and every
commit that changes a persisted shape already ends by running `reset_local_save.py`
(FP0.10, landed 0.58.0). The tool that makes the exception unnecessary exists; the
exception's cost is a permanent hole in the rule this repo's crash-is-a-feature identity
rests on. Revisit if and when something ships — which is `AD-D2`, the same fork from the
other side.

### `ES-D2` — whether `render/` is a family or an implementation detail

Blocks `FP0.18` (`docs/ARCHITECTURE.md`) and colours FP8.1's gate. `lib/src/core/render/`
has no spec twin, is 8 files and growing with every FP7.15 item, and sits inside the path
FP8.1 requires to stay untouched when a second pack boots.

**Recommendation: name it as a first-class family in `ARCHITECTURE.md`, and split FP8.1's
gate in two** — `git diff --stat lib/src/core/` excluding `render/` must be empty, and any
diff inside `render/` must be reported with its reason rather than failing silently. A
gate that cannot distinguish "the architecture leaked" from "Flame needed a new drawing
call" answers a question nobody asked. The alternative — holding `render/` to the same
zero-diff bar — is defensible and stricter, and it is the developer's call which of the two
the study is actually testing.
