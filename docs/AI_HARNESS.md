# Dawnforge Flutter — The AI Development Harness

> **SSOT for how AI works on this repo**: retrieval, hook guards, the suite command, and
> the lifecycle. Ported from the Godot repo's `docs/AI_HARNESS.md` (read that one for the
> full design history and rationale — §8 there records the boom-and-bust that shaped this
> lean form). `CLAUDE.md` holds the *rules of the work*; this document holds the
> *machinery around the worker*. When they overlap, `CLAUDE.md` wins.

Baseline at writing: FP0, 2026-08-25.

## 1. The lifecycle (AIDLC)

Same loop as the Godot repo: Orient → Recall → Specify → Implement → Verify → Document →
Ship → Observe → Evolve. The skills that instrument each stage are ported incrementally
(plan step FP0.9); until a skill exists here, follow its SSOT directly:

| Stage | Instrument today | SSOT |
|:---|:---|:---|
| Orient | `git log`/`git status` + `docs/refactoring/PENDING.md` | — |
| Recall | `python3 scripts/ai/search_project_knowledge.py "<q>"` | §2 |
| Specify | plans in `docs/refactoring/implementation_plan/` | port plan |
| Implement | `CLAUDE.md` rules 1–34 + the Godot repo as the spec | — |
| Verify | `python3 scripts/project/check_test_suite_is_clean.py` | — |
| Document | rule 34 (both changelogs; manual when player-visible) | `CLAUDE.md` |
| Ship | one-command bump-from-HEAD commit | `CLAUDE.md` §Parallel sessions |
| Observe | `docs/refactoring/LEDGER.md` (rule 27) | ledger header |
| Evolve | periodic sweep drains the ledger into the next plan | Godot repo's `ARCHITECTURE_EVOLUTION.md` |

## 2. Retrieval — the knowledge index

`scripts/lib/knowledge_index.py` + the two CLIs in `scripts/ai/`: BM25 (stdlib-only,
offline, bilingual en/pt-BR, diacritics folded) over `docs/**`, `scripts/**/*.md`, the
content pack, `.claude/skills/*/SKILL.md`, both changelogs, `CLAUDE.md`, and **every git
commit**. Auto-rebuilds when HEAD or a source moves; cache at
`.claude/cache/knowledge_index.json` (gitignored). `reference/` and `deprecated/` trees
are excluded structurally (rule 10).

Contract for consumers: **hits are entry points, not answers** — open the file,
`git show` the commit, verify at HEAD.

## 3. Hook guards

`.claude/settings.json` wires two hooks; both **fail-open** and both only enforce
prohibitions that already exist in writing:

| Hook | Event | Blocks / flags | Encodes |
|:---|:---|:---|:---|
| `scripts/ai/hooks/block_forbidden_git.py` | PreToolUse · Bash | `git rebase`, `git commit --amend`, `git commit` without ` -- ` pathspec, `git commit` whose message (`-m`, `-F`, `--file=`) carries AI attribution, `git commit` naming `LEDGER.md` while an ID heads two entries | §Parallel sessions, §Commit message format, ledger header |
| `scripts/ai/hooks/check_edited_file_rules.py` | PostToolUse · Edit/Write | `pauseEngine()`/`resumeEngine()`, `.paused =` writes, raw pointer reads (`.canvasPosition`/`.devicePosition`) outside `input_helper.dart` | rules 30, 11 |

Contract: exit `2` + stderr = the reason, fed back to the model; exit `0` = silence. The
PostToolUse guard is a **tripwire, not a gate**. Only mechanically-checkable,
zero-false-positive patterns belong here. Test with synthetic stdin:

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"git rebase -i HEAD~2"}}' \
  | python3 scripts/ai/hooks/block_forbidden_git.py; echo "exit=$?"
```

## 4. The suite

`python3 scripts/project/check_test_suite_is_clean.py` = `flutter analyze --fatal-infos`
+ `flutter test`. Green means both. The analyzer is half the rule set (rule 4's strict
typing lives in `analysis_options.yaml`), so an info is a failure.

## 5. Cross-repo contract

The Godot repo (`~/Documents/godot/remottely/tessera_project` — written once as
`SPEC_REPO_ROOT` in `scripts/lib/project_paths.py`, overridable by `TESSERA_SPEC_ROOT`)
is the **spec** for port
work and is read-only from here. Its knowledge index answers questions this repo cannot:
run its `search_project_knowledge.py` from its own root. The pack format is shared and
never forks (study §4).
