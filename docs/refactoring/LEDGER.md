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

## Drained

| ID | Title | Drained into |
|:---|:---|:---|

## Struck

| ID | Title | Why struck |
|:---|:---|:---|
