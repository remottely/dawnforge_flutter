# Dawnforge Flutter (Tessera-Dart) — Developer & AI Instructions

> **IMPORTANT:** This file contains non-negotiable coding and workflow rules for the
> Tessera-Dart study track. It is the sibling of the Godot repo's `CLAUDE.md`
> (`~/Documents/godot/remottely/dawnforge_project`): **same rule numbers, same spirit,
> Dart/Flame bodies.** Rules that cannot apply in Dart are marked *N/A* — the number is
> reserved so cross-repo references stay valid.
>
> Founding study: `docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md` (decisions D1–D7).
> Executable plan: `docs/refactoring/implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md`.
> Harness machinery: `docs/AI_HARNESS.md`.

## Project Overview
Flutter · Dart · Flame (direct — **no Bonfire**, decision D2) · 2D TopDown survival/crafting
· Português Brasileiro (Chat) / English (Code & Git) · **Singleplayer-first, multiplayer-shaped**
This is the **study track**: it reproduces the Tessera content-engine architecture in Dart
to explore new genres inside Flutter. The Godot repo is the delivery track. They share
architecture, the content-pack format, and this harness — never code.

**Target audience: players aged 7 and up.** Every player-facing text must be readable by a
7-year-old: short sentences, concrete words, numbers explained by their effect. Content and
tone only — it never simplifies mechanics.

**`reference/legacy_flutter/` is the archived pre-port codebase — read-only reference.
Never import from it, never resurrect a pattern from it without passing these rules.**

---

## ✅ Non-Negotiable Technical Rules

1. **Factory.create()** — a world object (Actor / Prop / Ground / Item) is constructed
   only by its factory (`lib/src/core/factories/`). Nothing else assembles a world-object
   host, its core, or its components. UI widgets are ordinary Flutter and need no factory.
2. **Registry.get(id)** — never read or parse content JSON directly in gameplay code; all
   game data comes from a registry (`lib/src/core/registries/`).
3. **initialize(data)** + `data = initialData.clone()` on every WorldObject — each
   instance owns its state; a host is unusable until initialized (assert on both ends).
4. **100% strict typing** — `dynamic` is forbidden in `lib/`; `analysis_options.yaml`
   pins `strict-casts`, `strict-raw-types`, `strict-inference` and stays at zero infos.
   Every declaration, param, return and generic is explicit.
5. **Zero fallbacks** — crash is a feature. Validate with direct `assert`/`throw`; never
   a conditional recovery path, never a default patched over missing data.
6. **No default-constructed data** — data classes have no argumentless constructors used
   by gameplay; all data arrives via `initialize()` / `fromJson`.
7. **Hierarchical naming** — `I + [Type] + [Subtype]`: `IPropBuildableData`,
   `IActorEnemyData`, `IComponentHealth`. File is `snake_case` of the class name; a
   content id always equals its filename without extension.
8. **Data-Driven state** — mutable game state lives in the data layer only, never
   duplicated into host/component locals. (Valid locals: visual-only transients, cached
   component refs, per-frame temporaries, never-serialized internals.)
9. **State Machines** — for any complex/sequential state; never loose boolean flags.
10. **`deprecated/` and `reference/` — completely ignore**, never read as prior art,
    never import.
11. **Unified Cursor** — gameplay code never reads pointer/touch position from raw Flutter
    or Flame events; always `InputHelper.getCursorWorldPos()` /
    `InputHelper.getCursorScreenPos()` (`lib/src/core/systems/input/`).
12. **Input Parity** — every behavior added for one input mode (keyboard/mouse, gamepad,
    touch) must be reflected in all other modes; `InputHelper` is the single source of truth.
13. **Typed Component Access** — components are read through `WorldObjectCore`. When the
    concrete host type is known, call `getComponent()` on it; when it is not (a collision
    callback, an event payload), ask `WorldObjectHelper.getCore(node)` — a non-null core
    is the typed proof the node owns components. Never probe with `is`-cascades over host
    types, never `dynamic` dispatch.
14. **Version Major Locked at 0** — `pubspec.yaml` version is `0.MINOR.PATCH+B` where
    MINOR grows indefinitely. The major digit stays `0` until v1.0.0 ships. Bump MINOR or
    PATCH only. (Legacy `1.110.x` numbering died with the legacy code — decision D5.)
15. **One component container, never a copy** — a host that owns components takes its
    container from its `WorldObjectCore`; never declare a local component map. UI never
    owns components — widgets compose with child widgets.
16. **Components addressed by constant** — `getComponent(ComponentKeys.health)`, never a
    string literal; `component_keys.dart` is generated from the component class names
    (pipeline step 10), so the constant and the container key cannot drift.
17. **Generated code holds content, never logic** — `lib/src/generated/` and
    `assets/generated/` may only carry data and wiring; behavior belongs in `lib/src/core/`.
    Never hand-edit generated files.
18. **No duck typing where a type exists** — no `dynamic`, no `as`-guessing, no
    `try/catch` as dispatch. Cast to the declared type and assert. Rule 13 is this ban
    applied to the component contract.
19. **No user-facing string literals** — every human-readable string goes through `tr()`
    with a translation key (en + pt-BR). Decorative glyphs are icons, not text.
20. **A logged warning followed by `return` is a fallback in disguise** — either the state
    is a legitimate branch (no warning) or it is invalid (assert/throw). Breaks rule 5
    otherwise.
21. **No commented-out code in `lib/`** — dead code lives in git history.
22. **Folder names describe a domain, never a leftover** — `others/`, `misc/`, `utils2/`
    are forbidden; every folder names what it contains.
23. **Every automation lives in `scripts/`**, in the subfolder for when it is used
    (`pipeline/`, `content/`, `assets/`, `project/`, `docs/`, `maintenance/`, `ai/`,
    `deprecated/` — move, never delete). Binding sub-rules: paths come from
    `scripts/lib/project_paths.py` (never hand-counted `parents[N]`); name the job, not
    the shape; runnable standalone from the repo root with a `__main__` guard;
    `--dry-run` when it writes, `--check` when it generates a committed file. A script
    writing generated output stamps its own path in the `AUTO-GENERATED by …` header and
    lands in `scripts/COMMANDS.md` in the same commit.
24. **Never poll input state inside an event callback** — an event handler reads the event
    it was handed; per-frame polling belongs in `update(dt)` and only there. One physical
    press must never be processed twice because a handler also polled.
25. **One arbiter per shared button** — a back/cancel press is routed once
    (`UIStateMachine.requestCancel()`); surfaces answer the routed request, they never
    read the button themselves. Two widgets reacting independently to one press is how a
    menu closes itself while another opens on top.
26. *N/A in Dart* (Godot repo: GDScript↔C# lambda marshalling). Number reserved.
27. **Record every architectural observation in the ledger** — a structural problem found
    mid-task that is not the task goes to `docs/refactoring/LEDGER.md` as one 4-line entry
    (`Lens`, `Evidence` with `file:line` + version, `Cost of leaving it`, `Found while`),
    in the same commit as the task, never mentioned in the commit message, never fixed in
    that commit. Check `docs/refactoring/PENDING.md` for duplicates first.
28. **A registered system is never null** — every singleton registered at boot in the
    service locator exists for the app's whole life; `if (locator.isRegistered…)` guards
    and null-tolerant reads of them are fallbacks in disguise (rule 20 + rule 5). Call it
    plainly. The one exception is a teardown path, commented as such.
29. **`lib/src/core/` never names a content folder** — content paths come from
    `ContentPaths` (`lib/src/core/shared_logic/definitions/content_paths.dart`), the
    runtime twin of `scripts/lib/project_paths.py`. A hand-written content path fails
    silently when a folder is renamed; that is why there is exactly one name table.
30. **The game never pauses** — writing to Flame's `pauseEngine()` / `resumeEngine()`,
    forcing `dt = 0`, or any global freeze flag every system consults is forbidden. The
    simulation is multiplayer-shaped even while singleplayer (decision D4): a surface that
    must stop the player pushes `GameInputManager.pushUiBlocker(this)` /
    `popUiBlocker(this)`; gameplay asks `GameInputManager.isGameplayEnabled`. The ban
    covers *looking* paused: the world behind a menu keeps moving and must be seen moving
    (live `BackdropFilter`, never a captured snapshot). `AudioPlayer.pause()` on a sound
    is fine — it pauses a sound, not the game.
31. **The content pack is `games/<game>/data/`** — Markdown+YAML, the SSOT for all game
    content. Automation addresses it only through `DATA_ROOT` and children in
    `scripts/lib/project_paths.py`. The pipeline generates `assets/generated/<game>/`
    (JSON) — never hand-edit outputs, never fork the pack format from the Godot repo
    (shared contract, study §4).
32. **Nothing has shipped, so a breaking change is free — and the local save is the
    bill.** No save migration, no compatibility obligation. Any commit that changes a
    persisted shape ends with `python3 scripts/project/reset_local_save.py` and one line
    in the commit body naming what became unreadable.
33. **Transforming a tile is not removing it** — Place asks `allowsActorOverlap` of the
    object placed; Destroy asks it of the object destroyed; Transform asks nobody. Which
    verb a tool performs is content (`farm_tools` vs `allowed_tools` on the ground data),
    never a new `if` in a tool script; the verb is decided once, where every path meets,
    against actors' body rects. A tool that refuses says so via notification — it never
    falls silently through.
34. **A task is not done when the code works — it is done when the player can read about
    it.** Every commit ships the commit message, a changelog section in
    `games/dawnforge/CHANGELOG.md` **and** `CHANGELOG.pt-BR.md` (seven fixed categories;
    internal-only changes still get their `### 🧹 Internal` line; the section is written
    as literal `0.0.0-NEXT` and stamped by the commit command), and — when player-visible
    — the manual page in `games/dawnforge/docs/manual/en/` **and** `pt-BR/` (same
    filename, same heading order). Same commit as the code, never a follow-up.

---

## 🔄 Execution Workflow

1. **Plan** — check prior art first: `python3 scripts/ai/search_project_knowledge.py
   "<topic>"`; for port work, also consult the Godot repo's implementation as the spec.
2. **Implement ONE concern** — single responsibility per commit.
3. **Run the suite** — `python3 scripts/project/check_test_suite_is_clean.py`
   (wraps `flutter analyze` + `flutter test`; exit 0 or it did not pass).
4. **Validate against the rules above.**
5. **Document for the player** (rule 34) — both changelogs; manual when visible.
6. **Reset the local save** if a persisted shape changed (rule 32).
7. **Bump the version and commit in ONE shell command** (§Parallel sessions).
8. **Reference the plan step** (`FP<phase>.<step>`) in the commit body when the task
   belongs to the port plan.

### Parallel sessions — assume one, always

Another chat may be working in this repository at the same time. Two obligations:

**1. Derive the version from `HEAD`, in the same command as the commit:**

```bash
CUR=$(git show HEAD:pubspec.yaml | grep -m1 '^version:' | sed 's/version: *//' | cut -d'+' -f1)
BLD=$(git show HEAD:pubspec.yaml | grep -m1 '^version:' | grep -o '+[0-9]*' | tr -d '+')
NEXT=$(python3 -c "import sys;M,m,p=sys.argv[1].split('.');print(f'{M}.{int(m)+1}.0' if sys.argv[2]=='minor' else f'{M}.{m}.{int(p)+1}')" "$CUR" minor)
sed -i '' "s|^version: .*|version: $NEXT+$((BLD+1))|" pubspec.yaml
sed -i '' "1s|^[0-9][0-9.]*;|$NEXT;|" <msgfile>
sed -i '' "s|^## 0\.0\.0-NEXT|## $NEXT|" games/dawnforge/CHANGELOG.md games/dawnforge/CHANGELOG.pt-BR.md
git add <task files> pubspec.yaml games/dawnforge/CHANGELOG.md games/dawnforge/CHANGELOG.pt-BR.md \
  && git commit -F <msgfile> -- <task files> pubspec.yaml \
  games/dawnforge/CHANGELOG.md games/dawnforge/CHANGELOG.pt-BR.md
```

Then verify uniqueness: `git log --format='%s' <base>..HEAD | cut -d';' -f1 | sort |
uniq -d` must print nothing. A collision is repaired with `git commit-tree` +
three-argument `git update-ref` — **never `rebase` or `commit --amend`** (the hook blocks
both).

**2. Fix what the other session wrote when it is wrong or stale, in your own commit** —
verified against the code, mentioned in the commit body, its commits never rewritten.

### Commit message format

```
0.2.0; feat: one-line summary in English

Body: what and why. Plan step FP1.3. Breaking-save line when rule 32 fired.
```

Prefix is the exact `pubspec.yaml` version; type ∈ `feat|fix|refactor|config|chore|docs|test|perf`.

**No AI attribution, ever.** A commit message carries what changed and why —
never a `Co-Authored-By:` naming a model, never a "Generated with" line, never a
tool's badge or emoji signature. The commit history is the project's engineering
record and its author is the person who ships it; a machine co-author line is
noise in the log, and it leaks the tooling into a record that outlives it. This
holds for every message the repo produces — commits, tags, PR bodies. The
`block_forbidden_git.py` hook refuses a commit whose message carries one
(`docs/AI_HARNESS.md` §3).

---

## 📋 Testing Policy

- Port work (FP steps) **writes tests with the port** — the API is a spec, not a draft;
  `test/` mirrors `lib/src/`.
- Exploratory/new-genre work: no tests during active design; tests after the API freezes.
- **Always run** the full suite before any commit (workflow step 3). Never
  `run_in_background` — inline, wait for the exit code.

## 📚 Key File Locations

| What | Where |
|:---|:---|
| **Founding study (decisions D1–D7)** | `docs/study/GODOT_TO_FLUTTER_PORT_STUDY.md` |
| **Port plan (SSOT for FP steps)** | `docs/refactoring/implementation_plan/FLUTTER_PORT_PLAN_2026-08-25.md` |
| **The AI harness (SSOT)** | `docs/AI_HARNESS.md` |
| **Game content (SSOT) — the `.md` pack** | `games/dawnforge/data/` |
| Generated content (never hand-edited) | `assets/generated/` + `lib/src/generated/` |
| Every path automation may use | `scripts/lib/project_paths.py` |
| Ask the repo's knowledge | `python3 scripts/ai/search_project_knowledge.py "<q>"` |
| Architecture ledger (rule 27) | `docs/refactoring/LEDGER.md` |
| Everything documented, not yet done | `docs/refactoring/PENDING.md` |
| Player changelogs + manual (rule 34) | `games/dawnforge/CHANGELOG*.md` · `games/dawnforge/docs/manual/` |
| **The Godot sibling (the spec being ported)** | `~/Documents/godot/remottely/dawnforge_project` — read-only from here |
| Archived pre-port code (rule 10) | `reference/legacy_flutter/` |
