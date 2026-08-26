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
| FP3 World & rendering | pending | player walks a chunked world at 60fps with debug overlay proving frame budget |
| FP4 Gameplay loop | pending | harvest → craft → place loop playable end to end |
| FP5 Surfaces & UX | pending | HUD + inventory + menu with blocker stack, no pause anywhere |
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

- **FP4.1** Props (harvestable) + drops system + item pickups.
- **FP4.2** Inventory + hotbar (domain rules + UI surface).
- **FP4.3** Tools in hand; the place/destroy/transform verb split (Godot rule 33) via
  `ActorOccupancyHelper` + permission helper ports.
- **FP4.4** Farming transform chain (till/water/plant/grow via time system minimal core).
- **FP4.5** Crafting at a workstation prop.
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

Time system full · spawning/procedural rules · progression/XP/skill trees · quests +
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
