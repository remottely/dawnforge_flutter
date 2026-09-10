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

## scripts/pipeline/ — the content build

`dawnforge.py` (repo root) wraps the ordered `.md` → JSON pipeline; step numbering is
shared with the Godot repo. Runs via the repo `.venv` (`requirements.txt`).

| Command | What |
|:---|:---|
| `.venv/bin/python dawnforge.py sprites [--dry-run]` | step 02: cut every authored sprite out of the pack atlas (Pillow) into `assets/generated/<game>/…` |
| `.venv/bin/python dawnforge.py placeholders [--dry-run]` | step 03: fill missing sprites with `data/templates/sprites/` tier placeholders |
| `.venv/bin/python dawnforge.py import [--dry-run\|--check]` | step 04: almanac `.md` → `assets/generated/<game>/forge_almanac/**.json` + `manifest.json` |
| `.venv/bin/python dawnforge.py translations [--dry-run\|--check]` | step 05: the almanac's `translations:` blocks **and** the `strings:` blocks under `data/ui/` → `assets/generated/<game>/locales/<locale>.json`; `--check` also fails on cross-locale holes |
| `.venv/bin/python dawnforge.py component-keys [--dry-run\|--check]` | step 10: component classes → `lib/src/generated/component_keys.dart` (rule 16) |
| `.venv/bin/python dawnforge.py biome-terrain [--dry-run\|--check]` | step 11: `world/procedural/*.md` terrain densities → `assets/generated/<game>/world/biomes/**.json` + `manifest.json` |
| `.venv/bin/python dawnforge.py loadouts [--dry-run\|--check]` | step 26: `progression/*.md` starting loadouts → `assets/generated/<game>/progression/*.json` + `manifest.json`; every entry id must be an authored item document |
| `.venv/bin/python dawnforge.py full [--check]` | every ported step, in order |

## scripts/lib/ — shared modules (not commands)

`project_paths.py` (every path automation may use — rule 23), `knowledge_index.py`.
