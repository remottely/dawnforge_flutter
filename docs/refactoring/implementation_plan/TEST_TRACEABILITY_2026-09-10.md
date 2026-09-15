# Test traceability — the code no test has ever named

> **How to use this document.** `CLAUDE.md` §Testing Policy says port work writes its
> tests **with** the port, because the API is a spec and not a draft. This document is
> the list of places where that did not happen, measured rather than remembered, with
> what each missing test must fix. Every item is executable without asking anybody
> anything; the one fork is at the end and nothing waits on it.
>
> **Out of scope:** a coverage percentage (see §1 for why the number would lie), the
> exploratory lanes the policy exempts, and any demand that a file have a file — a class
> is covered when something asserts its behaviour, wherever that assertion lives.
>
> **Measured 2026-09-10 at `0.53.0`.** Suite: `flutter analyze --fatal-infos` clean,
> `flutter test` green at **381 tests**. Re-measure before acting: this is a snapshot of a
> tree two sessions write to.

## Progress

| ID | Item | What its absence costs | State |
|:---|:---|:---|:---|
| **TT1** | the four foundations: `JsonReader`, `Splitmix32`, `DropEntry`, `AllocatedMaterial` | every data class and every seeded world rests on them | pending |
| **TT2** | the FP1.5 components: `HealthComponent`, `MovementComponent`, `DirectionComponent`, `IComponentVital` | the rules are tested, the state that owns them is not | pending |
| **TT3** | the FP4 hand: `HeldItemComponent`, `HeldItemRules`, `WorldObjectToolHelper` | 190 lines deciding what the player is holding | pending |
| **TT4** | the envelope: `WorldObject.serializeEnvelope`, `GroundBuildable`, `CropDropComponent` | FP6 is about to build on a shape nothing asserts | pending |
| **TT5** | the four render classes | reachable with the idiom this repo already has | pending |
| **TT6** | the ratchet that keeps the number from growing | a list like this one reappears in six weeks otherwise | pending (`TT-D1`) |

---

## 1. The metric, and what it is worth

Every `.dart` under `lib/src/` that declares a class, enum or mixin (109 files, `generated/`
excluded), against every name that appears anywhere under `test/`:

| | count |
|:---|---:|
| declaring files | 109 |
| named at least once in `test/` | 88 |
| **never named** | **21** |

**"Named" is an upper bound on coverage and nothing more.** A class can be constructed as a
fixture for someone else's test and never be asserted about — `named` counts that as
covered, and it is not. The number that carries weight is the other one: a class no test
file so much as mentions is code no test can be asserting anything about. That is a lower
bound on the dark area, and 21 is it.

The reverse reading also matters and is the reason a percentage would lie: `test/core/domain/
domain_rules_test.dart` names `MovementRules` and `HealthRules` together, so one file covers
several, and file-to-file mirroring would report a hole where there is none. The `test/`
tree mirrors `lib/src/` by folder (`CLAUDE.md` §Testing Policy), never one-to-one by file.

---

## 2. The twenty-one

### TT1 · The four foundations

Nothing else in the tree is more depended upon, and none of the four is named in a test.

- **`JsonReader`** (`lib/src/core/resources/json_reader.dart`, 170 lines) is the single
  parse path every data class arrives through. Its whole job is rule 5 in one place: a
  missing required field must throw naming the field and the document, and a `stringOr`
  default must be a deliberate authored absence rather than a patch over one. Both halves
  are untested, so the guarantee the rest of the port assumes is the one thing nobody has
  checked. Its test is a fixture map and a dozen assertions, and it should be the first
  thing written in this document's list.
- **`Splitmix32`** (`utils/random/splitmix32.dart`) is why the same seed gives the same
  world. `dawnforge_game_test.dart` pins seed `20260826` and asserts the *world* that comes
  out, which is an excellent gate test and a poor generator test: it fails for any reason at
  all, including a legitimate content change, and it passes for a generator that is stable
  but wrong. The direct test is three lines — a known seed, a known first four values,
  written down so a refactor cannot quietly change the world.
- **`DropEntry`** (`systems/drop/drop_entry.dart`) and **`AllocatedMaterial`**
  (`resources/world_objects/props/allocated_material.dart`) are small value types on the two
  paths where a mistake becomes an item duplicated or an item lost — a loot roll and a
  production refund. `DropRules` and `ProductionRules` are both tested; the shapes they pass
  around are not.

### TT2 · The FP1.5 components the plan records as done

`PENDING.md` #2 records the first component slice as done on 2026-08-26 — "Direction/
Movement/Health + 4 Rules". Measured: the four **rules** are named in
`test/core/domain/domain_rules_test.dart`. The three **components** are named nowhere.

That is the more interesting half to test, because the rules are pure functions and the
components are where rule 8 lives: state on the data, never duplicated into the component.
The tests that fix that: a `HealthComponent` that takes damage and dies once (not twice — a
death path that fires again on a corpse is the double-free `freePropTiles` already asserts
against at the grid level); a `MovementComponent` whose position after N fixed steps is the
rules' answer and not an accumulated float; a `DirectionComponent` that survives a
serialize/clone round trip. `IComponentVital` is the contract the energy, mana and stamina
components of FP7.7 will implement — testing it now is cheaper than testing it three times.

### TT3 · The hand

`HeldItemComponent` is 190 lines, the largest untouched file in the list, and it carries the
port's own invention: **the selected slot IS the hand, derived and never stored** (0.28.0),
with an empty slot meaning BARE HANDS for a player. `HeldItemRules` and
`WorldObjectToolHelper` are the pure halves beside it. Every one of the ordered permission
gates from 0.29.0 has a test; the thing that decides *what is being held when they are
asked* has none.

What the tests must fix, in the language the port already uses: selecting an empty slot
yields the bare hand and never null; changing the selected slot rebuilds the hand exactly
once; a blueprint routes to the build hand and a tool to the tool arm, which is the routing
FP4.3b's refused seventh slice turned on. That last one is the assertion that makes FP5.1(e)
safe to write, because it pins the behaviour the `canBuildOnTarget` port will have to keep.

### TT4 · The envelope FP6 is about to stand on

`WorldObject.serializeEnvelope` exists since 0.2.0 and the string `serializeEnvelope`
appears in **no test file**. FP6.2 plans to extend it with `current_state`, route it through
a `WorldObjectSave` twin, and make the per-chunk diff out of it. Writing the round-trip test
now — envelope out, envelope in, same data, same components — costs an hour and makes every
FP6 commit a comparison against a fixed point instead of against a memory.

`GroundBuildable` (10 lines) is trivial and belongs to the same commit for completeness.
`CropDropComponent` is the one that should sting: it landed at 0.49.0, days ago, under a
policy that says tests come with the port. It filters drops by the crop's current stage,
which is a table lookup with an off-by-one at both ends of the stage list.

### TT5 · The four render classes

`AnimationCreator`, `BuildGhostRenderer`, `ItemWorldRenderer` and `SpriteLoader` are named in
no test, and the reason usually given — Flame needs a game loop — **is not true in this
repo**. `test/core/render/dawnforge_game_test.dart` already boots the real game from the
real bundled assets inside `testWidgets` with `runAsync`, precisely so image decoding
happens for real. The idiom exists; nothing new enters `pubspec.yaml`.

Priority inside the four: `SpriteLoader` first, because it is the consumer of
`ContentPaths.resolveRes` and therefore the place where a bad `res://` mapping becomes a
null texture (the other end of that thread is `L-015`). Then `BuildGhostRenderer`, whose
one invariant is written down in the port plan already — the preview and the press resolve
through the same `BuildPreview`, so the ghost cannot lie about the click.

---

## 3. What this document is not

It is not a request for 21 files. Several of these belong in tests that already exist —
`ItemStack` beside the inventory tests, `DropEntry` beside `DropRules`. It is also not a
verdict on the port's quality: 88 of 109 named, with the pure domain rules tested first and
the gate tests written as gates, is the shape a healthy port has. The 21 are simply where
the policy's *with the port* slipped to *after the port*, and after the port is a debt that
compounds — FP6 turns the envelope into a file format, and FP7.7 turns `IComponentVital`
into four components.

---

## 4. The ratchet

### TT6 · Keep the number from growing

A list measured once is a list measured again in six weeks with a bigger number. The guard:
a script that computes §1's table and refuses a tree where the never-named count has
**grown** since the number written in its own header. Rule 23 applies in full — it lives in
`scripts/project/`, takes its paths from `project_paths.py`, and runs from the suite. It is
the only automation this document owns; everything else it needs is already in
`AUTOMATION_DEBT_2026-09-10.md`.

Whether it refuses or merely reports is `TT-D1`.

---

## Decision register

| ID | Blocks | Question | Recommendation |
|:---|:---|:---|:---|
| **TT-D1** | TT6 | Should the never-named guard FAIL the suite, or report and ratchet? | **Ratchet.** A guard that fails on the day it lands fails on 21 existing classes, and a guard that fails for reasons nobody intends is a guard somebody disables — which costs more than the check was worth. It records the count, refuses an increase, and prints the delta on every decrease so the list visibly drains. Flip it to a hard refusal when the count reaches zero, which is a one-line change made at the moment it is free. |
