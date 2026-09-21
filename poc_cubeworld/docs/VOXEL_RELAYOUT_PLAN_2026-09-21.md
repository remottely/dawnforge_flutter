# The relayout — this folder becomes the `voxel_game` package, the app becomes its demo

**Step IDs: `VR0`–`VR6`.** Written 2026-09-21 at `7fd182ca`, before any file moved. Nothing
in this plan changes behaviour: it moves files, rewrites paths and renames things. Every
gate is "the same suite, the same probe logs, the same game".

The sibling plans are [`VOXEL_KIT_PLAN_2026-09-18.md`](./VOXEL_KIT_PLAN_2026-09-18.md) (how
the packages were extracted) and
[`VOXEL_CONSOLIDATION_PLAN_2026-09-19.md`](./VOXEL_CONSOLIDATION_PLAN_2026-09-19.md) (why
there are four). This one is the last structural move before a first release: it gives the
kit the shape it will have in its own repository, and it takes the POC's vocabulary out of
the code.

## Progress

| Step | State | Gate |
|:---|:---|:---|
| VR0 The baseline, frozen before anything moves | todo | the six suite commands green and `tool/probe_baseline.sh --check` clean, with the numbers written into this table's row |
| VR1 The relayout — `demo/` is born, the root becomes `voxel_game` | todo | analyze clean, the same test count, probe logs match `docs/baseline/`, `flutter run -d macos` from `demo/` plays |
| VR2 The demo's name — `cubeworld_poc` → `voxel_game_demo` | todo | no `cubeworld_poc` anywhere outside `.md`; the app builds, boots, and writes a world under the new save root |
| VR3 The terms leave the implementation | todo | `grep -ri 'minecraft\|cube ?world\|\bpoc\b'` over every `lib/`, `test/`, `tool/`, shader and native file returns nothing |
| VR4 The docs realigned to the new tree | todo | every path in `README.md`, `CLAUDE.md`, `ROADMAP.md`, `packages/PUBLISHING.md` and the three plans resolves |
| VR5 Publish readiness for the four packages | todo | `pub publish --dry-run` green for `voxel_engine`, `sound_recipes`, `voxel_scene`, `voxel_game` |
| VR6 The folder itself — `poc_cubeworld/` → `voxel_game/` | todo | the parent worktree builds and tests from the new path; no absolute path in the repo still says `poc_cubeworld` |

---

## The shape, before and after

Today the root is the POC app and the kit hangs off it. After VR1 it is the other way
round: the root **is** `voxel_game`, the other three packages are its `packages/`, and the
app that proves them is `demo/`.

```
voxel_game/                     (was poc_cubeworld/ — renamed in VR6)
├── pubspec.yaml                name: voxel_game · the workspace root · the published package
├── lib/  test/  example/       ← packages/voxel_game/{lib,test,example}
├── README.md  CHANGELOG.md  analysis_options.yaml   ← packages/voxel_game/
├── .pubignore                  new — keeps packages/ and demo/ out of the tarball
├── CLAUDE.md                   rewritten for this tree (VR4)
├── packages/
│   ├── voxel_engine/           unchanged
│   ├── voxel_scene/            unchanged (its example stays under it)
│   └── sound_recipes/          unchanged
└── demo/                       name: voxel_game_demo (was cubeworld_poc)
    ├── lib/ test/ assets/ flutter_scene_generated/
    ├── android/ ios/ macos/
    ├── tool/                   probe_baseline.sh, perf_loop.sh — they drive the demo
    ├── docs/                   the whole of today's docs/, baseline logs included
    ├── ROADMAP.md              stage SSOT *and* a demo asset (the credits read it)
    ├── README.md               how to run it and every probe flag
    └── pubspec.yaml            resolution: workspace
```

`packages/voxel_game/` ceases to exist. `voxel_scene/example` and the new root `example/`
stay `publish_to: none` apps, as before.

### The decisions behind that shape (taken 2026-09-21, do not re-litigate)

1. **The root is the package, not a wrapper.** The kit is the product; the app is the demo
   that proves it. A published `repository:` should point at a tree whose root is the thing
   you installed.
2. **Everything the app owns moves with the app** — `ROADMAP.md`, `tool/` and `docs/` all
   land in `demo/`. `ROADMAP.md` has no choice: Flutter only serves assets from inside the
   declaring package, and the credits screen reads it at runtime
   (`lib/src/ui/credits_screen.dart`, `roadmapAsset = 'ROADMAP.md'`).
3. **"cubeworld", "poc" and "minecraft" are documentation words from now on.** They keep
   their place in `.md` files — that is the lineage, and the port's whole story — and leave
   every Dart file, test, shader, script and native config, including doc comments. The
   dartdoc of `voxel_game` is published; it should describe what the code does, not which
   game it was measured against.
4. **The app is `voxel_game_demo`**, shown as "Voxel Game Demo".
5. **The native identity drops `com.remottely`** — macOS/iOS become
   `com.example.voxelGameDemo`, Android `com.example.voxel_game_demo`. The demo is an
   example app, not a shipped product of anyone's.
6. **The saves are the bill** (rule 16). The save root moves from
   `…/com.remottely.cubeworldPoc/dawnforge_cubeworld_poc/worlds/` to
   `…/com.example.voxelGameDemo/voxel_game_demo/worlds/`: every existing world becomes
   unreachable, and the byte-level path parity with the Godot POC's save folder ends. The
   *format* stays identical; only the folder that holds it moves. Existing worlds are
   deleted, not migrated.

---

## What was verified before writing this (2026-09-21, `7fd182ca`)

- **A workspace root can be published.** A throwaway workspace (`ws_root_probe` with one
  member) passed `dart pub publish --dry-run` with its `workspace:` key in place; the only
  warning was about the changelog. So `voxel_game` being both the workspace root and the
  published package is not a contradiction. Residual risk: pub.dev "may enforce additional
  checks" that a local dry run does not. Fallback if the server refuses, in order of
  preference: publish from a clean copy of the tree with the `workspace:` key removed, or
  drop the workspace entirely and give `demo/` and the examples `path:` dependencies.
- **A nested package is bundled unless it is ignored.** The same probe shipped its member's
  `lib/` and `pubspec.yaml` inside the tarball. A root `.pubignore` naming `packages/`,
  `demo/`, `build/`, `.dart_tool/`, `example/macos/` and `example/build/` removed them — the
  archive came back down to `lib/`, `README`, `CHANGELOG`, `LICENSE`, `pubspec.yaml`.
  **`.pubignore` is not optional in this layout**; without it every release of `voxel_game`
  ships the other three packages and the whole demo as dead weight.
- **The surface of the rename**: 28 Dart files import `package:cubeworld_poc/…`; the string
  `cubeworld` / `cube world` / `poc` / `minecraft` appears in 57 tracked non-generated files,
  about 35 of them doc comments inside `lib/` (both trees) and the rest in native config,
  scripts and `.md`.
- **The probe scripts survive the move for free.** Both start with
  `cd "$(dirname "$0")/.."`, so moving `tool/` into `demo/` keeps them rooted at the app.
  Only the built binary's path changes, and only in VR2 (`cubeworld_poc.app` →
  `voxel_game_demo.app`).
- **The parent repo does not resolve this tree.** `../pubspec.yaml` (the 2D track) declares
  no workspace covering `poc_cubeworld/`, so the relayout cannot break the 2D project's
  resolution.

---

## The steps

### VR0 — freeze the baseline

No file moves. Run, from today's root, and write the results into the Progress table:

```sh
flutter analyze && flutter test
cd packages/voxel_engine  && dart test
cd packages/voxel_scene   && flutter test
cd packages/sound_recipes && flutter test
cd packages/voxel_game    && flutter test
tool/probe_baseline.sh --check
```

Expected at `f6155a18`: analyze clean · 194 + 168 + 10 + 4 + 32 = **408 tests** · probe logs
match. A relayout with a red baseline is a relayout that cannot be judged.

### VR1 — the relayout (one commit; the tree is unbuildable between its halves)

Order matters: the app has to vacate the root before the package can occupy it.

1. `git mv` into a new `demo/`: `lib`, `test`, `assets`, `android`, `ios`, `macos`,
   `flutter_scene_generated`, `tool`, `docs`, `ROADMAP.md`, `README.md`,
   `analysis_options.yaml`, `.metadata`, `pubspec.yaml`. (`.gitignore` and `CLAUDE.md` stay
   at the root; `pubspec.lock` stays — the workspace keeps one lock, at its root.)
2. `git mv packages/voxel_game/{lib,test,example,README.md,CHANGELOG.md,analysis_options.yaml,pubspec.yaml} .`
   and remove the empty `packages/voxel_game/`.
3. Root `pubspec.yaml`: the `voxel_game` one, minus `resolution: workspace` (a root does not
   resolve into another workspace), plus
   `workspace: [packages/sound_recipes, packages/voxel_engine, packages/voxel_scene, packages/voxel_scene/example, demo, example]`.
4. `demo/pubspec.yaml`: keep `name: cubeworld_poc` for now (VR2 renames it), add
   `resolution: workspace`, keep the asset list as-is — `ROADMAP.md` now sits beside it, so
   the asset declaration finally points at a file in its own package.
5. New root `.pubignore` (see above). `.gitignore`: the app-relative entries
   (`/build/`, `/android/app/{debug,profile,release}`) become `demo/…`, and
   `packages/*/build/` keeps its meaning.
6. `flutter clean` in both trees (`build/` and `.dart_tool/` hold absolute paths),
   `flutter pub get` at the root, then the whole suite from the new directories, then
   `demo/tool/probe_baseline.sh --check`.

**Gate:** analyze clean, 408 tests, probe logs identical, and `cd demo && flutter run -d macos`
plays. Rule 18: a screenshot probe is what closes this step, not the tests.

### VR2 — the demo's name

`cubeworld_poc` → `voxel_game_demo` everywhere it is an identifier:

- `demo/pubspec.yaml` `name:`, and the 28 `package:cubeworld_poc/…` imports in `demo/test/`.
- macOS: `PRODUCT_NAME = voxel_game_demo`, `PRODUCT_BUNDLE_IDENTIFIER = com.example.voxelGameDemo`
  (`macos/Runner/Configs/AppInfo.xcconfig`), the copyright line, the Xcode project and scheme
  strings, and the window title in `MainFlutterWindow.swift` → `"Voxel Game Demo"`.
- iOS: `Info.plist` bundle name/display name, `Runner.xcodeproj` product name, the bundle id.
- Android: `namespace` and `applicationId` → `com.example.voxel_game_demo`,
  `android:label="Voxel Game Demo"`, and the Kotlin package folder
  `android/app/src/main/kotlin/com/example/cubeworld_poc/` renamed with its `MainActivity.kt`.
- The save root in `demo/lib/main.dart`: `'${support.path}/dawnforge_cubeworld_poc'` →
  `'${support.path}/voxel_game_demo'`. **Delete the local `worlds/` folders** rather than
  moving them, and say so in the commit body (rule 16).
- `demo/tool/*.sh`: the built binary path.
- Regenerate `demo/docs/baseline/*.log` (they are written by a run whose binary path changed)
  and eyeball that only the path lines moved.

Generated/ephemeral files under `ios/Flutter/ephemeral`, `macos/Flutter/ephemeral` and
`example/macos/Flutter/ephemeral` are rewritten by the next build — never hand-edited
(rule 17).

### VR3 — the terms leave the implementation

Rewrite, do not delete: a comment that says *why* the number is what it is keeps its
reasoning and loses the trademark. `/// Minecraft's view bobbing: the eye drops by |cos|…`
becomes `/// View bobbing: the eye drops by |cos|…`. Names to clear, in both trees:

- **Strings on screen** — `demo/lib/src/ui/credits_screen.dart` (`'CUBEWORLD POC'`, the
  tagline) and `title_screen.dart` (`'a Cube World + Minecraft clone — proof of concept'`).
  Their replacements obey rule 22: short words a seven-year-old reads.
- **Doc comments** — ~35 across `packages/voxel_game/lib`, `packages/voxel_engine/lib`,
  `packages/sound_recipes/lib`, `demo/lib` and `packages/voxel_scene/shaders/terrain.frag`.
- **`packages/voxel_game/pubspec.yaml` and `lib/voxel_game.dart`** both open with "A
  Minecraft-like in a few lines" — that is the package's pub.dev description; it is rewritten
  to say what it is ("a voxel sandbox in a few lines").
- The word `poc` in native comments (`AppDelegate.swift`, `MainFlutterWindow.swift`).

`.md` files are untouched by this step. `ROADMAP.md` §Design decisions still says "Look:
Cube World" — that is the reference the art was measured against and it stays.

### VR4 — the docs realigned

- Root `README.md` = the package's: what `voxel_game` is, the four-package graph, and a
  pointer to `demo/` and `example/`. Today's root README (run + probe flags + lineage) is
  `demo/README.md`, with its paths fixed.
- `CLAUDE.md`: the map table, every rule that names a path (1, 2, 15, 17, 19, 20), the suite
  commands, and §"Two codebases" — `lib/` is no longer the POC app, it is the package.
- `packages/PUBLISHING.md`: the workspace root's new address, the `.pubignore` requirement,
  and the release order unchanged.
- The three plans' progress tables and this one; `ROADMAP.md` §Session log gets the entry.

### VR5 — publish readiness

Exactly `packages/PUBLISHING.md`'s checklist, now unblocked: a `LICENSE` in each of the four,
`homepage`/`repository`/`issue_tracker`/`topics` in each pubspec, real version ranges instead
of `^0.0.0`, `0.1.0` as the first number, `publish_to: none` removed from the four and kept
on the two example apps. Then the four dry runs, in dependency order. `voxel_game` cannot be
released before the three it depends on exist on pub.dev.

### VR6 — the folder

`git mv poc_cubeworld voxel_game` from the parent repo, last, when nothing else is in
flight — it invalidates every absolute path a running session holds. Then grep the parent
tree for `poc_cubeworld` in paths (the 2D `CLAUDE.md`, `.claude/` hooks, any doc) and fix
what refers to this directory rather than to the git branch of the same name.

---

## Risks, and what each one costs

| Risk | Cost | Guard |
|:---|:---|:---|
| pub.dev refuses a pubspec carrying `workspace:` | `voxel_game` cannot be released from this tree | verified green on a local dry run; two fallbacks written above |
| `.pubignore` forgotten | every release ships the kit twice and the whole demo | VR5's dry run prints the file list — read it |
| Stale `build/` and `.dart_tool/` after the move | a build that fails for a reason that is not in the diff | `flutter clean` in both trees is part of VR1 |
| Another session holding uncommitted work in this tree | a `git mv` that eats somebody's file | `git status --short` before VR1; move only the tracked paths listed |
| The rename lands before the layout | two unrelated failures in one diff, impossible to read | VR2 and VR3 are separate commits, after VR1's gate is green |
| The credits screen loses its asset | a blank credits roll, seen only by playing | `ROADMAP.md` moves into `demo/` in the same step as the app, and `--open-credits` is in the probe set |
