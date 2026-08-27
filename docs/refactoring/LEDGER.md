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

## Drained

| ID | Title | Drained into |
|:---|:---|:---|

## Struck

| ID | Title | Why struck |
|:---|:---|:---|
