---
version: 0.1.0
name: suite
description: |
  Run this repo's verification suite and judge the result honestly — the five
  checks behind `check_test_suite_is_clean.py`, how to triage a Dart failure,
  and the one known load-dependent flake so nobody loses an afternoon to it.
  Use before any commit, after editing anything under `lib/` or `test/`, on
  "roda os testes", and whenever a run comes back red.
argument-hint: "[--analyze-only|--test-only]"
---

# Suite — run it right, judge it right

## 1. The command

```bash
python3 scripts/project/check_test_suite_is_clean.py
```

Exit 0 or it did not pass. `CLAUDE.md` §Execution Workflow step 3 also says **never in the
background** — run it inline and wait for the code. It takes a few minutes cold, seconds
warm.

Five checks run in order, each named in the output:

| Step | What it proves | Its plan step |
|:---|:---|:---|
| `changelog` | both changelogs newest-first, mirrored, categories in their fixed order | FP0.16 |
| `translations` | every literal `tr('key')` in `lib/` exists in every emitted locale table | FP0.17 |
| `manual` | `en/` and `pt-BR/` hold the same filenames with the same heading structure | FP0.15 |
| `analyze` | `flutter analyze --fatal-infos` at zero issues | — |
| `test` | the whole `test/` tree, which mirrors `lib/src/` | — |

`--analyze-only` and `--test-only` exist for iteration. **Neither is a commit's proof** —
the three document checks are half of rule 34, and a green `--test-only` says nothing
about them.

## 2. Why the analyzer is not a lint step

`analysis_options.yaml` pins `strict-casts`, `strict-raw-types` and `strict-inference`, so
rule 4's typing is enforced there and nowhere else. An info-level message is a failure,
which is why the flag is `--fatal-infos`. Do not silence one with an ignore comment; fix
the type.

## 3. Triage — a Dart failure, in order

1. **Read the assertion, not the test name.** The suite's failure summary prints only the
   name, and the useful part scrolls past above it. Re-run the one file:
   `flutter test test/path/to/the_test.dart` and read the whole block.
2. **Ask whether the message is an `assert` from `lib/`.** This codebase crashes on
   invalid state by design (rule 5), so an assertion from a component or a factory usually
   means the *test's setup* is wrong, not the code.
3. **Check whether the tree is yours.** Another session may be mid-task in this worktree
   (`CLAUDE.md` §Parallel sessions). `git status --short` before concluding that your
   change broke something you never touched.
4. **Re-run the single file before re-running everything.** It is seconds instead of
   minutes, and it separates a real failure from §4.

## 4. The one known flake, so you do not chase it

`test/core/systems/world/chunk_streaming_system_test.dart` → *"gameplay budget: one frame
advances but never swallows a flood"* can fail in a full-suite run and pass when run
alone. It asserts against a 1200µs wall-clock frame budget, so it is sensitive to what
else the machine is doing — several agent sessions and their Flutter compilers at once is
enough. `L-024` in `docs/refactoring/LEDGER.md` carries the measurement and the two
possible repairs.

**This is a reason to re-run, never a licence to ignore red.** If any other test fails, or
if this one fails on an idle machine, it is real. Say so in the commit conversation rather
than re-running until it turns green — that is the exact behaviour the ledger entry warns
about.

## 5. Before you say it passed

Report the exit code and the step that failed, if any. "The suite is green" means all five
steps printed `✅` and the script exited 0. A step that printed a warning it could not
check — the manual's section map, which waits on `D-4` — is not a pass and says so in
words.
