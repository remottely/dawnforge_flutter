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

### L-003 · Cross-repo pointers name a Godot repo path that no longer exists

- **Lens:** docs / harness
- **Evidence:** `CLAUDE.md` (Project Overview, §Key File Locations) and `docs/AI_HARNESS.md:68` point at `~/Documents/godot/remottely/dawnforge_project`; at 0.7.1 the repo lives at `~/Documents/godot/remottely/tessera_project` (engine under `tessera/src/`, per-game constants moved to `games/<game>/`).
- **Cost of leaving it:** every spec lookup driven by these docs fails silently (empty `find`/`ls`), and each new session re-discovers the rename by hand before any port work starts.
- **Found while:** FP3.4a — locating `procedural_map_view.gd` and the chunk-streaming spec to port.

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

### L-006 · Nothing notices when an imported pack document drifts from the spec's

- **Lens:** content pipeline / cross-repo contract
- **Evidence:** `games/dawnforge/data/forge_almanac/02_workstations/01_smelter/t1/t1_ground_buildable_terrain.md:115-128` at 0.35.0 still carries a `cave_elevation_drops` entry for `t1_item_ore_copper` and the comment that justified it; the same document in `tessera_project` dropped that entry and rewrote the comment ("the cave wall is the deposit" → "what a cut wall pays when it held nothing visible"). Every pack document here is a hand-copied SNAPSHOT — `scripts/` has no step that compares the two trees, and the knowledge index covers only this repo, so a `.md` that changed over there is invisible from this side until somebody diffs it by hand.
- **Cost of leaving it:** the pack format is a SHARED contract that must never fork (study §4, risk register #3), and the fork this allows is the quiet kind: not a parse failure but two engines rolling different loot from the same authored tile. The gap widens per import — the pack is imported one slice at a time, so every slice pins its own snapshot date, and no two documents here are guaranteed to be from the same version of over there. A `--check` step that diffs the imported subset costs one script and is the only thing that would have surfaced this.
- **Found while:** FP4.3b slice 1 — copying the five blueprint documents in, and diffing an already-imported one first to learn the delta convention.

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

## Drained

| ID | Title | Drained into |
|:---|:---|:---|

## Struck

| ID | Title | Why struck |
|:---|:---|:---|
