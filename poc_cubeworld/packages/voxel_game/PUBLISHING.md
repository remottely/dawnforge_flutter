# Publishing these packages

Nothing here is published. Every package is at `0.0.0` with `publish_to: none`,
and they resolve each other through the pub workspace declared in this folder's
`pubspec.yaml`: `voxel_game` is both the workspace root and a published package,
and the other three live under `packages/`. This file is the checklist for the
day that changes. The reasoning behind the four-package split is in
[`docs/VOXEL_CONSOLIDATION_PLAN_2026-09-19.md`](docs/VOXEL_CONSOLIDATION_PLAN_2026-09-19.md),
and how the folder got this shape in
[`docs/VOXEL_RELAYOUT_PLAN_2026-09-21.md`](docs/VOXEL_RELAYOUT_PLAN_2026-09-21.md).

## The four packages

| Package | Kind | Depends on |
|:---|:---|:---|
| `voxel_engine` | pure Dart | — |
| `voxel_scene` | Flutter + flutter_scene | `voxel_engine` |
| `sound_recipes` | Flutter + flutter_soloud | — |
| `voxel_game` | Flutter | all three |

`example/` and `packages/voxel_scene/example/` are apps, not packages. They stay
`publish_to: none` for good.

**`.pubignore` is a requirement, not a tidy-up.** `voxel_game` sits at the root of
the folder that holds the other three packages, and `pub publish` bundles every
file under the package it is not told to ignore. Without the `.pubignore` beside
`pubspec.yaml` (`packages/`, `build/`, `.dart_tool/`, `example/macos/`,
`example/build/`), every release of `voxel_game` would ship `voxel_engine`,
`voxel_scene` and `sound_recipes` inside its own tarball. Read the file list the
dry run prints for `voxel_game` every time.

## Before the first release

1. **A repository of its own — the next thing that happens.** This folder is
   laid out to be that repository as it stands: moved out whole, its root is the
   package you install, and nothing in it reaches outside it. Until then it lives
   on the `poc_cubeworld` branch of a game repository, and a published package's
   `repository:` has to point at the packages' own home.
2. **A license.** One `LICENSE` per package, the same one, chosen by the
   developer. Without it the code is "all rights reserved" to everyone who finds
   it, and pub.dev docks the score for it.
3. **Metadata in each pubspec:** `homepage`, `repository`, `issue_tracker`,
   `topics`, and a `description` between 60 and 180 characters.
4. **Real version constraints.** `voxel_engine: ^0.0.0` means
   `>=0.0.0 <0.0.1` — it only resolves because pub resolves workspace members
   locally. Published, it has to be a range against a released version.
5. **Pick the first version.** `0.1.0` says "usable, the API still moves" far
   better than `0.0.1`, and leaves `0.0.x` unused rather than spent.
6. **Remove `publish_to: none`** from the four packages, and keep it on the two
   example apps.
7. **A CI that runs the whole workspace** — `dart analyze`, `dart test`,
   `flutter test` — on one push. That is the reason the monorepo exists.

## Releasing

Always in dependency order, because a package cannot be published against
versions that do not exist yet:

```sh
# from this folder
(cd packages/voxel_engine  && dart pub publish --dry-run)
(cd packages/sound_recipes && flutter pub publish --dry-run)
(cd packages/voxel_scene   && flutter pub publish --dry-run)
flutter pub publish --dry-run                                  # voxel_game itself
```

Then the same four without `--dry-run`, in that order, bumping the constraint in
each dependent to the version just released. `voxel_engine` and `sound_recipes`
do not depend on each other, so their order between themselves does not matter.

A published version can never be replaced, only retracted for seven days. The
dry run is not a formality.

## The version graph, and why it is short

Every breaking change in `voxel_engine` is a bump in `voxel_scene` and
`voxel_game`, and a release of all three. That is three edges. It was seven
before the packages were consolidated, which is the whole reason they were.
Keep it that way: a new package here earns its place by carrying a dependency
that its users should be able to refuse, not by being a different subject.

## The step before publishing

Publishing is not the only way to reuse these. A git dependency gives the same
code to another project of your own, with no release ceremony and no promise to
anyone:

```yaml
dependencies:
  voxel_engine:
    git:
      url: https://github.com/<you>/<repo>.git
      path: packages/voxel_engine   # voxel_game itself has no path: it is the root
      ref: <a tag or a commit>
```

It is a legitimate place to stop. Publishing buys discoverability and a version
contract with strangers; until someone other than you depends on these, it
mostly buys the ceremony.
