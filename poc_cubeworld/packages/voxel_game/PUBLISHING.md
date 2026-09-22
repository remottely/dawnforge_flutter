# Publishing these packages

Nothing here is published. Every package is at `0.0.0` with `publish_to: none`,
and they resolve each other through the pub workspace declared in
`poc_cubeworld/pubspec.yaml`. This file is the checklist for the day that
changes. The reasoning behind the four-package split is in
[`../docs/VOXEL_CONSOLIDATION_PLAN_2026-09-19.md`](../docs/VOXEL_CONSOLIDATION_PLAN_2026-09-19.md).

## The four packages

| Package | Kind | Depends on |
|:---|:---|:---|
| `voxel_engine` | pure Dart | — |
| `voxel_scene` | Flutter + flutter_scene | `voxel_engine` |
| `sound_recipes` | Flutter + flutter_soloud | — |
| `voxel_game` | Flutter | all three |

`voxel_game/example` and `voxel_scene/example` are apps, not packages. They stay
`publish_to: none` for good.

## Before the first release

1. **A repository of its own.** These live on the `poc_cubeworld` branch of a
   game repository, next to that game's history and its own rules. A published
   package's `repository:` has to point at a repository that is the packages'
   home. Moving them is the first step, not the last.
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
cd packages/voxel_engine   && dart pub publish --dry-run
cd packages/sound_recipes  && flutter pub publish --dry-run
cd packages/voxel_scene    && flutter pub publish --dry-run
cd packages/voxel_game     && flutter pub publish --dry-run
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
      path: packages/voxel_engine
      ref: <a tag or a commit>
```

It is a legitimate place to stop. Publishing buys discoverability and a version
contract with strangers; until someone other than you depends on these, it
mostly buys the ceremony.
