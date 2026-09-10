---
version: 0.1.0
name: onboard
description: |
  Brief a fresh session on where this repo stands: what HEAD is, whether another
  session is working in the same tree right now, which plan is LIVE and which are
  side lanes, what `PENDING.md` says, which forks are still open, and what the
  next executable step is. Use at session start, on "onde paramos?", "o que temos
  pra fazer?", or before picking up any task.
---

# Onboard — orient before touching anything

Run the probes, then deliver the briefing. **Read-only: this skill changes nothing.**

The repository already holds everything a fresh session needs — HEAD, `PENDING.md`, the
plan catalogue, the progress tables — so a briefing derived from those is current, while a
handoff written by the previous session was already stale when its author stopped typing.
Never ask a session to compose the next session's prompt. Open a new chat and run this.

## 1. The probes

```bash
git log --format='%h %s' -12                       # what landed, and how fast
git status --short                                 # is somebody mid-task in this tree?
grep -n "LIVE" docs/refactoring/README.md          # which plan is the front, which are lanes
sed -n '1,12p' docs/refactoring/PENDING.md         # the derived index of everything not done
grep -c "^### L-" docs/refactoring/LEDGER.md       # how much the ledger is carrying
grep -n "^| \*\*D-" docs/refactoring/implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md
python3 scripts/project/check_test_suite_is_clean.py   # only if you are about to change code
```

## 2. Read `git status` before anything else

**Assume another session is working in this worktree — there usually is one.** A dirty tree
you did not dirty is somebody else's task in flight, and it changes what you may do:

- Their files are theirs. Do not edit, revert, or commit them.
- Shared documents (`LEDGER.md`, `PENDING.md`, both changelogs, the live plan) are the
  contested ground. `L-016` records what happens when two sessions edit one: a pathspec
  protects the index, not the file, so a commit carries the whole file including the other
  session's unfinished half. `L-017` records the same race on ledger IDs.
- Practical consequence: keep your uncommitted window on a shared document **short**, take
  the ledger ID with `check_ledger_ids_are_unique.py --next` immediately before you write
  the entry, and re-read a shared document right before committing rather than trusting the
  copy you edited twenty minutes ago.

## 3. What to read, in this order

| Question | Where the answer is |
|:---|:---|
| Which plan is live | the catalogue table in `docs/refactoring/README.md` — **never a plan's own header** |
| What is not done | `docs/refactoring/PENDING.md`, the derived index |
| What the code IS | `docs/ARCHITECTURE.md`, each section stamped with the version it was verified at |
| What was observed and not fixed | `docs/refactoring/LEDGER.md` §Open |
| What is waiting on the developer | the **Decision register** at the end of the live plan (`D-n`), plus each side lane's own register |
| The rules | `CLAUDE.md` — 34 of them, non-negotiable |
| The harness itself | `docs/AI_HARNESS.md` |

There is one front plan and several side lanes. A lane exists so a session has executable
work when the front is held by somebody else — picking a lane item is a normal choice, not
a fallback.

## 4. The briefing to deliver

Six short answers, in the user's language, no preamble:

1. **HEAD** — version, subject, and the cadence of the last few commits.
2. **Who else is here** — what `git status` shows uncommitted, and whose it is.
3. **The front** — which plan is LIVE and which phase it is in.
4. **The lanes** — one line each, with what makes each one pickable.
5. **The forks** — every open `D-n` by number and one clause on what it blocks. This is
   the part that decides what you may NOT start.
6. **The next executable step** — one named step that needs no decision, with why it is
   next.

## 5. Then stop

Do not start work in the same breath as the briefing unless the user asked for both. The
point of orienting is that the next choice is informed, and the person reading is the one
who makes it.
