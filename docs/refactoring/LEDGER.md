# Architecture Ledger

> Where rule 27 writes. One entry per structural observation found mid-task that was
> **not** the task. Four mandatory fields: `Lens`, `Evidence` (`file:line` + version),
> `Cost of leaving it`, `Found while`. IDs are sequential (`L-001`, `L-002`, …) and
> **never reused** — plans and `PENDING.md` cite entries by ID, so a collision is
> ambiguous forever. `python3 scripts/project/check_ledger_ids_are_unique.py --next`
> hands out the next free one; the commit hook refuses a ledger with a duplicate.
>
> Same mechanism as the Godot repo (`docs/ARCHITECTURE_EVOLUTION.md` there owns the
> full loop; this repo inherits it via the study, §6).

## Open

### L-005 · Every prop carries health and drops, authored or not

- **Lens:** components / streaming cost
- **Evidence:** `lib/src/core/base/world_objects/props/prop.dart:29-33` (0.30.0) mounts `HealthComponent` and `DropComponent` on every prop unconditionally, and `ProceduralSpawnSystem` scatters up to `maxPropsPerChunk` per chunk across a 5×5 boot window (`engine_constants.dart:51`, `proceduralChunkLoadRadius`). A decorative tuft with no `drops` and no authored `base_max_health` gets both anyway: a component map, two objects, and two entries walked by `core.update` every fixed step. The spec attaches these per scene instead, so a prop that cannot be harvested does not carry the machinery for it.
- **Cost of leaving it:** the waste is per-prop and the props are the most numerous hosts in the world, so it scales with exactly the thing the streaming budget already guards (FP3.4's 1200µs). It is also a correctness smell before it is a cost one: a prop with no loot table still answers `drop`, and a decoration still answers `health`, so "can this be broken" reads as yes everywhere and only the authored `allowedTools` says otherwise.
- **Found while:** FP4.3a slice 5 — giving props the death path harvest needs.

### L-007 · Which props are resident in a chunk is owned by the system named for ONE way they get there

- **Lens:** systems / ownership
- **Evidence:** `lib/src/core/systems/spawning/procedural_spawn_system.dart:51-66` at 0.39.0 holds `_chunkContent`, the map of every prop resident in every chunk, and the unload that releases them. Since FP4.3b props also arrive by hand, so `WorldPlacementHelper.placeProp` has to call `adoptPlacedProp` on a *spawn* system to have a built smelter released, and the system needed a second field (`_populatedChunks`) to keep "has been scattered" apart from "lives here" — two facts that were one only while the scatter was the sole author.
- **Cost of leaving it:** the residency list is the thing that frees grid tiles, and every future way a prop can enter the world (FP4.4's crops from a transform, FP4.5's craft output, FP7's respawn and rehydration) has to know to register with a system whose name says it is about procedural scatter. A path that forgets does not fail loudly: the prop simply stays drawn, ticked and holding its tiles at a place the player has left. The fix is a rename and a move, not a redesign — the bookkeeping is already correct, it is only filed under the wrong owner.
- **Found while:** FP4.3b slice 5 — giving the built prop the same exit every other prop has.

### L-010 · The player manual has no section map, and its page names already diverge from the sibling's

- **Lens:** docs / rule 34
- **Evidence:** `games/dawnforge/docs/manual/{en,pt-BR}/` at 0.48.0 hold four pages each (`backpack.md`, `gathering.md`, `item-bar.md`, `world.md`) and no `README.md`; the spec's `games/dawnforge/docs/manual/README.md` carries a fifteen-page section map ("a sixteenth page needs a line in this table first") plus `TEMPLATE.md`, and its pages for the same ground are `interface.md` and `gathering-and-farming.md`. Nothing here checks that `en/` and `pt-BR/` hold the same filenames with the same heading order — the spec's `tessera/scripts/docs/check_manual_mirrors.py` does, and `CLAUDE.md` rule 34 states the mirror obligation without a guard.
- **Cost of leaving it:** the failure is silent in the way that matters — a page that exists only in English is noticed by a Brazilian seven-year-old, who is not in this repository — and the divergence in names is quiet cross-track drift of exactly the kind `L-006` records for the pack: two manuals for one game whose "how does the forge work" lives under two different filenames. FP4.4 and FP4.5 owe three new pages between them; without a map each is named on the spot.
- **Found while:** 2026-09-10 re-slicing the port plan — naming the manual page each FP4/FP5 slice owes.

### L-012 · The two steps that write the most bytes are the two the suite cannot check

- **Lens:** pipeline / rule 23
- **Evidence:** `scripts/pipeline/02_extract_sprites_from_atlas.py` and `03_fill_missing_sprite_placeholders.py` at 0.53.0 carry `--dry-run` and no `--check`; every other step (04, 05, 10, 11, 26) carries both. `CLAUDE.md` rule 23 requires `--check` "when it generates a committed file", and `assets/generated/` is tracked — 126 files, 58 of them PNGs these two steps cut. `scripts/COMMANDS.md` lists the two commands without the mode, so the omission reads as intended.
- **Cost of leaving it:** the suite can prove that every JSON document on disk is what the pipeline would emit today, and cannot prove it for a single pixel. An atlas edited over there, a `atlas_position` moved, a sprite re-cut by hand — each survives every green suite until somebody looks at the game. It is also the gap that hides the next one: with no `--check` there is no declaration of what a step wrote, and without that declaration the unclaimed-output sweep (step 99, never ported) cannot be written at all.
- **Found while:** 2026-09-10 — mapping the spec's 27 pipeline steps against this repo's 7 for `AUTOMATION_DEBT_2026-09-10.md`.

### L-013 · Two decision ID spaces, one hyphen apart, both called decisions

- **Lens:** docs / traceability
- **Evidence:** `docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md:206-212` registers `D1`–`D7` (settled, historical, cited by `CLAUDE.md`'s header and by FP steps as "decision D2"); `FLUTTER_PORT_PLAN_2026-08-25.md`'s decision register holds `D-1`–`D-8` (open, each blocking a step), added 2026-09-10 at 0.48.1. Nothing declares that they are different spaces, and `scripts/project/` has no twin of the spec's `check_decision_ids_are_unique.py`, which exists over there for exactly this.
- **Cost of leaving it:** "D-4" and "D4" are one keystroke apart and name unrelated things — a manual page name and the no-pause sim shape. The failure is not a crash but a misread: a session that follows the wrong one implements against a decision nobody took. The ledger already solved this problem for `L-nnn` (never reused, a script hands out the next free one) and the register was written without inheriting the solution.
- **Found while:** 2026-09-10 — inventorying the spec's 40 project commands against this repo's 4.

### L-014 · Nineteen things that hold nothing declare a thirty-slot bag

- **Lens:** content / data defaults
- **Evidence:** `lib/src/core/resources/i_world_object_data.dart:35,57` defaults `inventorySize` to `30` (constructor and `reader.intOr('inventory_size', 30)`), and at 0.56.0 nineteen pack documents author exactly that: `t1_prop_rock_moss`, `t1_prop_rock_coal`, `t1_prop_vein_copper`, `t1_prop_grass_wild`, every `*_prop_crop_*`, `t1_prop_soil`, `t1_ground_buildable_terrain` and `t1_ground_buildable_bridge_palm` among them. The same documents in the spec author `0`; the spec reserves a non-zero size for things that are containers. Nothing here reads the field yet, which is why a plank bridge with thirty slots has cost nothing so far.
- **Cost of leaving it:** the default is the fallback rule 5 forbids wearing a data class's clothes — `intOr(..., 30)` answers "how big is this object's bag" for a document that never said, and every snapshot taken since has been normalised to that answer rather than to the object. The bill arrives with the first thing that opens a container: FP4.5(f)'s workstation panel asks a prop for its inventory, and every rock in the world will say thirty. The repair is two edits and a sweep — author `0` where nothing is held, and make the field required rather than defaulted — but only while the field is still inert.
- **Found while:** FP0.11 — building the pack-drift guard, whose first green run listed the nineteen as the largest single fork between the two packs.

### L-015 · Two fifths of the pack references the generated JSON carries resolve to nothing

- **Lens:** content pipeline / assets
- **Evidence:** at 0.53.0 the emitted JSON under `assets/generated/dawnforge/` holds **95** `res://data/…` references. `ContentPaths.resolveRes` (`lib/src/core/shared_logic/definitions/content_paths.dart:31-45`) maps each to a bundled asset key; 58 (every spritesheet) resolve to a committed file and **37 do not** — all of them `.wav` paths under `data/audio/`, a pack family that has never crossed into `assets/`. Nothing reports this: no step validates that an emitted reference resolves, and the analyzer cannot see inside a JSON string.
- **Cost of leaving it:** today the unresolved 37 are harmless because nothing plays a sound, and that is precisely what makes the hole invisible when a **new** one appears. The next family imported with a dangling reference joins 37 others and reads as normal. Rule 5 says the crash is the feature, but the crash lands at render — naming a null texture — instead of in the pipeline, which would name the document and the field.
- **Found while:** 2026-09-10 — probing what the spec's `check_referenced_assets_are_committed.py` would report here.

### L-016 · The commit ritual's pathspec protects the index, not the file

- **Lens:** harness / parallel sessions
- **Evidence:** `CLAUDE.md` §Parallel sessions commits with `git commit -F <msg> -- <task files>`, and `scripts/ai/hooks/block_forbidden_git.py:179` refuses a `git commit` without a pathspec — the pair exists so one session cannot sweep another's staged work into its commit. On 2026-09-10 two sessions worked in this one worktree and it happened three times anyway, in both directions: `3ab7a9ab` (0.54.0) carried another session's unfinished `LEDGER.md`, `PENDING.md` and port-plan edits, placeholders included; `afa5c72c` (0.55.0) carried that session's `## 0.0.0-NEXT` changelog section and stamped it, leaving `games/dawnforge/CHANGELOG.md` with `## 0.55.0` twice at HEAD until the next commit repaired it. A pathspec names a FILE; git commits the file's whole working-tree content, and both sessions edit the same six shared documents (both changelogs, `LEDGER.md`, `PENDING.md`, the plan, `COMMANDS.md`) on every single commit.
- **Cost of leaving it:** the shared documents are exactly the ones the rules make mandatory per commit (rule 27, rule 34), so the collision is not occasional — it is once per commit per session, and it lands silently: the sweeping commit is green, its message describes half of what it contains, and the swept session finds its own text already committed under someone else's version number. The changelog case is the loud one only because `check_changelog_is_ordered.py` (0.51.0) now catches it; the ledger case is silent, and a renumbered or dropped entry there is the thing plans cite by ID forever. Two shapes would each close it: a commit script that refuses a listed file whose diff contains hunks the session did not write, or one worktree per session (`git worktree add`), which is what the delivery track's ten lanes do.
- **Found while:** FP0.11 — committing the pack-drift guard, whose ledger entry was renumbered twice and dropped once by another session's commits in the same hour.

### L-017 · Two sessions cannot both append to a shared document, and the ID handout races

- **Lens:** harness / parallel sessions
- **Evidence:** on 2026-09-10 two sessions took `L-011` within minutes of each other (`check_ledger_ids_are_unique.py --next` is a read of the file, and both read it before either wrote), the commit hook refused the collision, both renumbered, and both landed on `L-014`. `CLAUDE.md` §Parallel sessions answers the *version* collision — derive from `HEAD` in the same command as the commit — and says nothing about this one. The documented commit is `git add <files> && git commit -F msg -- <files>`, which commits the file's staged content whoever staged it, so the only way out was to rebuild `LEDGER.md` from `HEAD` plus one session's own entries by hand, commit that, and restore the other session's work afterwards.
- **Cost of leaving it:** every shared document is exposed — `LEDGER.md`, `PENDING.md`, both changelogs, the plans — and the exposure grows with the number of sessions, which is the direction this repo is going. The failure has two shapes and only one of them is loud: the ID collision is caught by a hook, while a commit that quietly sweeps another session's in-flight edit to the same file is caught by nobody. The repair is manual, undocumented, and was invented twice today.
- **Found while:** 2026-09-10 — writing the automation, test and pack-import documents while another session drained FP0.10–FP0.15.

### L-018 · The third thing D4 keeps open has no subject in the code

- **Lens:** simulation shape / study decision
- **Evidence:** study §5 and `D4` name three things that keep the multiplayer door open — no pause, **input as intents**, and systems owning their serialized sections. Two are real: rule 30 is enforced by a hook and FP6.1 plans the sections. The third is nowhere. At 0.64.0 the fixed step reads the device directly (`lib/src/core/render/dawnforge_game.dart:320-324`: `InputHelper.getMovementVector()` applied straight to `player.movement`), and the verb does the same (`lib/src/core/base/world_objects/actors/player/actor_player.dart:63`: `usePrimaryAction(aimAtCursor())`). `grep -rn 'Intent' lib/src` returns nothing, and no `FP` step plans one.
- **Cost of leaving it:** a door that is written down as open and is closed by construction is worse than one nobody claimed — the study's own §5 table is the thing a future session would read before assuming the shape is there. The cost also grows monotonically: today three call sites turn a device reading into a simulation change, and FP4.5(e)'s interact, FP4.4(g)'s planting and every FP7.7 verb each add one. The same layer is what a deterministic replay would consume, which is the assertion `Splitmix32` currently has no way to make (`TEST_TRACEABILITY_2026-09-10.md` TT1). Note what this is NOT: rule 24 is satisfied — the polling happens in `update(dt)`, exactly where that rule puts it.
- **Found while:** 2026-09-10 — reading the study's scope cuts while writing §7.1's status pass.

### L-019 · The index you are told to read first is 3,400 words long

- **Lens:** docs / onboarding cost
- **Evidence:** `docs/refactoring/PENDING.md` at 0.65.0 is 16 rows, **3,400 words, 22 KB**, in a five-column table whose longest single row is **525 words on one line**. Its own header says "Read this first when onboarding", and `docs/refactoring/README.md` calls it "the derived index". Four of the longest rows were written on 2026-09-10, so this is a recent and accelerating shape, not an old one.
- **Cost of leaving it:** an index costs less than the thing it indexes or it is not an index. Reading `PENDING.md` now costs more than reading the port plan's progress table, which is the artifact it derives from, so the cheap first read a fresh session is promised does not exist and the expensive one is disguised as it. Most of the prose is also duplicated — the plan's own step carries it — so the drift is the second cost: two copies of one story, one of them not maintained by whoever edits the step. The repair is a MOVE, not a delete: rows 7, 8 and 9 carry breakdowns of finished work that no plan holds, and those belong in an `archive/` document rather than in an index or in a bin.
- **Found while:** 2026-09-10 — appending the fourth row of the day while writing the side-lane documents.

### L-020 · What a press is allowed to mean is decided by whoever listens for it

- **Lens:** input / rule 25's shape
- **Evidence:** `lib/src/core/systems/input/input_helper.dart:95-124` (0.67.0) raises every discrete intent unconditionally — a hotbar digit, the page flip, the bag toggle and cancel all leave the source with no idea what is on screen. Whether the press may act is then re-decided at four unrelated places (`dawnforge_game.dart:321`, `actor_player.dart:60`, `actor_player.dart:80`, `build_ghost_renderer.dart:71`) and at a fifth that does not ask at all (`hotbar_view.dart:70-72`), so pressing `3` with the bag open still changes what is in the player's hand. The spec answers this centrally: `InputActionCatalog.CONTEXTS` declares the contexts each of its 51 actions may fire in and `is_active(action)` is asked once, at the source, with a build failure for any action nobody classified.
- **Cost of leaving it:** it grows by one forgotten guard per new subscriber, and the forgetting is silent — the press does something reasonable in the wrong context rather than crashing, which is rule 5 inverted. It also blocks `TEXT_ENTRY`: `dawnforge_game.dart:339-345` returns `KeyEventResult.handled` for every key, so the first text field FP6.4 needs cannot be typed into, and the reason will look like a Flutter focus problem rather than a missing context table.
- **Found while:** 2026-09-10 — measuring rule 12's parity across the two repos for `INPUT_PARITY_2026-09-10.md`.

### L-021 · The one string the player reads that no translation guard can see

- **Lens:** content / rule 19 at the pack boundary
- **Evidence:** `interaction_prompt` is authored as finished English in the pack — 11 documents at 0.67.0, seven of them non-empty (`"Harvest [E]"` ×6, `"Interact [E]"` ×1, `games/dawnforge/data/forge_almanac/`). It reaches the player through `InteractableComponent.prompt` (`lib/src/core/components/i_interactable/interactable_component.dart`, 0.67.0) and the hover indicator FP5.1(e) will draw it verbatim. `scripts/project/check_translation_keys.py` (FP0.17) only reads `tr()` calls under `lib/`, so a display string living in a CONTENT field is invisible to it, in both repos: the spec's `i_prop_interactable.gd:42` assigns it raw too, and its own `ui_strings` never carries a key for it.
- **Cost of leaving it:** the first locale switch (FP5.3) leaves every prompt in English while every other word on screen turns, and nothing fails — the guard is green because the string was never a key. It is also the key's shape that is wrong, not just its absence: `[E]` bakes a keyboard binding into content, so `D-1`'s rebinding to `E` was correct only by accident and a gamepad reads a keyboard key off a bush. The repair is one pack field (`interaction_prompt_key`) plus the binding resolved at draw time, and it is cheapest before the indicator exists.
- **Found while:** 2026-09-10 — porting FP4.5(e), reading the two interaction fields across the pack.

## Drained

| ID | Title | Drained into |
|:---|:---|:---|
| L-008 | The commit guard makes a merge commit unreachable, and the way around it skips the guard | FP0.12 (0.61.0) — `scripts/project/commit_merge.py` proves the index; the hook refuses `git merge --continue` and no longer reads past an environment prefix |
| L-004 | Rule 32's ritual names a script this repo does not have | FP0.10 (0.58.0) — `scripts/project/reset_local_save.py`, landed before FP6.1 writes the first save; FP6.3 still owes the proof against a real one |
| L-009 | The edit tripwire carries three of the five patterns FP0.5 promised | FP0.14 (0.57.0) — the fourth added (`\bdynamic\b` under `lib/`), the fifth (`timeScale`) dropped in writing in the hook header and `docs/AI_HARNESS.md` §3 |
| L-006 | Nothing notices when an imported pack document drifts from the spec's | FP0.11 (0.56.0) — `scripts/content/check_pack_snapshot_matches_spec.py`; its first green run recorded 28 forked documents and 67 forked keys, `cave_elevation_drops` among them, and opened `L-014` |
| L-003 | Cross-repo pointers name a Godot repo path that no longer exists | FP0.13 (0.53.0) — `SPEC_REPO_ROOT` in `scripts/lib/project_paths.py`, cited by `CLAUDE.md`, `docs/AI_HARNESS.md` §5 and the study's §1 table |

## Struck

| ID | Title | Why struck |
|:---|:---|:---|
