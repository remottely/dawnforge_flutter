# Flutter Port Plan — Tessera-Dart

> **The executable plan for reproducing Tessera in this repo.** Context and rationale:
> `docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md` (read it first — decisions D1–D7 bind this
> plan). Written 2026-08-25. Stable IDs (`FP<phase>.<step>`) — reference them in commits.
>
> **Gate discipline:** a phase is *closed* when its gate line is demonstrably true, and no
> later phase starts on a foundation whose gate is open. Phases are sized to be
> independently parkable (study track must never block the Godot delivery track).

## Progress

| Phase | State | Gate |
|:---|:---|:---|
| FP0 Reset & harness | gate met 2026-08-25 (FP0.9 skills pending) | harness scripts run; hooks wired; suite command green on empty project |
| FP1 Core foundation | gate met 2026-08-26 (FP1.5 component slice, FP1.9 domain rules pending) | `flutter test` green over events/registry/factory/component/FSM/grid with zero Flame imports |
| FP2 Pipeline retarget | gate met 2026-08-26 (FP2.3 sprites, FP2.4 translations, FP2.5 component-keys pending) | `dawnforge.py full` emits JSON; registries boot from a real pack slice; `--check` clean |
| FP3 World & rendering | gate met 2026-08-26 (120fps hand-run, macOS) | player walks a chunked world at 60fps with debug overlay proving frame budget |
| FP4 Gameplay loop | in progress (FP4.1–FP4.3 done; FP4.2's deferred Sort button paid 2026-08-31) | harvest → craft → place loop playable end to end |
| FP5 Surfaces & UX | pending (FP5.1's `UIStateMachine` + back-press arbiter landed early, 0.22.0) | HUD + inventory + menu with blocker stack, no pause anywhere |
| FP6 Persistence | pending | save/load round-trip; reset_local_save.py works |
| FP7 Breadth systems | pending | (per-system sub-gates: time, spawning, progression, quests, audio, i18n, minigames) |

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
- **FP4.4** Farming transform chain (till/water/plant/grow via time system minimal core).
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
- **Gate:** harvest → craft → place, playable, suite green.

## FP5 — Surfaces & UX

- **FP5.1** HUD; notification queue; `UIStateMachine` + single back-press arbiter
  (Godot rule 25); blocker stack everywhere — **nothing pauses** (rule 30: no
  `pauseEngine`, world visibly alive behind `BackdropFilter` menus).
- **FP5.2** Menus: main, settings (bindings, audio, locale), save slots.
- **FP5.3** Localization surfaces end-to-end (en/pt-BR).

## FP6 — Persistence

- **FP6.1** `SaveManager`: sectioned schema, each section owned by its system;
  fail-fast load; `SAVE_VERSION` seam.
- **FP6.2** World-object envelope serialization via core (Godot §7 shape).
- **FP6.3** `reset_local_save.py` proven; rule-32 ritual live.

## FP7 — Breadth systems (each independently parkable)

Time system full · spawning/procedural rules (**prop scatter landed early in FP4.1d** —
what remains here is actor packs, respawn and rehydration) · the tier field
(domain-warped Voronoi + per-cell tier rolls: the `ProceduralWorldManager.initialize`
crash on a second biome is the port obligation waiting for it) · ground destruction +
bridges/cave floor (deferred from FP4.3) · progression/XP/skill trees · quests +
achievements · thermal · audio system + SFX defaults (step 12) · minigames frame +
fishing · cosmetics. Order decided per study interest at the time — this is the
"new genres" playground the track exists for.

---

## Working agreements

- Every FP-step commit references its ID; observations go to the ledger, not the commit.
- `docs/ARCHITECTURE.md` for *this* repo is written incrementally as phases close — it
  describes what is true, never what is intended (Godot repo §11 discipline).
- When this plan and reality disagree, the plan is edited in the same commit that proves
  the disagreement.
