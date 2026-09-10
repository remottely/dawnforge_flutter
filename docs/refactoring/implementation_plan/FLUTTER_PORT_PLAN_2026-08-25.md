# Flutter Port Plan — Tessera-Dart

> **The executable plan for reproducing Tessera in this repo.** Context and rationale:
> `docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md` (read it first — decisions D1–D7 bind this
> plan). Written 2026-08-25. Stable IDs (`FP<phase>.<step>`) — reference them in commits.
>
> **Gate discipline:** a phase is *closed* when its gate line is demonstrably true, and no
> later phase starts on a foundation whose gate is open. Phases are sized to be
> independently parkable (study track must never block the Godot delivery track).
>
> **Re-sliced 2026-09-10 (0.48.1)** against the spec at `tessera 0.432.1`: FP4.4, the rest of
> FP4.5, FP5, FP6 and FP7 carry slice-level items, FP0 gained its harness debt (FP0.10–
> FP0.18), and the open forks moved out of prose into the **Decision register** at the end.
> Every `file:line` cited there was true at that version and must be re-grepped before use.

## Progress

| Phase | State | Gate |
|:---|:---|:---|
| FP0 Reset & harness | gate met 2026-08-25 (FP0.9 skills pending; FP0.10–FP0.18 harness debt opened 2026-09-10) | harness scripts run; hooks wired; suite command green on empty project |
| FP1 Core foundation | gate met 2026-08-26 (FP1.5 component slice, FP1.9 domain rules pending) | `flutter test` green over events/registry/factory/component/FSM/grid with zero Flame imports |
| FP2 Pipeline retarget | gate met 2026-08-26 (FP2.3 sprites, FP2.4 translations, FP2.5 component-keys pending; the step-by-step map against the spec's 27 is `AUTOMATION_DEBT_2026-09-10.md` §1.1 — steps 02/03 owe `--check`, step 99 is unported, our step 11 folds the spec's 09 and 25) | `dawnforge.py full` emits JSON; registries boot from a real pack slice; `--check` clean |
| FP3 World & rendering | gate met 2026-08-26 (120fps hand-run, macOS) | player walks a chunked world at 60fps with debug overlay proving frame budget |
| FP4 Gameplay loop | in progress (FP4.1–FP4.3 done; FP4.2's Sort paid 2026-08-31; FP4.5 slices (a)–(d) landed 0.45.0–0.48.0, (e)–(h) sliced 2026-09-10; FP4.4 re-ordered after FP4.5 and sliced (a)–(h)) | harvest → craft → place loop playable end to end |
| FP5 Surfaces & UX | pending, sliced 2026-09-10 (FP5.1's `UIStateMachine` + back-press arbiter landed early, 0.22.0) | HUD + inventory + menu with blocker stack, no pause anywhere |
| FP6 Persistence | pending, sliced 2026-09-10 (FP6.1–FP6.4) | save/load round-trip; reset_local_save.py works |
| FP7 Breadth systems | pending, mapped 2026-09-10 (FP7.1–FP7.15 with sub-gates and a dependency map) | (per-system sub-gates: time, spawning, progression, quests, audio, i18n, minigames) |

---

## FP0 — Repo reset & AI harness port

- **FP0.1** Archive legacy code to `reference/legacy_flutter/` — **done 2026-08-25.**
- **FP0.2** New `CLAUDE.md`: the non-negotiable rules re-authored for Dart/Flame
  (renumbered; interop rules dropped; pause ban covers `pauseEngine`/`timeScale`).
- **FP0.3** `scripts/lib/project_paths.py` for this tree (`DATA_ROOT`, `GENERATED_ROOT`,
  `SRC_CORE`, …). Every later script imports from it (Godot repo rule 23 carried over).
- **FP0.4** Knowledge index: copy `scripts/lib/knowledge_index.py` +
  `scripts/ai/{index,search}_project_knowledge.py`, corpus re-pointed (exclude
  `reference/`, include `docs/**`, pack, `.claude/skills`, commits).
- **FP0.5** Hooks: `block_forbidden_git.py` (paths re-pointed) +
  `check_edited_file_rules.py` (Dart tripwires: `pauseEngine`/`timeScale` writes,
  raw pointer reads outside `input_helper.dart`, `dynamic` in `lib/src/core/`).
  Wire both in `.claude/settings.json`. Test with synthetic stdin.
- **FP0.6** `scripts/project/check_test_suite_is_clean.py` → wraps `flutter analyze` +
  `flutter test` (the "suite" of this repo); `reset_local_save.py` port.
- **FP0.7** `docs/AI_HARNESS.md` port; `docs/refactoring/{README,LEDGER,PENDING}.md`
  seeded empty; changelog pair + manual skeleton under `games/dawnforge/`.
- **FP0.8** Version ritual: `pubspec.yaml` reset to `0.1.0+1`; bump-from-HEAD one-command
  commit recipe adapted (reads `pubspec.yaml` instead of `project.godot`).
- **FP0.9** Skills: port `onboard`, `recall`, `ledger`, `ship`, `plan-doc`, `suite` first;
  `scaffold-worldobject` re-templated in FP1; `sweep`, `player-docs`, `ui-text` after
  their subjects exist; new `flutter-run` know-how skill replaces `godot-run`.

**Harness debt, opened 2026-09-10 (0.48.1).** Each item is a script or a document the
rules already assume exists. None needs a decision; each names the ledger entry or the
rule that is its evidence. Every script obeys rule 23 (`project_paths.py`, `__main__`
guard, `--dry-run`/`--check`, a `COMMANDS.md` row in the same commit).

**The wider inventory is its own document.** FP0.10–FP0.18 are the scripts *this repo's own
rules* already assume exist. The question "what else does the delivery track run that we do
not" was measured on 2026-09-10 into
`implementation_plan/AUTOMATION_DEBT_2026-09-10.md` — 27 pipeline steps and 40 project
commands over there against 7 and 4 here, each row either owed with an `AD` id, owned by an
`FP` step, or not applicable with the reason. Nothing there is restated here and nothing
here is restated there.

- **FP0.10** `scripts/project/reset_local_save.py` — the port `L-004` says is missing.
  The spec is `tessera/scripts/project/reset_local_save.py`; the Dart delta is the
  location: the save dir is `path_provider`'s application-support folder keyed by the
  bundle id, so the script reads `PRODUCT_BUNDLE_IDENTIFIER` from
  `macos/Runner/Configs/AppInfo.xcconfig` (and the Linux/Windows twins) rather than
  typing `com.remottely.dawnforge` by hand, and sweeps `saves/` under it on every
  platform folder that exists. Settings (`shared_preferences`) survive by default;
  `--all` takes them. Lands **before FP6.1's first write**; FP6.3 proves it.
- **FP0.11** — **done 0.56.0.** `scripts/content/check_pack_snapshot_matches_spec.py
  [--check|--report <path>|--accept <path>]` — the drift guard `L-006` asked for. Two
  deltas from the commission, each because the pack said so: documents pair by **`id`,
  not path** (the port files two `t1_ground_buildable_*` snapshots under the smelter and
  the spec under the biome — a path match calls a moved document a missing one, and the
  move is REPORTED because the folder is part of a translation key); and the three kinds
  of difference are not one verdict. A key only the SPEC authors is the port's BACKLOG,
  never a failure — 1023 of them across 52 documents, because a field whose Dart data
  class does not exist cannot be authored here (rule 6). A key both sides author with
  different values, or a key only this pack authors, is the FORK, and fails `--check`
  unless recorded with a written reason in `pack_snapshot_deltas.yaml` (`--accept` writes
  one document at a time, never in bulk; `--report` prints one diff). Two repo-wide
  deltas live in the script header instead: the `spritesheet` path rewrite, and
  `shadow_origin_offset`, which 51 documents here author and the spec has dropped.
  Documents with no twin at all are the header's `ONLY_HERE` allowlist, each with its
  reason. A machine without the sibling repo reports **not applicable**, never a pass —
  the Godot repo's `L-306` lesson (`check_pipeline_check_coverage.py`). NOT in the suite:
  it needs a repo the suite cannot assume. First green run: 28 forked documents, 67
  forked keys, `L-006`'s own `cave_elevation_drops` among them; `L-014` opened.
- **FP0.12** the merge-commit path `L-008` found: `block_forbidden_git.py` learns
  `git merge --continue` and refuses it, pointing at a new
  `scripts/project/commit_merge.py` that (1) asserts the index holds exactly the paths the
  merge itself touches (`git diff --name-only $(git merge-base HEAD MERGE_HEAD)
  MERGE_HEAD` vs `git diff --cached --name-only`), (2) runs the attribution check on the
  message, (3) commits. The one case the guard could not inspect becomes the one case a
  script inspects for it. `docs/AI_HARNESS.md` §3 gains the row.
- **FP0.13** — **done 0.53.0.** The cross-repo path sweep `L-003` asked for:
  `dawnforge_project` → `tessera_project` in `CLAUDE.md` (Project Overview, §Key File
  Locations), `docs/AI_HARNESS.md` §5 and the study's §1 table (the study's dated prose
  stays — it says where the repo WAS; §8 holds no path). The path is written once, as
  `SPEC_REPO_ROOT` in `project_paths.py` (FP0.11 reads it) beside `spec_repo_available()`
  and `spec_pack_root()`; every doc cites the constant. `L-003` drained.
- **FP0.14** — **done 0.57.0.** The tripwires FP0.5 promised and `check_edited_file_rules.py`
  did not carry (`L-009`): `\bdynamic\b` on a non-comment line, scoped to all of `lib/`
  rather than `lib/src/core/` — rule 4 says `lib/`, the hook already judges only `lib/`,
  and generated files are included on purpose because rule 17 forbids hand-editing them
  at all. Zero occurrences in `lib/` and `test/` when it was written, so it needed no
  whitelist. The `timeScale` tripwire FP0.5 also listed is **dropped, with the reason
  written in the hook header and in `docs/AI_HARNESS.md` §3**: Flame has no global time
  scale, and a hand-rolled `dt *= factor` has no zero-false-positive regex — a tripwire
  with false positives is trained away within a day. It stays a rule 30 reading, not a
  hook. `L-009` drained.
- **FP0.15** the manual's section map (`L-010`): `games/dawnforge/docs/manual/README.md`
  (the fifteen-page table as the spec's, adapted to this track's page names) +
  `TEMPLATE.md`, and `scripts/docs/check_manual_mirrors.py --check` (same filenames in
  `en/` and `pt-BR/`, same heading levels in the same order, every existing page listed
  in the map). Runs from the suite script.
- **FP0.16** — **done 0.51.0.** `scripts/project/check_changelog_is_ordered.py --check` — newest-first
  order, no surviving `0.0.0-NEXT`, en/pt-BR section and category parity, no version
  twice. Evidence it is owed: at 0.47.0 both changelogs carried `0.45.4` and `0.45.3`
  ABOVE `0.47.0`, and 0.48.0 repaired it by hand. Runs from the suite script.
- **FP0.17** — **done 0.52.0.** `scripts/project/check_translation_keys.py --check` — every string-literal
  key passed to `tr(` in `lib/` exists in every emitted locale table
  (`assets/generated/<game>/locales/*.json`); the count of non-literal calls is printed,
  never swallowed. Here a missing key CRASHES at render (rule 5), which is later than a
  red suite.
- **FP0.18** `docs/ARCHITECTURE.md` — the working agreement below says it is written as
  phases close; FP1, FP2 and FP3 have closed and the file does not exist. Seed it with
  what is TRUE at HEAD only: the sector tree, the boot order (`boot.dart`'s
  registrations), the fixed-step loop (`SimClock`), the world-object envelope
  (`WorldObject.serializeEnvelope`), the hand family (`ItemHand`, `ActionOutcome`), the
  surface stack (`UIStateMachine` + blocker), residency ownership (cite `L-007`). Never
  an intention.

## FP1 — Core foundation (pure Dart, zero Flame imports)

The engine's brain, unit-testable headless. Tree: `lib/src/core/` mirroring the Godot
sector model (`shared_logic/`, `domain/`, `resources/`, `registries/`, `factories/`,
`components/`, `systems/`, `utils/`, `base/`).

- **FP1.1** `shared_logic/definitions/`: `game_constants.dart`, enums, tier enums.
- **FP1.2** `systems/eventing/events.dart` — typed event bus; service locator boot
  (`get_it`) with the "a registered system is never null" rule.
- **FP1.3** `resources/` base: `IWorldObjectData` → `IActorData`/`PropData`/
  `GroundBuildableData`/`ItemData` hierarchy, constructor-validated (`Data that exists is
  valid data`), `fromJson` + `clone()`, `serialize()` restricted to mutable state.
- **FP1.4** `registries/`: `RegistryBase<T>` scanning bundled JSON via asset manifest;
  typed getters that throw on miss; `FallbackRegistry` (save-compat only).
- **FP1.5** `components/`: `IComponent`, `WorldObjectCore` (single container, lazy
  materializer, typed `health`/`energy`/`mana` accessors), constructor DI between
  components; `component_keys.dart` generator (pipeline step, FP2).
- **FP1.6** `components/fsm/`: `State`, `StateMachine` (plain Dart, fixed-step ticked).
- **FP1.7** `factories/`: Actor/Prop/Ground/Item factories — the only construction sites.
- **FP1.8** `systems/`: `GridManager` (grid↔world math), fixed-step `SimClock`
  (accumulator over variable `update(dt)` — study risk #5), `GameInputManager`
  (UI blocker stack, `isGameplayEnabled`).
- **FP1.9** `domain/`: port the highest-value `*Rules` classes as needed by FP4 systems
  (movement, farming, inventory, placement first) — pure Dart, direct translation from C#.
- **FP1.10** Test suite mirrors `lib/src/core/` under `test/core/`; write tests here
  (API is stable — it is a port, not a design).

## FP2 — Content pipeline retarget

- **FP2.1** Copy pipeline scaffolding (`dawnforge.py`, `scripts/pipeline/` skeleton,
  `scripts/lib/`) from the Godot repo; keep step numbering.
- **FP2.2** Step 04 JSON emitter: `.md` almanac → `assets/generated/<game>/**/*.json`
  (replaces `.tres` emitter; same `HIER_BLOCK_FIELDS` idea, one target).
- **FP2.3** Steps 02/03 (atlas sprite extraction/placeholders) as-is; add sprite/animation
  manifest JSON for the Dart `AnimationCreator`.
- **FP2.4** Step 05 translations → ARB/lookup tables + `tr()` helper.
- **FP2.5** Step 10 `component_keys.dart` generator (single target).
- **FP2.6** Import a real slice of the Dawnforge pack (01_biomes + 03_farm subset) and
  boot registries from it in a test. `--check` modes wired into the suite script.
- **FP2.7** `ContentPaths` twin in Dart (`lib/src/core/shared_logic/definitions/`) —
  engine never names content folders (Godot rule 29).

## FP3 — World & rendering (Flame enters here)

- **FP3.1** Flame `GameWidget` shell, camera/viewport, fixed-step sim wiring (SimClock
  drives systems; render interpolates).
- **FP3.2** `AnimationCreator` port: manifest JSON → `SpriteAnimation`s.
- **FP3.3** World object shells: `base/` hosts binding core+components to Flame
  `PositionComponent`s; factories assemble them (the "scene" replacement).
- **FP3.4** Chunked ground renderer: per-chunk baked layers (`toPicture`/sprite batch),
  budgeted bake per frame (mirror of `procedural_map_view`), elevation layers.
- **FP3.5** Grid-occupancy collision + movement (domain rules), player actor + input
  (`InputHelper`: unified cursor, input parity keyboard/touch/gamepad).
- **FP3.6** Debug overlays: FPS/frame budget, chunk state, AIDebugMonitor equivalent.
- **Gate:** walkable procedural chunked world, 60fps, budget overlay proving it.

## FP4 — First full gameplay loop

- **FP4.1** Props (harvestable) + drops system + item pickups — **done 2026-08-26**, in
  four slices: (a) loot tables + biome population parse, (b) `DropRules`, (c) physical
  pickups (drop → landing → magnet → collect), (d) procedural prop scatter + grid prop
  occupancy. *Plan edit (working agreement): the prop half of **spawning moved here from
  FP7** — harvesting needs something authored to harvest, and the pack has carried the
  population tables since FP3.4a. FP7's spawning entry now covers actor packs, respawn
  and rehydration. "Harvestable" itself is FP4.3a's damage verb: FP4.1 built everything
  a harvest produces, not the swing.*
- **FP4.2** Inventory + hotbar (domain rules + UI surface) — **(a) domain done 2026-08-26**
  (rules + slots in the data soul + component). (b) is the surface, and it pulls
  `UIStateMachine` + the single back-press arbiter forward from FP5.1 (decision: FP4 ships
  the definitive surface, not a throwaway). **(b) done 2026-08-27** in seven
  commits (0.20.0–0.25.0) — `PENDING.md` #7 carries the breakdown. *Plan edits the work forced:* interface strings needed a pack source of
  their own before rule 19 was satisfiable at all (`data/ui/`, step 05's second source),
  and the player had to **become an authored actor** here rather than in FP4.3a — the
  boar standing in for one authors `inventory_size: 0`, so no surface bound to it could
  show a slot. The `ActorPlayer` HOST is still FP4.3a's; only the document moved. Sorting
  was deferred out of FP4.2b entirely, because `InventorySortRules` ranks by item
  subtypes and a tier field that did not exist yet — **paid 2026-08-31** (0.41.0–0.43.0)
  once both had arrived, `tier` with FP4.3a and `ItemBuildableData` with FP4.3b. The
  ladder's four unported families keep their numbers so nothing renumbers when they
  land, and the sort's fourth axis (the localized display name) is skipped for want of
  a data class that reads `display_name_key` — it arrives with the first surface that
  shows an item's name.
- **FP4.3** Tools in hand; the place/destroy/transform verb split (Godot rule 33) via
  `ActorOccupancyHelper` + permission helper ports. *Scope edit: ground destruction
  (digging a terrain tile + the empty-tile flood) is deferred to FP7 with bridges/cave
  floor — the gate needs place / destroy-prop / transform-farm, and all three are here.*
  **(a) done 2026-08-29** in nine commits (0.26.0–0.34.0) — occupancy, the tool gate, the
  hand, the ordered permission gate, prop death and drops, the swing, the unified cursor,
  the aim, and `ActorPlayer`. `PENDING.md` #8 carries the breakdown and the four things
  left out on purpose. *Plan edit reality forced:* the CURSOR had to be built here.
  Rule 11 had no subject until an action needed aiming, so `InputHelper` grew pointer
  state (mouse + touch; the gamepad's virtual cursor is its own port) — which is also
  what FP4.2b's deferred mouse-wheel hotbar was waiting on. **(b) done 2026-08-30** in
  six commits (0.35.0–0.40.0) — the blueprint, the named refusal, the ground half, the
  hand refactor, the verb, and the ghost. `PENDING.md` #9 carries the breakdown, the
  seventh slice that was investigated and refused, and the two debts. *Plan edits
  reality forced:* a seventh slice (`canBuildOnTarget`) was planned and is NOT written,
  because its blocker turned out to be the missing second consumer — the cursor
  indicator, FP5.1 — rather than the missing data class, so porting it now would be
  unreachable code (rule 5). And 0.38.0 was a refactor nobody planned: the deed had to
  move out of `ActorPlayer` and into the item holding it (`ItemHand` + subclasses)
  before place and strike could be two verbs instead of two settings of one.
  **The verb is finished and NOT REACHABLE:** no path in the game puts a blueprint in
  the player's bag, so FP4.5 is what opens it, and `building.md` waits for that commit
  rather than documenting a deed the player cannot perform.
- **FP4.4** Farming transform chain — till → water → plant → grow → harvest. **Re-ordered
  2026-09-10: lands AFTER FP4.5**, because every farm tool is a WORKSHOP recipe and the
  workshop is FP4.5's hand-craft (see the chain under FP4.5(g)); before that commit the
  chain is unreachable and rule 34 forbids documenting it. Sliced from the spec at
  `tessera 0.432.1`; file:line must be re-grepped before each slice.
  **CORRECTION, 2026-09-10 — the re-order could not hold whole, and part of (b), (c),
  (e) and (g) landed FIRST (0.49.0).** The FP4.5(g) chain says "the palm falls to bare
  hands → logs", and that was false at 0.48.2: `t1_prop_crop_tree_palm` authors no
  `drops`, its logs live ONLY in `stage_drop_configs.BUDDING`, and nothing read that
  table — a felled palm gave nothing, so no smelter could ever be paid for. The crop
  half of (b) (`PropCropData`, without `PropSoilData`), (c) `CropRules`, the scatter
  obligation in (e) (a wild crop surfaces at a stage rolled in `[PLANTED, peak]`, the
  spec's `_make_prop_command`, not "at peak"), `CropDropComponent`, `PropCrop` (stage
  and the two loot halves only — no growth) and the seven seed documents the local
  stage tables name (rule 5: a rolled id must resolve) are in. Growth on `dayChanged`,
  soil, the ground verb, planting and `farming.md` remain here, after FP4.5.
  - **(a) `TimeSystem`, the minimal core** (`shared/systems/timing/TimeSystem.cs`):
    `timeProgress` in [0,1) advanced by `stepDt / dayLength` on the **fixed step**, never
    wall time; day boundary at 0.25 (06:00) fires `Events.dayChanged(dayCount)` exactly
    once per wrap; `timeUpdated(hour, minute)` stepped to 10 minutes; `isNight` from
    `nightStart`/`nightEnd` (0.7083 / 0.25). Constants join `engine_constants.dart`
    (`dayLength = 780`, `daysPerSeason = 28`, `seasonsPerYear = 4`). `serialize()` is
    `{time_progress, day_count}` — FP6's `time_system` section. PORT DELTA: the spec ticks
    in `_Process` scaled by `tactical_time_scale`; there is no time scale here (rule 30).
    Seasons, weekday names, weather and sleep stay FP7.1. Tests: one boundary crossing per
    wrap, wrap-around, stepped minutes, no double fire on a large step.
  - **(b) the two data classes + registry routing**: `PropSoilData` and `PropCropData`
    (`PropCropData.cs:37-77` — `ground_stage`, `has_ground_stage`, `is_waterable`,
    `peak_stage`, `is_immortal`, `days_to_die_if_unharvested`, `is_hand_harvestable`,
    `is_recurrent`, `recurrent_return_stage`, `variants_per_stage`,
    `hides_actors_at_stage`, `stage_drop_configs: {stage: [DropEntry]}`); the mutable half
    (`current_stage`, `days_unharvested`, `variant_index`) in `serialize()`; the two
    soil flags (`is_tilled`, `is_watered`) live on `PropSoilData`, not on the components —
    the spec keeps them on the component (`waterable_component.gd:11`), which is its own
    rule 8 broken, and this port does not copy a violation. `PropRegistry` gains the two
    `type` arms. PORT DELTA: the `tilemap`/`TileMapPlacement` block is Godot's autotile
    placement; soil here is a prop host drawn on the prop layer (terrain is nodeless,
    FP3.4), so the block is not read and the data class does not declare it.
  - **(c) the pure rules**: `CropRules` (`ShouldGrow`, `ShouldDie`,
    `CalculateTargetFrame`, `ShouldBeFlat`, `IsHarvestable`) with tests; `SoilTileRules.
    IsConnectedBlock` is a TileMap atlas question and is **not ported** until a consumer
    exists (rule 5 — no unreachable code).
  - **(d) the ground verb** (`item_hand_tool_ground.gd:17-74`, `ground_buildable.gd:572-
    600`): `ItemHandToolGround` — materialize the aimed tile, ask the ONE ordered gate
    (`canDamageTarget`; occupancy first), then `GroundBuildable.takeDamage`, which asks
    `canFarmTarget` FIRST: a farm tool (`farm_tools: [SHOVEL]` on
    `t1_ground_buildable_terrain`) spawns `farm_prop_id` at the tile through the factory —
    the TRANSFORM verb of rule 33, asking nobody about overlap. `ToolType` already has
    `shovel`, `hoe`, `wateringCan`, `sickle`. `GroundBuildableData` gains `farmPropId`,
    `farmTools`, `elevationAllowedTools` (authored, unread today). PORT DELTA: the spec's
    `"t1_prop_soil"` default when `farm_prop_id` is empty is a fallback (rule 5) — here an
    empty `farm_prop_id` with non-empty `farm_tools` is a content error asserted at
    construction. The XP grant line is FP7.5's, left out not stubbed (0.47.0 precedent).
  - **(e) the hosts**: `PropSoil` (interactable; `dayChanged` → daily drying; watering can
    → `water()`), `PropCrop extends PropSoil` (`prop_crop.gd:138-172` growth on
    `dayChanged`: grow one stage while watered or not waterable, rot after
    `days_to_die_if_unharvested` at peak unless immortal; `set_growth_stage` for wild
    crops; `CropDropComponent` filtering drops by `current_stage`; harvest at peak — by
    hand if `is_hand_harvestable` (the interact verb, FP4.5(e)) or by the death path;
    recurrent crops return to `recurrent_return_stage`, one-shot crops revert to a soil
    prop). **Obligation the scatter inherits:** `t1_prop_crop_tree_palm` is
    `prop_crop_data` and spawns today as a plain prop; the moment (b) routes it, FP4.1d's
    scatter must spawn crops at `peak_stage` (`set_growth_stage`), or every forest boots
    as saplings. The frame is `CalculateTargetFrame(variant, stageCount, stage)` over the
    authored `frames_grid`, selected by `WorldObjectRenderer`.
  - **(f) residency**: a soil spawned by a transform and a crop planted by a blueprint
    enter the world by neither scatter nor placement — the third author `L-007` predicted.
    This slice drains `L-007`: the residency map moves out of `ProceduralSpawnSystem` into
    a `ChunkResidency` owner every entry path registers with; `adoptPlacedProp` becomes
    its method. Refactor, no behaviour change, tests moved with it.
  - **(g) planting**: a seed is an `item_buildable_*` whose `blueprint_id` is the crop
    (spec `04_seed_station/t1/`, `crafted_at: SEED_STATION`; the palm also drops its seed
    at every stage). Planting IS FP4.3b's place verb with one more gate: the anchor tile
    must hold a soil prop (`PlacementRefusal.needsSoil`, named), and placing REPLACES the
    soil (the crop is a soil). Import the six seed documents + the seed station pair.
  - **(h) rule 34**: manual page `farming.md` (en + pt-BR; name per the decision
    register, `D-4`), `### ✨ New` in both changelogs.
  - **Gate:** with the FP4.5 loadout only — shovel and watering can from the workshop,
    seeds from felling a palm — till, water, plant, sleep through three day boundaries,
    harvest wheat. Suite green.
- **FP4.5** Crafting. Content imported 2026-08-31 (0.45.0); recipe data read for the
  first time in the same commit. It owes the **`building.md` and `crafting.md` manual
  pages in both languages**, `building.md` deferred here on purpose from FP4.3b (rule 34
  is satisfied by the commit that makes a deed reachable, not by the one that makes it
  work). Seven slices: recipe data · `CraftingRules` · `PropWorkstationData` + recipe
  discovery · `WorkstationComponent` (the production queue) · the **interact verb**,
  which does not exist in this port at all and is pulled forward from FP5.1 the way
  FP4.2b pulled `UIStateMachine` (`E` is taken by the hotbar step here, so the binding is
  its own decision) · the two surfaces · the bootstrap.

  **CORRECTION, 2026-08-31 — the claim this bullet carried at 0.44.0 was wrong, and it
  was mine.** It said FP4.5 makes FP4.3b reachable "since the smelter authors
  `crafted_at: NONE` and is therefore made in the player's own menu". Verified against
  the spec at HEAD, both halves fail. **(1) No hand-craft menu exists, there either.**
  `ItemCraftableData.cs:19` promises one in a comment ("If NONE, it can be hand-crafted
  in player inventory"), but `workstation_ui.gd` is the only recipe surface in the spec
  and it populates from `PropWorkstationData.get_valid_recipes()`, which filters
  `crafted_at == workstation_type` — a NONE recipe appears at no station. **(2) Even
  with that menu the smelter stays unmakeable:** it costs 5 copper ore + 5 coal, and
  `t1_prop_vein_copper` / `t1_prop_rock_coal` author `allowed_tools: [PICKAXE]`; the
  copper pickaxe is `crafted_at: WORKSHOP` from 5 planks + 1 copper bar, both SMELTER
  outputs. That is a **cold-start deadlock in the authored content**, and it holds on the
  delivery track too — the only thing that opens it there is the COMMENTED-OUT debug dict
  in `actor_player.gd:140-220`, which is where `"t1_item_buildable_workstation_smelter":
  1` sits. The pack authors no starting inventory (`actor_player.md` has only
  `inventory_size: 30`), and no biome population table can scatter a smelter.

  **Consequence: a faithful port of FP4.5 does not close the FP4 gate** — craft and place
  both stay unreachable. **Decision taken 2026-08-31 (developer's call, the fork was put
  to them):** the bootstrap is an **authored starting inventory** — the player document
  gains `starting_inventory: [{id, amount}]`, read by `IActorData` and granted by the
  factory, which is the use `ItemAmount.cs`'s own comment already names. Starting with a
  copper pickaxe closes the loop: mine → chop → hand-craft the smelter → place it →
  produce at it. Two things follow from it and are owed by the bootstrap slice: the
  **hand-craft surface** for `crafted_at: NONE` has to exist (otherwise the loop is a
  one-off), and the new pack field is an **additive fork of the shared contract** until
  the Godot side reads it too — study §4 and risk register #3, and `L-006` is the entry
  that already says nothing here notices pack drift.

  **Slices, restated 2026-09-10 against HEAD (0.48.0).** (a) recipe data — 0.45.0 ·
  (b) `CraftingRules` — 0.46.0 · (c) `PropWorkstationData` + discovery — 0.47.0 ·
  (d) `WorkstationComponent` + `ProductionRules` — **0.48.0** (batch paid up front,
  allocated materials, refund on cancel and on death, quiet refusals for a foreign recipe
  and an unaffordable batch, `is_producing` derived from `current_recipe`, the "1 of 5"
  count the spec never wrote down). Four remain:
  - **(e) the interact verb** — `InteractableComponent` (`interactable_component.gd`:
    `interact(interactor)`, `interacted` signal, `interaction_prompt` and
    `interaction_range` read from the data — both authored on every document, both unread
    today) mounted by `PropWorkstation.setupComponents` only (the `L-005` lesson: a
    component goes where its data says, not on every prop); `IActor.tryInteract(
    AimSnapshot)` → `WorldObjectHelper.getCore` → the component, gated by the SAME
    edge-to-edge `isWithinRange` the swing uses (0.34.0). PORT DELTA: the spec needs
    `PlayerHoverComponent` because `E` has no cursor meaning on its keyboard; here the
    `AimSnapshot` already carries the aimed tile, so hover state is not required for the
    verb — the hover INDICATOR is FP5.1(e). Touch: a tap on an interactable within reach
    interacts (rule 12). Gamepad: waits with the virtual cursor (FP4.3a omission, still
    open). The key is `D-1` in the decision register — the code binds an ACTION
    (`interact`), so the slice does not wait for the letter.
  - **(f) the two surfaces** — `WorkstationPanelView` (a Flutter widget, `UIStateMachine`
    MENU kind + `pushUiBlocker`, live `BackdropFilter`): recipe grid (`RecipeSlotView`
    with the spec's six panel states), details (each ingredient as have/need,
    `craft_time × quantity`, `craft_amount`), quantity stepper 1..`maxCraftable` capped at
    100, start/cancel, progress view fed by the component's signals (`workstation_ui.gd`
    is the spec, 800 lines, most of it Godot layout). The **hand-craft surface** is the
    SAME widget bound to the `crafted_at: NONE` recipe list, opened from the inventory
    panel — its behaviour is `D-2`. Strings enter `data/ui/ui_strings.md` with the spec's
    spellings (`translations_static.csv`: `notification.production_started`,
    `.production_complete`, `.not_enough_materials`, `.production_failed`, plus the
    `ui.workstation.*` labels). This is the first surface that SHOWS an item's name, so it
    pays PENDING #7's port delta: a data class reads `display_name_key`, and
    `InventorySortRules`' fourth axis goes live in the same commit.
  - **(g) the bootstrap — CORRECTED 2026-09-10; landed 0.50.0** (step 26 twin with its
    own item-id check, `IStartingLoadoutData`, `LoadoutRegistry` routed by the loader,
    `StartingLoadoutRules.apply(player)` at boot, XP refused until FP7.5 rather than
    dropped, the pickaxe document imported into `02_workshop/t1/`). The 2026-08-31 decision assumed the
    shared contract had no starting inventory and proposed `starting_inventory:` on the
    player document as an additive fork. **The spec has authored one since `tessera
    0.334.0` (2026-09-05):** `games/dawnforge/data/progression/starting_loadout_default.md`
    (`entries: [{id, amount}]`, `granted_xp`), read by `IStartingLoadoutData` +
    `StartingLoadoutRules` (`shared/systems/progression/`) through pipeline step 26. The
    fork clause is **void**; the port is: step 26 twin (`26_import_loadouts_to_json.py`,
    `--check`), `IStartingLoadoutData`, `StartingLoadoutRules.grant(player)` called once
    by the boot on a NEW world (every boot is new until FP6), the loadout id named as an
    engine contract the way the spec's `BareHandRules` names the fists (rule 29 bans
    folders, not entries). The pack copy here authors `t1_item_tool_melee_pickaxe_copper
    × 1` — a VALUE, on the shared shape, which `L-006`'s guard (FP0.11) will list as a
    known delta. The spec's `DEBUG_LOADOUT` switchboard is `D-3`. **Chain verified
    2026-09-10 against both packs:** pickaxe → ore + coal (`allowed_tools: [PICKAXE]`);
    the palm falls to `INNATE` (bare hands) → logs; smelter (`NONE`: 5 ore + 5 coal) and
    workshop (`NONE`: 5 logs + 5 ore + 5 coal) are hand-crafts; bars + planks at the
    smelter; every tool (`WORKSHOP`: 5 planks + 1 bar) at the workshop. One item opens
    all of it. The earlier "mine → chop" wording was right by accident — chopping needs
    no axe.
  - **(h) rule 34** — `crafting.md` and `building.md`, en + pt-BR; `### ✨ New` for
    craft AND place in the same section (place became reachable in this commit, 0.39.0–
    0.40.0 were `### 🧹 Internal` for exactly this reason).
  - **Gate:** a new world, the pickaxe in slot 1: mine, punch a palm, hand-craft the
    smelter, place it, produce a bar. Suite green.
- **Gate:** harvest → craft → place, playable, suite green.

## FP5 — Surfaces & UX

Sliced 2026-09-10 from the spec at `tessera 0.432.1`. What FP4 pulled forward stays
pulled: `UIStateMachine` + the back-press arbiter (0.22.0), the hotbar (0.24.0), the
inventory panel (0.25.0), the workstation panel (FP4.5f). **Gate:** HUD + tabbed menu +
settings + main menu, every surface through the blocker stack, nothing pauses, the world
visibly moving behind every `BackdropFilter`.

- **FP5.1 HUD** (`shared/ui/interface/hud.gd`, `i_hud_surface.gd`).
  - (a) `NotificationQueue` (`NotificationQueue.cs`): `Events.notificationAdded(text,
    type)` → queued display + a 50-deep history (`notificationHistoryUpdated`) + the
    floating request (`floatingNotificationRequested(owner, text, color, 2.5 s)`); types
    INFO/SUCCESS/WARNING/ERROR to colour via `VitalNotificationRules.PickColor`'s sibling
    table. The named refusals of 0.36.0 and 0.48.0 get their first listener here.
  - (b) floating numbers: `FloatingNumberRules` (pure: rise, punch, fade, format) +
    `VitalNotificationRules` (pure) with tests, and a Flame `TextComponent` pool over
    world objects (the spec's `DamageNumberUpdater`). Setting `show_floating_
    notifications` gates it (FP5.2c).
  - (c) vitals: `StatBar` and `HeartBar` widgets bound to `HealthComponent`; the
    `health_bar_*`, `bar_offset_y`, `hide_bar_when_full` fields authored on every
    document and read by nothing today feed `WorldObjectBar` (the bar above a damaged
    prop). Energy/mana/stamina bars arrive with their components (FP7.7).
  - (d) `TimeHUD` (hour:minute stepped by 10, day count) over FP4.4(a)'s clock.
  - (e) `InteractionIndicator` (`interaction_indicator.gd`, `interaction_manager.gd`):
    `HoverComponent` (hover rect from `grid_size`) + `PlayerHoverComponent` (cursor →
    hovered object, UI hover wins) + the corner brackets sized to the target or to a held
    blueprint, the `[E]` balloon with `interaction_prompt`. **This is the second consumer
    FP4.3b's refused seventh slice waited for** — `canBuildOnTarget` ports here, and the
    note at `WorldObjectPermissionHelper` that says so is deleted in the same commit.
  - (f) `NotificationHistoryHUD` (collapsible list) and `hudVisibleChanged` hiding the
    HUD while a MENU is open (already emitted by `UIStateMachine`, listened to by nobody).
  - (g) the HUD as the one owner of surfaces: adopts `IHudSurface`s (hotbar, inventory,
    workstation), routes the back press once (rule 25 — `requestCancel` exists),
    forwards drag previews between slots.
  - (h) `DeathOverlay` is parked until an actor can die (FP7.7).
  - rule 34: `interface.md` (en + pt-BR).
- **FP5.2 Menus.**
  - (a) `TabbedMenu` (`tabbed_menu.gd`: tabs INVENTORY and CONFIG now; WORLD_MAP,
    SKILLS, CHARACTER, PROGRESSION, ACHIEVEMENTS arrive with their FP7 systems) — the
    inventory panel becomes a tab; one MENU-kind surface, one back press closes it.
  - (b) `ConfigurationTab` (`configuration_tab.gd`) over two settings twins persisted with
    `shared_preferences` (already a dependency): `InputSettings` (music/sfx/ui volumes,
    `show_floating_notifications`, `show_ui_notifications`, `hold_to_pickup`,
    `smart_stack_to_storages`) and `UISettings` (health display style hearts/bar, target
    FPS 30/60/120, locale, font scale — locked at 1 as in the spec). Every value has a
    default in `engine_constants.dart` and a `reset_to_defaults`.
  - (c) bindings: `InputActionCatalog` (contexts GAMEPLAY/MENU/DIALOG/OVERLAY/TEXT_ENTRY;
    `InputHelper` today binds 23 physical keys directly — they become ACTIONS looked up
    through the catalogue, which is the seam rebinding needs), `ShortcutMappingPanel`
    (rebind by pressing), `input_icons` (a glyph per device for every action label —
    rule 19: the glyph is an icon, never text). Rule 12: every action has a keyboard, a
    gamepad and a touch answer in the catalogue or the catalogue refuses to build.
  - (d) `ConfirmationDialogData` + `ConfirmationDialogUI` + `DialogLayer` (DIALOG kind;
    the destructive verbs of (f) and FP6.4 ask through it).
  - (e) `TextEntryPanel` + `VirtualKeyboardUI` (`OnScreenKeyboardManager`): TEXT_ENTRY
    kind; gamepad/touch can type a world name (rule 12).
  - (f) `MainMenu` (`main_menu.gd`: a page stack — `MenuRootPage`, `MenuWorldListPage`,
    `MenuWorldCreatePage`, `MenuSessionPage`; join/host pages are multiplayer and are
    cut, study §5) over `WorldSession` (`request_new_world(slot, name, difficulty, seed)`
    / `request_existing_world(slot)`). **Needs FP6.4** for the list; the root page and
    the create page's seed/name fields can land first with a single implicit slot only
    if FP6.1 already writes it — no stub slot (rule 5).
  - (g) `LoadingScreen` over `loadingStarted/Finished` — the chunk boot burst runs UNDER
    it; the world is alive behind it (rule 30).
  - rule 34: `controls.md`, `getting-started.md` (en + pt-BR).
- **FP5.3 Localization end-to-end.** Runtime locale switch (`LocalizationSystem.
  loadLocale` again + `Events.localeChanged` → every `tr()` consumer rebuilds; widgets
  through a `ValueListenable`); `es` as the third selectable locale (`D-5`; the tables
  already carry it since 0.20.0); FP0.17's key guard in the suite; the `display_name_key`
  reader lands in FP4.5(f), not here. Manual stays en + pt-BR (spec's own scope choice).

## FP6 — Persistence

Sliced 2026-09-10 from `world2d/systems/managers/SaveManager.cs` (`SAVE_VERSION =
"6.0.0"`, `MAX_SAVE_SLOTS = 32` via `WorldCatalogue.cs`, `AUTO_SAVE_INTERVAL = 30`) and
`shared/utils/WorldObjectSave.cs`. **Gate:** save → quit → load restores the player, the
bag, every built/harvested/planted difference from the roll, and the clock; a save from a
different `SAVE_VERSION` is REFUSED with its version named; `reset_local_save.py` clears
it. Every commit here that changes a shape ends with rule 32's ritual.

- **FP6.1 `SaveManager`.** One JSON per slot under the application-support dir
  (`saves/slot_<n>.json`, `D-6`); header `version`, `timestamp`, `world_name`,
  `game_mode` (`survival` only until FP7.14); sections `players` (one, keyed by a fixed
  local identity — multiplayer-shaped, study §5), `world_objects`, `procedural_world`
  (seed + the terrain cuts), `time_system`; `progression`, `difficulty`, `quests`,
  `achievements`, `statistics` are added by the commits that port their systems, each
  bumping `SAVE_VERSION`. **A section is owned by its system** — `serialize()`/
  `deserialize()` on the system, `SaveManager` only assembles; the list of sections is
  ONE table the round-trip test iterates. Fail-fast load: unknown version → throw naming
  it (no migration, rule 32); missing section → throw; writes suppressed while loading
  (`ISaveLifecycle.set_writes_suppressed`). Auto-save every 30 s on the fixed clock,
  `save_game(slot)` explicit from the menu. `is_loading_game` guards the systems that
  must not react to their own restoration (the spawn adopt at
  `procedural_spawn_system.gd:252`).
- **FP6.2 The envelope.** `WorldObject.serializeEnvelope()` exists (0.2.0): `{id, type,
  position, data: data.serialize(), components}` — extend with `current_state` for FSM
  hosts (FP7.7) and route through a `WorldObjectSave` twin so the manager never spells a
  host's fields. **What is saved in procedural mode is the DIFF from the roll**, per chunk
  (`procedural_spawn_system.gd:833-853`: `_prop_records`, `_actor_records`,
  `_item_records`, the populated-chunk set, and rolled-but-unexecuted commands): a
  harvested prop is an absence, a built or planted one is an envelope, a pickup on the
  ground is an `item` record. This is the residency owner's section — FP4.4(f)'s
  `ChunkResidency` serializes it, which is the second reason `L-007` drains there. The
  player envelope carries `actor_data`, `inventory` (`InventoryData.serialize` since
  0.17.0, `selected_slot` since 0.24.0), position.
- **FP6.3 Ritual live.** FP0.10's script proven against a real save; a test writes every
  registered section and reads it back; `CLAUDE.md` rule 32's command finally runs.
- **FP6.4 `WorldCatalogue`** (`shared/systems/WorldCatalogue.cs`): `save_exists`,
  `get_world_card(slot)` (name, day, playtime, mode — what the list row shows),
  `find_free_slot`, `delete_world`, `rename_world`, `duplicate_world`. FP5.2(f)'s list
  page consumes it; the destructive three ask FP5.2(d)'s dialog.

## FP7 — Breadth systems (each independently parkable)

Order is decided per study interest at the time — this is the "new genres" playground
the track exists for. What follows (2026-09-10) is not an order but the DEPENDENCY MAP
and each system's sub-gate, spec files and known port deltas, so a session can pick any
node whose arrows are satisfied. Spec paths are under `tessera/src/core/` at `tessera
0.432.1`; the pack counts are the spec's `games/dawnforge/data/` at the same version.

```
FP4.4(a) clock ─► FP7.1 time ─► FP7.8 thermal
FP7.5 progression ─► FP7.6 quests/achievements
FP7.5 ─► FP7.3 tier field (is_content_unlocked) ─► FP7.4 ground destruction + layers
FP7.7 combat/AI ─► FP7.2 actor spawning (a pack needs an AI to wander)
FP5.2 settings ─► FP7.9 audio (volumes) · FP5.1 HUD ─► FP7.10 minigames (OVERLAY kind)
FP6 ─► everything that persists a new section (7.1, 7.2, 7.5, 7.6, 7.12)
```

- **FP7.1 Time system, full** (`TimeSystem.cs`, `storm_scheduler.gd`,
  `IWeatherBiomeSource.cs`): seasons (28 days × 4), year, weekday names, `get_season_name`
  via `tr()`; night window → `WorldDarkness` (a screen tint, not a pause); daily weather
  roll per biome (`_RollDailyWeather`, `is_weather_active(biome)`), rain watering every
  soil at day start (`prop_soil.gd:237 _check_rain_on_start`); sleep (`PropSleepable`,
  `get_hours_slept`) with the rest fractions of FP7.5's difficulty; the void/ambience
  windows are content-specific (Eclipse) and port last. Section `time_system` grows.
  Sub-gate: a week passes with a season change and one rainy day that waters the field.
- **FP7.2 Actor spawning** (`procedural_spawn_system.gd:174-360`, `procedural_actor_
  spawn_entry.gd`, `PopulationRollRules`): `actor_entries` (id, pack size, chance,
  minimum distance from the player — spawns wait for the player to exist),
  `max_actors_per_chunk` (the forest authors 1), the far-actor despawn sweep that
  serializes into `_actor_records` and rehydrates through the factory when the chunk
  loads again. **Plan correction:** the spec's `ResourceRespawnManager` is ISLAND mode
  (`register_island`, `SpawnRuleData`) and procedural mode "never respawns" by its own
  table header — so "respawn" here means only `RespawnComponent` on a prop whose
  document authors `respawn_time > 0` (every imported one authors `0.0`; port when a
  document does not). `PropPool` is an allocation optimisation; measure before porting.
  Sub-gate: a boar pack appears at distance, wanders (FP7.7's idle/wander states), leaves
  and returns across a chunk unload without duplicating.
- **FP7.3 The tier field** (`world2d/utils/TierResolver.cs:110-274`, `TierSystem.cs`,
  `docs/architecture/TIER_SYSTEM.md`): `get_tier_at(worldPos)` from a domain-warped
  Voronoi over the seed with per-cell tier rolls, `get_biome_data_at`, per-tier terrain
  ids for the chunk baker; the second biome (`procedural_swamp.md`, t2) imported — the
  `ProceduralWorldManager.initialize` crash on a second biome IS the sub-gate; then
  `is_content_unlocked` (the third clause 0.47.0 left out) once FP7.5 exists. Section
  `procedural_world` grows.
- **FP7.4 Ground destruction, bridges, layers** — the largest node; opens its own plan
  document (`plan-doc` shape) when picked. Spec: `item_hand_tool_ground.gd` (dig /
  sledgehammer), `ground_buildable.gd:656 destruction_refusal` (named refusals — the
  Godot `DESTRUCTION_REFUSALS_2026-09-05.md` plan), the empty-tile flood
  (`ground_empty_water/cliff` already imported), stacking ground on ground (refused WHOLE
  at 0.36.0; reopen with max height `mountainMaxHeight = 3`, world edge, slab margin),
  `mountain_face_resolver.gd` + `cliff_visual_system.gd`, `PropCaveShaft` +
  `PropStaircase` + `WorldLayer` (`procedural_cave_<biome>.md`, `world_layer_manager.gd`,
  Godot `CAVE_SYSTEM_2026-08-07.md`). Sub-gate: dig a tile, watch water flood it, bridge
  it, descend a shaft into the cave layer of the same chunk.
- **FP7.5 Progression** (`shared/systems/progression/`, `shared/resources/progression/`):
  `TierSystem` (25 levels, 5 per tier, XP curve, AP), `PlayerProfile` (its own
  `serialize`), `XPActionConfig` (`ActionType` + `CalculateXp(action, tier,
  multiplier)`) — then the XP grant lines deliberately left out at 0.47.0, 0.48.0 and
  FP4.4(d)/(e) are put back, each citing this step; `DifficultySystem` (Easy/Normal/Hard
  and the ten clause getters `DifficultySystem.cs:78-181`, the world-create page's
  stepper); `SkillTreeRegistry` + `SkillTreeCategory`/`SkillTreeNode`
  (`skill_tree_bootstrapper.gd`; the pack authors it under `data/progression/`);
  `ExperienceBar`, `SkillTreeTab`, `ProgressionTab`, `CharacterTab`. Sections
  `progression`, `difficulty`. Manual `progression.md`, `difficulty.md`. Sub-gate:
  harvesting levels the player up and unlocks a node that changes something authored.
- **FP7.6 Statistics, quests, achievements** — statistics FIRST, it is the substrate
  both read: `StatisticsManager` + `StatisticsLedger` (`record(statType, targetId,
  amount)`), section `statistics`. Then `QuestRegistry` (36 documents), `QuestData`/
  `QuestObjective`/`QuestState`, `QuestManager` (prerequisites, `start`, `report_
  progress(objectiveType, targetId, amount)`, `complete`), `QuestHUD`, `QuestJournalUI`
  (`quest_graph_canvas`), NPC dialogue (`ActorNpc`, `NpcInteractionEntry`,
  `quest_dialog_balloon_ui`; `t1_actor_npc_thornwick` is already imported). Then
  `AchievementRegistry` (131 documents, generated by `generate_achievement_families.py` —
  port the generator too, rule 23), `AchievementManager.evaluate_all` over the ledger,
  `AchievementsTab`. Manual `progression.md`, `achievements.md`.
- **FP7.7 Combat and AI** — pays FP4.3a's four written omissions: (i) the swing's MOTION
  (`ActionMotionRules`, `ActionMotionStep`, `hand_visual.gd`, the impact delay
  `AimSnapshot` was built to survive); (ii) actors hittable — `usePrimaryAction` over an
  actor, a corpse, loot and the death path (`WorldObjectDeathRules` is ported);
  (iii) the gamepad's virtual cursor (`gamepad_cursor.gd`, `player_cursor_component.gd`
  — rule 12 broken in writing since 0.32.0; also unblocks the mouse-wheel hotbar of
  PENDING #7); (iv) action costs (`action_cost_purse.gd`, `combo_tracker.gd`,
  `EnergyRules`/`StaminaRules`/`ManaRules` + their components and bars). Then the AI:
  `ActorCreature`/`IActorEnemy` hosts, `StateMachineBuilder` from `state_config` data over
  the FSM already ported (0.2.0), states idle/wander/chase/flee/attack/keep-distance/
  dodge/stun, domain `AIWanderRules`, `ChaseRules`, `FleeRules`, `KeepDistanceRules`,
  `ThreatDetectionRules`, `PathfindingRules`, `DodgeRules`, `HerdRules`, `GrazingRules`,
  `BreedingRules` (every one pure C#, the cheapest ports in the tree); ranged
  (`ItemHandToolRanged`, `ItemHandProjectile`, `ItemProjectileData` —
  `t1_item_projectile_spell_vinewhip` is imported); armour (`ArmorRules`,
  `ItemArmorData`, `ItemHandArmor`, durability `IItemDurabilityData`); death and
  respawn (`RespawnAnchorComponent`, `DeathOverlay`, the difficulty fractions). Manual
  `combat.md`, `survival.md`. Sub-gate: a boar charges, is struck with motion and cost,
  dies, drops hide; the player dies and respawns at the anchor.
- **FP7.8 Thermal** (`ThermalRules.cs` — nine pure functions; `thermal_component.gd`,
  `hud_thermometer.gd`): `base_temperature`/`thermal_tolerance` are authored on every
  document (the smelter authors 400°), `heat_radius` too — a lit smelter warms the
  player; energy toll before health toll. Manual `survival.md`. Sub-gate: standing in the
  swamp at night without a heat source drains energy, then health.
- **FP7.9 Audio** (`flame_audio` is a dependency; spec `shared/systems/audio/`,
  `world2d/systems/audio/`, `sfx_rules.gd`): an `AudioSystem` façade with the bus split
  (music / sfx / ui) fed by FP5.2's volumes; pipeline step 12 (`sfx_defaults.md` →
  JSON: `pickup`, `build`, `plant`, `dig`, `till`, `water`, `eat`, `hit`, `die`, …) and
  the `data/audio/sfx/**` crossing into `assets/`; `sfx_rules` (which sound a struck
  thing makes, by `material_type`); `bgm_manager` playlist; `ui_sound_config.md`. Rule
  30: pausing a SOUND is fine. Sub-gate: every verb the manual describes is heard.
- **FP7.10 Minigames** (`shared/ui/minigames/minigame_frame.gd`, `world2d/ui/minigames/`,
  `IMinigameConfig` + `MinigameFishingConfig`, `ItemHandToolMinigame`): the frame
  (OVERLAY kind — the world keeps moving behind it, rule 30), fishing first (the rod is
  a WORKSHOP recipe), the guitar-hero variant second. Manual `minigames.md`.
- **FP7.11 Cosmetics** (`ItemCosmeticData`, `cosmetics_visual_component.gd`,
  `cosmetics_helper.gd`, `import_cosmetics_pack.py` + `author_cosmetics_from_sprites.py`
  — port the generators, rule 23): 150+ documents under `data/cosmetics/`; the six
  `cosmetic_*_id` fields are already authored on the player document; a layered sprite
  stack replaces the single sheet in `WorldObjectRenderer`. `CharacterTab` picks them.
- **FP7.12 The other prop families** the registry's `_` arm still reads as plain props
  (0.47.0): `PropStorage` + `StorageUIComponent` (the chest half of the inventory UI —
  `inventory_ui.gd` is written for two containers; `smart_stack_to_storages`),
  `PropSleepable` (→ FP7.1 sleep), `PropMarket` + `PropMarketData` (coins —
  `t1_item_craftable_coin_copper` is imported), `PropForageData`, `PropStaircase`
  (→ FP7.4), `ActorProductionComponent` (an animal that produces on a timer). Each is
  its own commit with its manual line.
- **FP7.13 Pushing** (`push_rules.gd`, `physics_movable_component.gd`,
  `player_pull_component.gd`; Godot `VOXEL_PUSHING_2026-09-03.md` records the second
  port of it): `is_pushable`/`weight` are authored on every prop and read by nothing;
  occupancy learns to MOVE (`GridManager` today only occupies and frees).
- **FP7.14 Creative mode** (`creative_inventory_rules.gd`, `RuntimeConfig.cs`,
  `GAME_MODE_CREATIVE`; Godot `CREATIVE_MODE_2026-08-17.md`): the catalogue as a bag;
  the save header's `game_mode` gains its second value. Manual `creative-mode.md`.
- **FP7.15 Visual polish, ungated:** `sprite_shadow_system.gd` (+ the Godot
  `SPRITE_SHADOWS_2026-08-14.md` decisions), `water_edge_renderer.gd` +
  `WaterWaveSystem.cs`, `elevation_visual_system.gd`, `biome_effects_controller.gd`,
  `hit_flash.gdshader` → a Flame `FragmentShader`, `glow_component.gd`,
  `sway_animation_component.gd` (`has_idle_sway` is authored and unread),
  `hit_animation_component.gd`, `footstep_component.gd`, `action_animation.gd`,
  `impact_visuals_flat.gd` (`ImpactDebrisRules` is pure), `pixel_perfect_viewport.gd`,
  `CameraZoom.cs`. Pick by what the eye misses most.

---

## Decision register

Open forks the plan cannot close on its own, grouped by what each blocks, each with a
recommendation. Settled ones move to the step they unblocked, dated. Decisions taken
before this register existed live inline in their steps (FP4.2b's Shift-drag, FP4.3's
ground-destruction deferral, FP4.5's authored loadout of 2026-08-31 — the last one
corrected in FP4.5(g)).

| ID | Blocks | Question | Recommendation |
|:---|:---|:---|:---|
| **D-1** | FP4.5(e) | Which key is `interact`? `E` steps the hotbar here; the spec binds `interact` to `E` / cross. | `E` = interact, hotbar step → mouse wheel (waits on FP7.7 iii) + `[`/`]` now; parity with the spec's muscle memory outweighs the port's habit. |
| **D-2** | FP4.5(f) | The hand-craft surface has NO spec (0.45.1). Instant or timed? Output to the bag or to the ground? | Same widget, timed with multiplier 1.0, output straight into the bag (no station to drop in front of). One code path, one behaviour to learn. |
| **D-3** | nothing | Port the spec's `DEBUG_LOADOUT` switchboard (`starting_loadout_rules.gd`, dev/tester only, `has_debug_loadout()`)? | Not now: it is a dev affordance with rule-21 dead lines by design, and the authored loadout already opens the loop. Revisit when a playtest needs "every item in the game". |
| **D-4** | FP4.4(h), FP0.15 | Manual page names: keep the port's (`backpack.md`, `item-bar.md`, `gathering.md`) or adopt the spec's section map (`interface.md`, `gathering-and-farming.md`)? | Keep the port's names and write ITS section map (FP0.15); the manual is per-game prose, not the shared contract. New pages take the spec's name where one exists (`crafting.md`, `building.md`, `farming.md` is the one exception: the port already split gathering out). |
| **D-5** | FP5.3 | Offer `es` in the settings menu? The tables carry it; the manual does not. | Yes — the pack authors every string in three locales and rule 19's guard (FP0.17) covers it for free. Manual stays en + pt-BR. |
| **D-6** | FP6.1 | Save location and slot count. | `getApplicationSupportDirectory()/saves/slot_<n>.json`; the spec's 32 slots is a UI number, not a schema one — take it. |
| **D-7** | FP5.1/5.2 look | Pixel font and design tokens (the spec ships `data/fonts/pixel_panel` + `UISettings` roles; Godot `DESIGN_SYSTEM_2026-08-06.md`). | System font until FP5.2 lands; the token set is a design pass of its own, after the surfaces exist. |
| **D-8** | harness | Adopt the Godot repo's rules 35–37 (35 dimension parity, 36 context budget, 37 shared docs via lane fragments)? | 36 only, as rule 36 here with 35 and 37 reserved N/A: 35 has no subject in a one-dimension repo, 37 solves a ten-lane problem this repo does not have. The developer's call — `CLAUDE.md` is theirs. |

---

## Working agreements

- Every FP-step commit references its ID; observations go to the ledger, not the commit.
- `docs/ARCHITECTURE.md` for *this* repo is written incrementally as phases close — it
  describes what is true, never what is intended (Godot repo §11 discipline).
- When this plan and reality disagree, the plan is edited in the same commit that proves
  the disagreement.
