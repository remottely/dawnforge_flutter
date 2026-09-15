# Tessera-Dart (Dawnforge Flutter) — Architecture Reference

> The code architecture of THIS repository, in one file. Consult it before writing code
> here; consult `CLAUDE.md` for the rules it obeys.
>
> **This file describes what is true, not what is intended.** Every section names the
> version it was verified against. A claim that cannot be verified is deleted, not
> softened — "will" and "should" belong in
> `docs/refactoring/implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md`. Why the file
> exists at all, and the discipline that keeps it honest, is §12.
>
> **Seeded at 0.72.0, verified against `lib/src/` at 0.70.0.** It is the Dart-side
> counterpart of the spec's `tessera/docs/ARCHITECTURE.md` (`SPEC_REPO_ROOT`): same
> section subjects where the architecture is shared, never a copy — a claim here is true
> of *this* code or it is not written.

---

## 1. What kind of program this is — verified 0.70.0

A **content engine**: the game's objects, items, ground, biomes and recipes are authored
as Markdown+YAML in `games/dawnforge/data/`, compiled to JSON by the pipeline, and read
at boot. Adding a tree is authoring a document, never writing a class.

| Principle | What it means in this repo |
|:---|:---|
| **Shell vs soul** | A host (`WorldObject`) is an empty container; its `data` is the soul injected by the factory. §5 |
| **Engine vs content** | `lib/src/core/` never spells a content folder name (rule 29); `ContentPaths` is the one name table |
| **Data-driven state** | Mutable state lives in the data layer; hosts and components read through it, never cache it (rule 8) |
| **Zero fallbacks** | Invalid state asserts or throws. There is no recovery branch and no patched default (rules 5, 20) |
| **Composition** | Behavior lives in `IComponent` subclasses; hosts are containers (§6) |
| **Fail fast** | A bad id crashes at load or first access, never silently at play (§7) |

The engine half is generic across a family of games; `games/<game>/` is one game. Today
there is exactly one game, `dawnforge`, and `TESSERA_GAME` selects it on the automation
side while `GameConstants.gameName` names it at runtime.

**Scale at 0.70.0:** 113 Dart files under `lib/src/core/`, 54 test files under `test/`,
one generated file (`lib/src/generated/component_keys.dart`).

---

## 2. The sector tree — verified 0.70.0

`lib/src/core/` mirrors the spec's sector model. Every folder names a domain; a folder
that names a leftover is forbidden (rule 22).

| Sector | Holds | Files |
|:---|:---|---:|
| `shared_logic/definitions/` | Constants, enums, `ContentPaths`, `WorldPos`/grid types | 5 |
| `resources/` | The data classes every `.md` document is authored against — the SSOT of which fields exist | 21 |
| `registries/` | One database per data family, plus `RegistryBase<T>` | 7 |
| `factories/` | The only construction sites of hosts (rule 1) | 4 |
| `components/` | `IComponent`, `WorldObjectCore`, the FSM, and the concrete components | 14 |
| `base/world_objects/` | The hosts themselves: actors, props, grounds, world items, the hand family, the placement helpers | 16 |
| `domain/` | Pure rule functions — `movement/`, `combat/`, `farming/`, `inventory/`, `production/`, `vitality/` | 13 |
| `systems/` | The long-lived singletons: eventing, input, timing, world, spawning, localization, managers, data | 17 |
| `render/` | The Flame binding — the game shell, the renderers, the sprite loader | 8 |
| `ui/` | Flutter widgets drawn over the game, and the one overlay table | 4 |
| `utils/` | Noise and deterministic random | 4 |

Two rules make the tree load-bearing rather than decorative:

- **`domain/` imports nothing from `base/` or `render/`.** A rule is a function of values,
  so it is testable without a world. This is why `test/core/domain/` runs headless.
- **`lib/src/generated/` holds content, never logic (rule 17)**, and is never hand-edited.
  Its one file today is `component_keys.dart`, emitted by pipeline step 10.

Beside the package: `games/<game>/` (the authored pack, both changelogs, the player
manual), `assets/generated/<game>/` (pipeline JSON output), `scripts/` (all automation,
addressed through `scripts/lib/project_paths.py`), `docs/`, `test/` mirroring
`lib/src/core/`, and `reference/legacy_flutter/` which is archived and never read
(rule 10).

---

## 3. Boot — verified 0.70.0

`lib/src/core/systems/boot.dart` is the Dart port of Godot's `[autoload]` table. One
function, `registerCoreSystems()`, registers **17 singletons** into a `get_it` locator, in
dependency order:

```
Events · SimClock · GridManager · ActorTracker · GameInputManager · UIStateMachine
InputHelper · LocalizationSystem
ActorRegistry · PropRegistry · GroundRegistry · ItemRegistry · BiomeRegistry · LoadoutRegistry
ProceduralWorldManager · ChunkStreamingSystem · ProceduralSpawnSystem
```

Three groups, and the order between them is the contract. The plumbing comes first
(signals, clock, grid, input, the surface stack). The six registries come next, because
everything after them reads content. The three world systems come last and are
*registered* at boot but *initialized* when a world starts — the same split the Godot
autoload makes.

**A registered system is never null (rule 28).** Everything above exists from before the
first frame until teardown, so calling `locator<Events>()` plainly is correct and an
`isRegistered` guard around one of them is a fallback in disguise. Registering twice
crashes, which `get_it` already enforces. `resetCoreSystems()` exists for tests only; the
app never unboots.

**Content boot** is separate from system boot. `AlmanacLoader.loadFromManifest` walks the
pipeline's emitted `manifest.json` and routes each entry into its typed registry by type
family (`actor_*`, `prop_*`, `ground_*`, `item_*`, `biome_*` — the family is the pack's
`type:`, which is the snake_case class name). An unknown family crashes, so the loader
gains its registry in the same commit that introduces the family. The caller supplies
`readEntry`, which is `rootBundle` in the app and `dart:io` in tests — the loader itself
makes no I/O choice and spells no folder name.

---

## 4. The clock — verified 0.70.0

The simulation advances **only in whole fixed steps** of `GameConstants.simFixedStep`
(1/60 s). `SimClock` accumulates Flame's variable frame `dt` and calls the tick callback
once per whole step elapsed.

Two properties of it are architecture, not tuning:

- **The catch-up cap.** At most `GameConstants.simMaxStepsPerFrame` (5) steps run per
  frame, so a debugger pause or a window drag cannot fire a burst of thousands of ticks.
  Steps beyond the cap are dropped, and `advance()` **returns how many** — the caller
  surfaces the number rather than swallowing it (rule 20).
- **`alpha`** is the un-simulated remainder in `[0, 1)`, which is what a render layer
  interpolates against.

**What ticks on which clock is a decision, not an accident.** World-object `update(dt)`
and every component run on the fixed step, so ported logic is deterministic and
multiplayer-shaped from day one. `ChunkStreamingSystem` runs on the **render frame**
instead, on a microsecond budget (`EngineConstants.proceduralStreamFrameBudgetUsec`),
because what a machine materializes around a camera is a view-side concern — a server
would stream for its own reasons.

Nothing in this repo pauses (rule 30). There is no `pauseEngine()` call, no forced
`dt = 0`, and no global freeze flag; §9 is the mechanism that replaces them.

---

## 5. The world object — verified 0.70.0

`WorldObject` (`base/world_objects/world_object.dart`) is the base of every host. It is
pure Dart: the simulation imports no Flame, and the render binding wraps hosts from the
outside (§2, `render/`).

The **injection contract** is three rules acting as one:

1. A host is constructed empty, by its factory and nowhere else (rule 1).
2. It receives its soul through `initialize(data)`, and the factory passes a `clone()` —
   each instance owns its own state (rule 3).
3. It is unusable before that. Reading `data` or calling `update` on an uninitialized host
   asserts, on both ends (rule 5).

`initialize` also wires the core's data provider and calls `setupComponents()`, so a host
composes itself exactly once, at the end of injection.

**The save envelope** is `serializeEnvelope()`: `data.serialize()` plus the position.
Hosts add only what is genuinely their own on top of it, and data classes serialize
**mutable state only** — never the authored configuration the pack already carries. This
is the shared shape the spec's §7 defines; nothing reads it back yet, because there is no
save/load path at HEAD (§11).

The host family at 0.70.0: `IActor` (with `ActorPlayer`), `Prop` (with `PropCrop` and
`PropWorkstation`), `GroundBuildable`, and `ItemWorld` for an item lying on the floor.

---

## 6. Components — verified 0.70.0

Behavior is composed, not inherited. `WorldObjectCore` is the **single component
container** every host owns (rule 15); a host forwards `addComponent`/`getComponent` to
its core and never declares a map of its own. A UI widget never owns a core — widgets
compose with child widgets.

Three mechanics carry the weight:

- **The key is the class name (rule 16).** A component registers under its concrete class
  name, and `ComponentKeys` — generated by pipeline step 10 from those same class names —
  restates them as constants. The constant a caller passes and the key the container
  stores therefore cannot drift. Nine components exist at 0.70.0: crop drop, direction,
  drop, health, held item, interactable, inventory, movement, workstation.
- **The lazy materializer lives on the core, not on the host.** A host may register a
  builder consulted before any miss is reported, and it sits on the core so that *every*
  reader triggers it — including a sibling reached through
  `IComponent.getSiblingComponent`, which is the reader a host-side builder would miss.
  At 0.70.0 no host installs one; the mechanism is exercised only by
  `test/core/components/world_object_core_test.dart`.
- **Absence is an answer, a wrong type is not.** `getComponent` returns null when a
  component is absent, because not every host has mana; but a key holding the wrong type
  asserts, and a duplicate key crashes rather than replacing (rule 5).

Components are reached through the core, always (rule 13), and at 0.70.0 **every call
site knows its host type** and calls `getComponent` on it directly. The newest of them is
the interact verb: `IActor.tryInteract` asks the grid for the prop at the aimed tile and
reads `ComponentKeys.interactable` off that typed `Prop`. The untyped path the
rule also describes — asking a helper for a node's core, so that a non-null core is the
typed proof the node owns components — has no implementation here; the class rule 13 names
does not exist (`L-022`). What the rule bans is nonetheless absent too: there is no
`is`-cascade over host types anywhere in `lib/`.

---

## 7. Construction and lookup — verified 0.70.0

**Registries** (`registries/`) are the only readers of content (rule 2). `RegistryBase<T>`
registers by id, refuses a duplicate id at load rather than at use, and **throws on a
miss** — there are no nulls in normal operation. Six registries exist: actor, prop,
ground, item, biome, loadout.

**Factories** (`factories/`) are the only construction sites (rule 1). The flow is always
the same four moves: the registry provides the data, the factory builds the shell, the
factory injects a clone of the soul, the factory returns the host.

One detail of `ActorFactory` is worth stating because it generalizes: **which host class
is built is decided by authored content, not by the id.** An actor whose document writes
`groups: [player]` becomes an `ActorPlayer`; the engine never knows the player by name.
`createPlayer` asserts that rather than casting quietly, so an id missing from the group
fails at construction instead of at the first press that does nothing.

---

## 8. The hand family — verified 0.70.0

What an item *does* when you press with it is a small class per kind of deed, not a
setting on one function: a swing and a build resolve different targets, ask different
gates, and spend different things.

- **`ItemHand`** is the base and also a working hand — the hand of an item that does
  nothing when pressed, which is most items in the game (a log, an ore, a bundle of
  fibre). It carries the item data, the actor whose hand it is, and `reachPixels` derived
  from the authored `action_range`.
- **`ItemHandTool`** swings. Which items get it is decided by `toolType != null`.
- **`ItemHandBuildable`** places, and exports `BuildPreview` — *what a build at this tile
  would be*, computed once and read by both the press and the ghost. A ghost painted green
  where the press would be refused is the bug that type makes unstateable.

Two types make the contract explicit:

**`ActionOutcome`** — a press becomes `none`, `spent` or `landed`. A bool cannot carry
this, because "did the blow land" and "did the press cost the actor its cadence" are
different questions: a swing at armour it cannot dent lands nothing and still takes the
cooldown, while a click on bare ground takes neither. Only the hand knows which happened,
so the hand has to say. This is a deliberate delta from the spec, which resets the
cooldown unconditionally.

**`AimSnapshot`** — the aim is measured **once**, at the instant the button goes down, and
carries every form a consumer could need: `direction` for anything that travels, `point`
for anything that names a tile, `origin` for anything that measures reach. Nothing
downstream re-derives one from another, and nothing subtracts an actor position again;
that rule is the entire reason the type exists.

---

## 9. The surface stack — verified 0.70.0

Two singletons own everything about "something is on screen", and they answer different
questions.

**`UIStateMachine`** owns what is drawn. Its invariant is one line:

> the gameplay HUD is visible ⇔ the surface stack is empty

`UIState` is *derived* from the stack, never assigned, so the two cannot disagree. Every
stack entry is keyed by its **owning object**, which is what removes a whole class of bug
rather than patching instances of it: a pop removes *this* surface, not some surface of
the same kind, so two opens against one close can no longer strand the HUD. A push is
**refused** — not queued — when the owner already has a surface open or a transition is in
flight, because a queued double-open still opens, just later. Popping an owner that is not
on the stack is a defined no-op, which is what makes a double teardown harmless.

It is also **rule 25's arbiter**: a back/cancel press is routed once through
`requestCancel()`, and surfaces answer the routed request instead of reading the button
themselves. The return value says whether a surface *owned* the press, not whether it
closed — a surface that answers by cancelling a drag has still consumed it.

**`GameInputManager`** owns whether the player may act, and it is the mechanism that
replaces pausing (rule 30). A surface that must hold the player pushes itself as a
blocker; gameplay asks `isGameplayEnabled`. It is a stack, so nested surfaces compose
without knowing what sits under them. **The simulation keeps running behind the blocker**,
and it must be seen running — the world behind a menu is live, never a captured snapshot.

`InputHelper` is the third piece: the single source of truth for player input (rules 11
and 12). Gameplay never reads a raw event or queries the keyboard; the render layer feeds
key events in, and the simulation reads a normalized vector out. Movement is a **state**
the sim samples once per fixed step; a hotbar selection is an **event**, because one
physical press must move the selection exactly one slot (rule 24).

---

## 10. Where things live in the world — verified 0.70.0

`GridManager` is the tile authority: all grid↔world conversion goes through it, never raw
vector arithmetic at a call site, and a tile's ground and elevation state has exactly one
owner. Streamed terrain is **nodeless** — a tile is a data entry, not an object — which is
what makes a 5×5 chunk window affordable.

`ChunkStreamingSystem` materializes chunks around the player with hysteresis between the
load and unload radii, widening per axis when the camera shows more world than the fixed
radius covers. `ProceduralWorldManager` supplies the terrain as pure functions of
`(seed, tile)`, so chunks regenerate identically in any order.
`ProceduralSpawnSystem` scatters the biome's authored tables, seed-pure per chunk.
`ActorTracker` is the Dart stand-in for Godot's `&"character"` scene-tree group: Dart has
no tree to ask "who is standing there", so membership is kept in a list the factory
maintains.

**One ownership fact is currently filed under the wrong owner, and it is recorded rather
than hidden.** The map of which props are resident in which chunk — the thing that frees
grid tiles on unload — lives inside `ProceduralSpawnSystem`, a system named for one of the
several ways a prop can arrive. A hand-placed prop therefore has to be adopted by the
*spawn* system to get released. See `L-007` in `docs/refactoring/LEDGER.md`; the fix is a
rename and a move, not a redesign.

---

## 11. What is not here yet — verified 0.70.0

Absences are facts about the code and belong in this file; the plans for filling them do
not.

- **No save or load path.** `serializeEnvelope()` exists and nothing reads it back. Rule 32
  is the standing consequence: a persisted shape may change freely, and the commit that
  changes it runs `scripts/project/reset_local_save.py`.
- **No intent layer between input and simulation.** The fixed step reads the device
  directly and the verb reads the cursor directly (`L-018`, `L-020`).
- **No animation on a swing, and no per-instance item state.** A hand holds the shared
  registry entry rather than a clone, because nothing mutates one yet.
- **No AI.** `AIBehavior` and `AICombatStyle` are authored and parsed onto `IActorData`;
  no system reads either field.
- **No untyped component lookup.** Rule 13's `WorldObjectHelper.getCore` has no class
  behind it (`L-022`); nothing has needed it yet, because every reader so far knows its
  host type.
- **No host uses the lazy component materializer.** The seam is ported and tested; the
  ground tiles that justify it in the spec are nodeless data here (§10).
- **Two data facts are authored but unread**: `inventory_size` on things that hold nothing
  (`L-014`), and two fifths of the pack references in the generated JSON resolving to
  nothing (`L-015`).

---

## 12. Keeping this document true

A rule with no code behind it is worse than no rule: it is read as authority and quietly
sends work in the wrong direction. This file did not exist while FP1, FP2 and FP3 closed,
which is how it comes to be seeded at 0.72.0 with three phases already behind it — so the
first obligation is the one that keeps that from happening twice.

- **Structural change updates this file in the same commit.** A sector added, a contract
  changed, a helper split: the section that describes it moves with the code, never in a
  later docs pass.
- **Every section states the version it was verified at.** A reader who sees `0.70.0`
  against a claim about 0.90.0 code re-greps; one who sees no version trusts it.
- **A claim you cannot verify is deleted, not softened.** No "should", no "will".
- **What you noticed but are not fixing goes to the ledger** (rule 27), so the next sweep
  finds it instead of rediscovering it. §10 and §11 cite ledger entries for exactly this
  reason.

The five lenses that decide what counts as an architectural finding, and the periodic
sweep that re-audits a file like this against the source, live in the spec repo's
`tessera/docs/ARCHITECTURE_EVOLUTION.md`; this repo inherits the loop through the founding
study (`docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md` §6) and has not ported the sweep.
