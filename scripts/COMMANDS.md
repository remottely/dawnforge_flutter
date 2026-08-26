# Automation Catalogue

> Every automation in the repo, by folder (rule 23). A new script lands here in the same
> commit that creates it.

## scripts/ai/ — the AI harness

| Command | What |
|:---|:---|
| `python3 scripts/ai/index_project_knowledge.py [--dry-run\|--stats]` | build the knowledge index (docs + pack + skills + changelogs + full git history) |
| `python3 scripts/ai/search_project_knowledge.py "<q>" [--k N] [--sources docs,git,…] [--json]` | BM25 search over everything the repo knows; auto-rebuilds a stale index |
| `scripts/ai/hooks/block_forbidden_git.py` | PreToolUse Bash guard (see `docs/AI_HARNESS.md` §3) |
| `scripts/ai/hooks/check_edited_file_rules.py` | PostToolUse Edit/Write tripwire (rules 30, 11) |

## scripts/project/ — whole-project operations

| Command | What |
|:---|:---|
| `python3 scripts/project/check_test_suite_is_clean.py [--analyze-only\|--test-only]` | the suite: `flutter analyze --fatal-infos` + `flutter test`; exit 0 = green |
| `python3 scripts/project/check_ledger_ids_are_unique.py [--check\|--next]` | refuse a LEDGER.md with duplicate IDs; hand out the next free one |

## scripts/pipeline/ — the content build (FP2, not yet ported)

`dawnforge.py <step>` will wrap the ordered `.md` → JSON pipeline, same step numbering as
the Godot repo.

## scripts/lib/ — shared modules (not commands)

`project_paths.py` (every path automation may use — rule 23), `knowledge_index.py`.
