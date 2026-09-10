# `docs/refactoring/` — how this folder is organized

> Every document produced by a plan, audit or investigation pass lives here, and nothing
> of this kind lives anywhere else in the repo. `CLAUDE.md` rule 27 and §Key File Locations
> point at this folder; this file says what is in it and which document is live.
> Same mechanism as the Godot repo's `tessera/docs/refactoring/README.md` (study §6).

## The three drawers

| Drawer | Test for a document to live there |
|:---|:---|
| `implementation_plan/` | *could a fresh session execute this without asking anything first?* |
| `investigate/` | *does this describe what is true, rather than what to do?* (empty today) |
| `archive/` | *is this history?* (empty today) |

A document may move between drawers as it matures — `git mv` plus every inbound
reference fixed in the same commit. `LEDGER.md` and `PENDING.md` stay at the folder root
and are the only two files allowed there besides this one.

## The plan catalogue

**This table is the SSOT for which plan is live.** A plan's own header never carries the
marker — reading a header to learn whether a plan is live is how a session comes to work
a finished one.

| What | Where | State |
|:---|:---|:---|
| **Architecture ledger — where rule 27 writes** | `LEDGER.md` | always open |
| **Everything documented and not yet done — the derived index** | `PENDING.md` | refreshed by every plan commit |
| **The founding study — decisions D1–D7, scope cuts, risk register** | `../study/GODOT_TO_FLUTTER_PORT_STUDY.md` | reference, not a plan |
| **The port plan — every `FP<phase>.<step>`, gates, the decision register `D-1`…`D-8`** | `implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md` | **LIVE FRONT** (FP4 in progress; FP4.4, FP5–FP7 sliced 2026-09-10) |
| **The automation debt — the spec's 27 pipeline steps and 40 project commands mapped against this repo's 7 and 4** | `implementation_plan/AUTOMATION_DEBT_2026-09-10.md` | **LIVE, side lane** (opened 2026-09-10) — every item is executable and none blocks an `FP` step, so it is what a session picks up when the front is held by another lane |
| **Test traceability — the 21 classes no test has ever named, and what each missing test must fix** | `implementation_plan/TEST_TRACEABILITY_2026-09-10.md` | **LIVE, side lane** (opened 2026-09-10) — measured, not estimated; the one fork is whether its guard refuses or ratchets |

## What a new document must carry

The skeleton the Godot repo's `plan-doc` skill enforces, and FP0.9 will port:

1. **Name** `<SUBJECT>_<YYYY-MM-DD>.md`, SCREAMING_SNAKE_CASE, dated the day the pass ran.
2. **A "how to use this document" opening**: scope, what is explicitly *out*, the version
   it was measured at, the suite count at that version — re-measured at HEAD, not
   remembered.
3. **Every claim carries `file:line`** plus the sentence that the numbers were true at
   version X and must be re-grepped before editing.
4. **Stable item IDs** and a **progress table** updated in the same commit that lands each
   item — the table, not the git log, is the plan's state.
5. **One decision register**, each fork with what it blocks and a recommendation. Never a
   `[DECISION]` marker scattered in prose.
6. Phase headers state their **gate**.

After writing one: refresh `PENDING.md`, add the row above, and prefer a **probe over an
argument** for any decision answerable by running something.

## The loop this folder closes

Observe → the ledger (`L-nnn`, four fields, same commit as the task that found it, never
fixed there) → a periodic sweep drains entries into the next plan (`Drained` table) or
strikes them (`Struck` table, with the reason) → the plan's progress table and `PENDING.md`
say what is left. The Godot repo's `ARCHITECTURE_EVOLUTION.md` owns the full ritual; this
repo inherits it via the study.
