# Automation debt — every script the spec has and this track does not

> **How to use this document.** It answers one question: *of the automation the delivery
> track runs, what does this port owe, what does it not, and why.* Each owed item is
> executable without asking anybody anything — a named spec twin, a `--check` mode, a
> `scripts/COMMANDS.md` row, `CLAUDE.md` rule 23 in full. The forks that genuinely need
> the developer are at the end (`AD-D1`…`AD-D3`) and **nothing above them waits on one**.
>
> **Out of scope:** the gameplay port (that is `FLUTTER_PORT_PLAN_2026-08-25.md`, and the
> `FP` ids here are references to it, never restatements), any script that authors pack
> content (§6.2 says why), and anything the second dimension of the Godot repo needs.
>
> **Measured 2026-09-10 at `0.53.0`** against the spec at **`tessera 0.440.4`**, whose
> `tessera/scripts/` holds 27 pipeline steps, 40 project commands, 12 AI-harness commands
> and 10 hook guards; this repo holds **7**, **4**, **2** and **2**. Every `file:line` and
> every count below was true at those two versions and must be re-measured before use —
> a document that is read as current a month from now is a document that lies.
>
> **Suite at the measurement:** `flutter analyze --fatal-infos` clean, `flutter test`
> green at SUITE_COUNT tests.

## Progress

| ID | Item | Owed because | State |
|:---|:---|:---|:---|
| **AD1.1** | `--check` for pipeline steps 02 and 03 | rule 23 (`--check` when it generates a committed file); `L-012` | pending |
| **AD1.2** | step 99, the unclaimed-output sweep | a renamed document leaves its old JSON behind, tracked | pending |
| **AD1.3** | the step map in `COMMANDS.md` | our step 11 folds two spec steps and matches neither number | pending (`AD-D1`) |
| **AD2.1** | `check_pipeline_check_coverage.py` | a `--check` that reports success for work it did not do | pending |
| **AD2.2** | `check_decision_ids_are_unique.py` | two decision ID spaces, no guard; `L-013` | pending |
| **AD2.3** | `check_referenced_assets_are_committed.py` | 37 of 95 `res://` references resolve to nothing; `L-015` | pending |
| **AD2.4** | `check_version_artifacts_agree.py` | the version lives in three files stamped by one shell line | pending |
| **AD2.5** | `check_python_scripts_compile_without_warnings.py` | the cheapest guard in the tree; clean today | pending |
| **AD2.6** | `check_no_debug_probe_markers.py` | zero markers today, which is the moment to fix it in place | pending |
| **AD2.7** | the suite refuses a run that is green but noisy | ours reads the exit code only | pending |
| **AD2.8** | every generated folder is declared in `pubspec.yaml` | Flutter bundles only what is declared; 27 of 27 correct today | pending |
| **AD3.1** | `stamp_changelog_section.py` | the `sed` in `CLAUDE.md` has already been paid for once here | pending |
| **AD3.2** | `commit_task_files.py` | the ritual is a shell recipe a human retypes each commit | pending (`AD-D3`) |
| **AD4.1** | `check_harness_machinery.py` | four guards and no test over any of them | pending |
| **AD4.2** | `summarize_ledger_entries.py` | the ledger is read whole or not at all | pending |
| **AD4.3** | `decision_inbox.py` | 11 open forks and no surface that lists them | pending |
| **AD4.4** | `report_runway.py` | how much executable planning is left, measured | pending |
| **AD5.1** | the four content validators | an imported document can be wrong in four mechanical ways | pending |

---

## 1. The pipeline

### 1.1 The step map

Every numbered step the spec runs, and what this track does with it. `tessera.py` runs
27; `dawnforge.py full` runs 7. **The gap is not debt by default** — three quarters of it
belongs to a dimension this repo does not have.

| Step | What it does over there | Here |
|:---|:---|:---|
| 00 | design tokens → `default_theme.tres` | **N/A as written** — a Godot theme resource. The tokens themselves are `D-7` in the port plan (system font until FP5.2 lands); a Dart twin emits a token file, not a theme. |
| 02 | atlas → sprite PNGs | **ported** — owes `--check` (AD1.1) |
| 03 | placeholder sprites | **ported** — owes `--check` (AD1.1) |
| 04 | almanac `.md` → resources | **ported** as JSON (study D3) |
| 05 | translation tables | **ported** (two sources since 0.20.0) |
| 06 | islands → resources | **not owed yet** — island mode is unported and the port is procedural-only (FP7.2 records that the spec's respawn manager is island-mode). Owed the day FP7 picks islands. |
| 08 | `.gd` SSOT → generated C# constants | **N/A, number reserved** — that step exists to keep two languages agreeing inside one engine. Here `game_constants.dart` *is* the SSOT and there is no second language to generate. |
| 09 | procedural spawns → resources | **folded into our step 11** — `prop_entries`, `actor_entries` and `max_*_per_chunk` come out in the same biome JSON (`assets/generated/dawnforge/world/biomes/biome_forest_data.json`) |
| 10 | component keys | **ported** (rule 16) |
| 12 | `sfx_defaults.md` → resource | **owed → FP7.9**, with the `data/audio/**` crossing |
| 13–22 | blocks, clusters, billboards, top atlas, and the five world3d rebuilds | **N/A** — the block dimension is the Godot repo's second ground. This track has one. |
| 23 | mirror the pack contract into a sibling *game* | **N/A as written** — it mirrors between two games of one Godot family. The cross-*repo* analogue is FP0.11's drift check, which is a different question (are the two copies of one document equal) with a different answer. |
| 24 | `ui_*_config.md` → resources | **owed, split**: `ui_anim_config.md` → FP5, `ui_sound_config.md` → FP7.9. Neither document has crossed into `games/dawnforge/data/ui/`, which today holds `ui_strings.md` and `sprites/` only. |
| 25 | `procedural_<biome>.md` → biome resources | **folded into our step 11** |
| 26 | starting loadouts | **ported** 0.50.0 |
| 27, 28 | models and the render contract they must meet | **N/A** — voxel |
| 99 | delete every file under `generated/` that no step claims | **OWED — AD1.2** |

### AD1.1 · `--check` for steps 02 and 03

Rule 23 says a script that generates a committed file carries `--check`. `assets/generated/`
is tracked (126 files, 58 of them PNGs cut by these two steps), and both steps carry
`--dry-run` and no `--check`. So the two steps that write the most bytes are the two the
suite cannot ask "is what is committed what you would write today?".

The shape is the one every other step here already uses: build the output in memory,
compare against what is on disk, exit 1 naming the first file that differs and the count of
the rest. For step 02 the comparison is the PNG bytes; for step 03 it is which placeholder
was chosen for which document, which is cheaper to compare than the image and is the part
that actually drifts (a document gains a real sprite and the placeholder should disappear —
that disappearance is AD1.2's job to notice).

Lands with AD2.1, which is the guard that would have caught this gap on its own.

### AD1.2 · Step 99 — the unclaimed-output sweep

Nothing deletes a generated file whose source is gone. Rename `t1_prop_crop_vegetable_wheat.md`
and the old JSON stays under `assets/generated/`, tracked, loadable, and — because
registries scan the manifest rather than the folder — invisible until something scans the
folder instead. The spec's own header says why it is numbered 99 and not 24: every other
number is a position in the build, this one runs after all of them.

Port: each step declares the paths it wrote (they already return them, or can); the sweep
takes the union, walks `GENERATED_ROOT`, and reports — `--dry-run` by default, deleting
only when told, and `--check` failing on an unclaimed file so the suite catches it.
Prerequisite: AD1.1, because a step that cannot say what it would write cannot say what it
claims.

### AD1.3 · Write the step map into `COMMANDS.md`

FP2.1 said "keep step numbering", and step 11 here does not: it emits the whole biome
resource (the spec's step 25) *and* the population tables (the spec's step 09), while the
spec's own step 11 was retired to `tessera/scripts/deprecated/11_patch_biome_terrain_density.py`.
Our step's docstring is honest about it and no reader of `COMMANDS.md` ever sees that
docstring. The table in §1.1 is the missing artefact; it belongs in `scripts/COMMANDS.md`
next to the command list, where a session looking for "the step that does X" reads it.
Whether to renumber instead is `AD-D1`, and the map is owed either way.

---

## 2. The project checks

40 commands over there, 4 here. Sorted by whether the subject exists in this repo at all.

### AD2.1 · `check_pipeline_check_coverage.py`

The guard the spec learned from its own `L-306`: a step whose `--check` returns success for
work it did not do is worse than no `--check`, because the suite reports green over it. It
tests each step's `--check` against a deliberately corrupted output and refuses a step that
does not fail. Here it also finds AD1.1 by itself, which is the argument for landing it
first: the two gaps are the same gap seen from the two ends.

### AD2.2 · `check_decision_ids_are_unique.py`

This repo runs **two decision ID spaces one hyphen apart**: the study's `D1`–`D7`
(`docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md:206-212`, settled, historical) and the port
plan's `D-1`–`D-8` (`FLUTTER_PORT_PLAN_2026-08-25.md`, open, each blocking a step). A
sentence that says "D-4" and one that says "D4" name different things, and no reader has
been told that. `L-013` carries it.

The guard: collect every decision ID declared under `docs/refactoring/` and `docs/study/`,
refuse a duplicate across documents, and hand out the next free one with `--next` (the
shape `check_ledger_ids_are_unique.py` already has). A new plan takes a **prefixed** space
the way this document does (`AD-D1`) and the way the spec does (`DP-D5`, `VM-D4`, `W-D2`) —
the guard is what makes that convention enforceable rather than remembered.

### AD2.3 · `check_referenced_assets_are_committed.py`

The emitted JSON keeps the pack's own URI scheme, and `ContentPaths.resolveRes`
(`lib/src/core/shared_logic/definitions/content_paths.dart:31-45`) maps it to a bundled
asset key at load. That is the one mapping, deliberately (rule 29). Measured at 0.53.0:
**95 `res://data/…` references, 58 resolve, 37 do not** — every unresolved one is a `.wav`
under `data/audio/`, a family that has never crossed and is owed by FP7.9.

So the guard is owed *now*, with the audio family as a NAMED, dated hole in its header (the
allowlist convention FP0.11 already uses), and its value is precisely that a **new** hole
fails the suite the day it appears instead of the day something tries to play it. Crashing
on a missing sprite is rule 5 working as designed; the point of the check is that the crash
happens in the pipeline, which names the file, and not at render, which names a null.
`L-015` carries it.

### AD2.4 · `check_version_artifacts_agree.py`

The version is written in three places by one shell line in `CLAUDE.md` §Parallel sessions:
`pubspec.yaml`, and the top section of both changelogs. They agree at 0.53.0 (`0.53.0+73`,
`## 0.53.0`, `## 0.53.0`). Nothing checks that they still will. The spec's version also
answers the harder half — *every* version since the release tool, not just the current one —
which here means: every `## <version>` section in the changelog pair has a commit whose
subject carries that same prefix, and no commit prefix is missing a section. That is the
`git log --format='%s' | cut -d';' -f1` uniqueness check `CLAUDE.md` already prescribes by
hand, run over the whole history instead of over one range.

### AD2.5 · `check_python_scripts_compile_without_warnings.py`

18 Python files compile with **zero warnings** at 0.53.0 (measured, not assumed). The guard
is fifteen lines and its whole value is that the number stays zero — a `SyntaxWarning` on an
invalid escape in a regex is the class of defect that reaches a script's behaviour, not just
its noise. Its sibling `check_automation_speaks_english.py` (rule: the automation is written
in English) has exactly one hit here, `scripts/lib/knowledge_index.py:81-83`, and that hit
is a **pt-BR stopword table** which must stay — so the twin lands with a data-vs-prose
exemption in writing, or it lands as a false alarm and gets ignored, which is worse than not
landing.

### AD2.6 · `check_no_debug_probe_markers.py`

`grep -rnE 'TODO|FIXME|XXX|DEBUG:' lib/src` returns **0** at 0.53.0. Rule 21 bans commented
code and rule 5 bans the recovery path a probe usually guards, so the discipline is already
being kept by hand. A guard over a clean tree costs nothing to add and is unarguable to
enforce; a guard over a dirty one is a negotiation. This is the moment.

### AD2.7 · The suite refuses a run that is green but noisy

`scripts/project/check_test_suite_is_clean.py` reads exit codes. The spec's twin refuses a
GUT run that passed while printing errors, because a suite that prints an exception and
passes anyway is how a broken path survives for weeks. The Dart shape: `flutter test` output
carrying an uncaught async error, a `print` from `lib/` (never legitimate — logging goes
through the project's own channel), or a Flame assertion that a test swallowed. Fail on any
of them, name the line, and keep `--test-only` as the loose loop for iteration.

### AD2.8 · Every generated folder is declared in `pubspec.yaml`

Flutter bundles only the assets a `pubspec.yaml` entry names, and a folder entry does not
recurse. So `assets/generated/<game>/**` is a hand-written list — **27 entries at 0.65.0,
one per generated folder that holds a file, and all 27 correct.** Nothing checks it, and
the failure mode is the worst kind: the pipeline succeeds, the file is on disk, git tracks
it, the suite is green, and the asset is simply absent at runtime — which under rule 5 is a
crash in front of a player rather than a red build.

This guard matters more the day after it lands than the day of. `PACK_IMPORT_MAP_2026-09-10.md`
schedules nine content batches, and **every batch that creates a folder owes a line here**;
that obligation is written into that document's §4 and this is the thing that enforces it.
The check is fifteen lines — walk `GENERATED_ROOT` for directories holding at least one
file, compare with the declared set, fail naming both directions (an undeclared folder and
a declared folder that no longer exists). It runs from the suite.

### 2.1 Not owed, with the reason

| Spec command | Why not |
|:---|:---|
| `check_scripts_have_uids`, `check_global_class_names`, `check_section_banners_describe_their_code`, `sync_project_godot` | Godot file formats and GDScript's global name table. Dart's analyzer answers the second; the rest have no subject. |
| `check_interop_call_sites` | rule 26 is *N/A in Dart* by `CLAUDE.md`'s own reservation — there is no C#↔GDScript boundary to count. |
| `check_shared_autoloads_are_declared`, `check_shared_components_build_no_ground_node`, `check_shared_names_no_dimension_class`, `check_shared_documents_match_head`, `report_dimension_coupling`, `check_game_fanout_is_family_scoped` | the dimension-parity family: one engine, two grounds, ten lanes. This repo has one ground and one game. The port plan's `D-8` already parks rules 35 and 37 for the same reason. |
| `lane.py`, `night_shift.py`, `start_codex_lane.py`, `sync_codex_harness.py`, `report_lane_leftovers.py`, and the six lane/night-shift hooks | same: a ten-lane board. This repo assumes parallel sessions (`CLAUDE.md` §Parallel sessions) and answers them with a version derived from `HEAD`, which is the whole mechanism it needs at this size. |
| `launch_host_and_client.py` | multiplayer is shaped-for, not built (study §5). |
| `check_input_action_contexts.py` | owed, but **owned by FP5.2(c)** — it checks a catalogue that does not exist here yet. It lands in the commit that builds `InputActionCatalog`, not before. |
| `check_shader_parameter_names_exist.py` | owed, **owned by FP7.15** — the first `FragmentShader` brings it. |
| `check_pack_contract.py` | the contract is derived from the *engine's* `res://data/…` references, and that engine is over there. This side's question is drift between two copies, which is FP0.11. Worth reading `tessera/docs/PACK_CONTRACT.md` before writing FP0.11 — it is the list of what a pack must supply, already derived. |
| `check_release_machinery`, `package_tester_build`, `ensure_tester_export_presets`, `run_migration_smoke_test.sh` | release machinery, `AD-D2`. Flutter's own `flutter build <platform>` replaces the export presets; what a tester build *is* here has never been decided. |
| `check_commit_message_is_ai_free.py` | **already enforced**, as a hook rather than a command (`scripts/ai/hooks/block_forbidden_git.py`). Nothing owed. |
| `check_drop_amounts`, `check_frame_sizes_divide_their_sheets` | owed as content validators — AD5.1. |
| `reset_local_save.py`, `check_changelog_is_ordered.py`, `check_translation_keys.py`, `check_ledger_ids_are_unique.py`, `check_test_suite_is_clean.py` | already owned: FP0.10, and FP0.16 / FP0.17 / done / done. |

---

## 3. The commit ritual, as a script instead of a recipe

### AD3.1 · `stamp_changelog_section.py`

`CLAUDE.md` §Parallel sessions prescribes this line:

```
sed -i '' "s|^## 0\.0\.0-NEXT|## $NEXT|" games/dawnforge/CHANGELOG.md games/dawnforge/CHANGELOG.pt-BR.md
```

It stamps the section **where it sits**. It does not move it to the top. The spec deleted
the same line from its own `CLAUDE.md` and replaced it with a script, after paying for the
defect three times (its `L-238`). **This repo has paid once already:** at 0.47.0 both
changelogs carried `0.45.4` and `0.45.3` above `0.47.0`, and 0.48.0 repaired it by hand —
the evidence FP0.16 was opened on. FP0.16's guard now *detects* it; nothing yet *prevents*
it, and the two are different jobs.

Port: stamp and move, both languages, idempotent, `--check` refusing a surviving
`0.0.0-NEXT`, and `CLAUDE.md`'s recipe edited in the same commit so the `sed` stops being
prescribed. Note the ordering constraint — FP0.16 fails the suite on an unordered pair, so
this script's own test fixtures must not be committed changelogs.

### AD3.2 · `commit_task_files.py`

The ritual in `CLAUDE.md` is eight shell lines a session retypes each time: read `HEAD`'s
version, compute the next, `sed` three files, `git add` a pathspec, `git commit -F` with the
same pathspec, then verify prefix uniqueness. Every line is a place to get it wrong, and the
guard hook exists precisely because one of them was. The spec's answer commits *the file
contents named on the command line*, never what the working tree happens to hold — which is
the property that matters with a second session editing the same tree, and the one a
pathspec only approximates (a pathspec commits the file's staged content, whoever staged it).

This one is `AD-D3`, not because the port is hard but because it edits the developer's own
documented flow, and `CLAUDE.md` is theirs.

---

## 4. The AI harness

Two commands and two hooks here, twelve and ten over there. Most of the difference is the
lane board (§2.1). What is left is small and each piece pays for itself:

### AD4.1 · `check_harness_machinery.py`

Four guards run on every commit — the two hooks, the changelog check, the translation
check — and **no test covers any of them**. Each is pure logic over a payload or a file, so
each is testable headless with fixtures: a message with an attribution trailer, a `git
commit` without a pathspec, a changelog with two `0.0.0-NEXT`, a `tr()` key missing from
one locale. The spec's own header for this file says it plainly: every case in it is a bug
that shipped.

### AD4.2 · `summarize_ledger_entries.py`

`LEDGER.md` is 79 lines and read whole every time a session asks "is this already written
down". Rule 27 makes that read mandatory before a new entry. The spec's answer is an index
first (ID, title, lens, one line) and the full entry on demand. Cheap now, and the thing
that keeps rule 27 affordable when the ledger is 400 lines.

### AD4.3 · `decision_inbox.py`

The port plan carries **8 open forks** (`D-1`…`D-8`) and this document adds **3**. They are
readable only by opening two plans and scrolling to the bottom of each. The inbox collects
every register in `docs/refactoring/`, prints what each fork blocks, and — the half that
matters — says which have been *answered* and are still sitting in a table marked open.
Depends on AD2.2, which is what makes "every register" a well-defined set.

### AD4.4 · `report_runway.py`

Measures how much executable planning is in front of a session: items documented, not done,
and not blocked on a decision. It is the direct answer to the question this document was
written for, and it turns "document the next steps" from a session's judgement into a
number that can be watched between sessions.

---

## 5. Content

### AD5.1 · The four validators

The pack is authored on the delivery track and **imported** here, so the mutators do not
cross (§6.2). Four validators do, because an import can be wrong in four mechanical ways
and nothing here would say so:

- `enforce_content_id_references` — every `id` a document names resolves to another
  document. Step 26 already does this for loadout entries (0.50.0) and step 04's loot sweep
  does it for drops; this generalises both to every id-shaped field.
- `enforce_drop_amount_fits_max_stack` — a loot roll that cannot fit the stack it produces.
- `enforce_tier_matches_filename` — `t2_` in the name, `tier: 1` in the frontmatter.
- `check_atlas_row_layout` / `check_frame_sizes_divide_their_sheets` — a `frame_size` that
  does not divide its sheet, which produces a sliced sprite nobody notices until it renders.

All four are read-only over `DATA_ROOT`, all four are `--check`, and all four fail with the
document's path. They belong in `scripts/content/`, which is the first inhabitant of a
folder rule 23 names and this repo does not have.

---

## 6. What is not owed, and why

### 6.1 The second dimension

Steps 13–22, 27 and 28, and the whole `shared`-parity family of checks, exist because one
Godot engine draws two grounds (a 2D tilemap and a voxel world) for two games of one family.
This repo is one game on one ground. Those numbers stay reserved so a cross-repo reference
keeps resolving, and nothing more.

### 6.2 Pack authoring

`tessera/scripts/content/` (28 scripts) and `tessera/scripts/assets/` (21) author and repair
the pack: they compose stat descriptions, translate display names, normalise field order,
draw placeholder sprites, merge atlases, pixelize to a palette. **The pack is the shared
contract (study §4) and it is authored on the delivery track.** A second authoring path here
is the fork that contract exists to prevent — the risk `L-006` already records. What crosses
is validation (AD5.1), never mutation. `tessera/scripts/maintenance/` (6) is one-shot Godot
tree surgery and crosses not at all.

### 6.3 The folders that do not exist yet

Rule 23 names eight `scripts/` subfolders; this repo has four (`pipeline/`, `project/`,
`ai/`, `lib/`). `content/` gets its first inhabitant from AD5.1 or FP0.11, whichever lands
first; `docs/` from FP0.15's `check_manual_mirrors.py`. `assets/`, `maintenance/` and
`deprecated/` stay empty until something real needs them — an empty folder that exists
because a rule listed it is a leftover with a rule's name on it, which is rule 22 read
backwards.

---

## Decision register

Prefixed `AD-D` so it cannot be confused with the port plan's `D-n` or the study's `Dn` —
the collision AD2.2 exists to guard. None of the items above waits on any of these.

| ID | Blocks | Question | Recommendation |
|:---|:---|:---|:---|
| **AD-D1** | AD1.3 | Renumber our step 11 to 25 (its closest spec twin), or keep 11 and publish the map? | **Keep 11, publish the map.** No spec number fits a step that folds 09 and 25, the spec's own 11 is deprecated, and a renumber costs `dawnforge.py`, `COMMANDS.md` and every doc that cites it to buy a number that is still wrong. Revisit if the port ever splits the step in two. |
| **AD-D2** | the release family | Is there a build to ship, and to whom? Platforms, a tester channel, CI. | **Not yet, and say so in writing.** No platform has been named, `.github/` does not exist, and the study track's product is knowledge. When a build is wanted, the decision is one line — which platforms — and the machinery is `flutter build` plus one workflow, not the spec's export presets. |
| **AD-D3** | AD3.2 | Replace `CLAUDE.md`'s eight-line commit recipe with `commit_task_files.py`? | **Yes, after AD3.1.** The stamp is the half that has already cost this repo a repair; the commit itself has not. Doing the cheap, proven half first means the recipe shrinks by the two lines most likely to be wrong before anything asks the developer to trust a script with the commit. |
