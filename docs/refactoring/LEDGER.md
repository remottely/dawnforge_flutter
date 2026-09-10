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

### L-004 · Rule 32's ritual names a script this repo does not have

- **Lens:** harness / persistence
- **Evidence:** `CLAUDE.md` rule 32 and §Execution Workflow step 6 both end a shape-changing commit with `python3 scripts/project/reset_local_save.py`; at 0.24.0 `scripts/project/` holds only `check_ledger_ids_are_unique.py` and `check_test_suite_is_clean.py`. `FLUTTER_PORT_PLAN_2026-08-25.md` FP0.6 lists the port ("`reset_local_save.py` port") and FP6.3 lists proving it, and `PENDING.md` #1 records only FP0.9 as the open FP0 item — so the gap is invisible from the index.
- **Cost of leaving it:** every commit that changes a persisted shape performs a ritual whose command fails, and the failure is silent in the sense that matters — the commit is correct today only because FP6 has not landed, so nothing persists. The first save written before this script exists will be the one nobody can clear, and the rule that was supposed to make that cheap will have been unenforceable for however many commits.
- **Found while:** FP4.2b slice 4 — `InventoryData.serialize` gained `selected_slot`, which is exactly the rule-32 trigger.

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

### L-008 · The commit guard makes a merge commit unreachable, and the way around it skips the guard

- **Lens:** harness / git guard
- **Evidence:** `scripts/ai/hooks/block_forbidden_git.py:179` refuses any `git commit` without `-- <pathspec>`, mirroring the flow `CLAUDE.md:177` documents; git itself refuses a pathspec commit while `MERGE_HEAD` exists ("cannot do a partial commit during a merge"). At 0.45.3 the two rules are jointly unsatisfiable: a commit with two parents cannot be made through the documented command. The escape used was `GIT_EDITOR=true git merge --continue` with `.git/MERGE_MSG` pre-written — `merge` is not the `commit` subcommand (`:171`), so the hook never sees it.
- **Cost of leaving it:** the hook exists to stop a bare commit sweeping in a parallel session's staged work, and the only route to a merge commit is precisely a bare commit of the whole index — so the one case the guard cannot inspect is the case that commits the most. The bypass is silent and undocumented: nothing in `CLAUDE.md` or the hook names it, so the next session either abandons the merge or finds `merge --continue` on its own and commits the index unchecked, having read no warning that it must verify it by hand first. Both outcomes are worse than a hook that recognised `merge` and asked for the same proof.
- **Found while:** 0.45.3 — recording the legacy `main` lineage on `dev` with `git merge -s ours`, after the hook refused the commit that would have carried it.

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

## Drained

| ID | Title | Drained into |
|:---|:---|:---|
| L-009 | The edit tripwire carries three of the five patterns FP0.5 promised | FP0.14 (0.57.0) — the fourth added (`\bdynamic\b` under `lib/`), the fifth (`timeScale`) dropped in writing in the hook header and `docs/AI_HARNESS.md` §3 |
| L-006 | Nothing notices when an imported pack document drifts from the spec's | FP0.11 (0.56.0) — `scripts/content/check_pack_snapshot_matches_spec.py`; its first green run recorded 28 forked documents and 67 forked keys, `cave_elevation_drops` among them, and opened `L-014` |
| L-003 | Cross-repo pointers name a Godot repo path that no longer exists | FP0.13 (0.53.0) — `SPEC_REPO_ROOT` in `scripts/lib/project_paths.py`, cited by `CLAUDE.md`, `docs/AI_HARNESS.md` §5 and the study's §1 table |

## Struck

| ID | Title | Why struck |
|:---|:---|:---|
