# Voxel Packages Plan — `voxel_core` + `voxel_scene`

> **The executable plan for growing two packages out of this POC.** Written 2026-09-14.
> Stable IDs (`VP<phase>.<step>`) — reference them in commits.
>
> **Where this lives, and why it never leaves.** Everything here stays on branch
> `poc_cubeworld`. It is never merged into `dev` or `main`, and `dev` carries no reference to
> it. The POC's history is ours to rewrite. When the API is stable, the two packages are copied
> into a **brand-new git repository as one commit, version `0.0.1`, with one initial
> `CHANGELOG.md`** — no history travels. Until then there is no per-package changelog and no
> version beyond `0.0.0`.
>
> **The rule of every step: the POC keeps working.** A file moves into a package, and the POC
> imports it from there in the same commit. Each step leaves the game playable, its tests green,
> and its probes printing what they printed before.
>
> Inputs: `docs/PERFORMANCE_VS_GODOT_2026-09-11.md` (the baseline numbers). The market scan of
> 2026-09-14 found no Flutter package shipping a GPU voxel world. The closest were a CPU
> `CustomPainter` renderer (`perfectum_3d`) and a heightmap terrain (`macbear_3d`).

## Progress

| Phase | State | Gate |
|:---|:---|:---|
| VP0 Scaffold & baseline | pending — VP0.1 can start now, VP0.2–VP0.3 wait on stage 32's commit | workspace resolves; empty packages analyze clean; baseline logs and parity hashes committed |
| VP1 `voxel_core` by moves | pending | every pure world file imported from `package:voxel_core`; POC tests, parity hashes and probe logs unchanged |
| VP2 `voxel_scene` by moves | pending | no `flutter_scene` import left in the POC's `world/`; radius 8/12/16 within 10% of the baseline |
| VP3 The render gap | pending | radius-16 sustained fps above the baseline's 70 (release, 3 workers) |
| VP4 Release prep `0.0.1` | pending | `dart pub publish --dry-run` clean for both; a standalone example runs without the POC |

---

## Starting point — `b57cf2a2`, 103 tests green

The blocker of 2026-09-14 20:07 (another session's uncommitted stage 32) cleared with
`03cc989c` (stage 32) and three follow-ups. One of them, `1ea8188c`, matters here. It adds
`world/godot_camera.dart`, the single handedness conversion at the render boundary, and turns
the mesher's winding back to Godot's clockwise order. `godot_camera.dart` stays in the POC for
now. It encodes "a right-handed world on flutter_scene", which `voxel_scene` may want at VP4.1.
Every commit of this plan still stages only its own paths (`git commit -- <paths>`), in case
another session is working in the worktree.

---

## Layout

```
poc_cubeworld/                          the POC app, and the workspace root
  pubspec.yaml                          + workspace: [packages/voxel_core, packages/voxel_scene]
  packages/
    voxel_core/                         pure Dart — no Flutter SDK dependency
      pubspec.yaml                      vector_math, meta; dev: test · version 0.0.0 · publish_to: none
      analysis_options.yaml             strict-casts/inference/raw-types + package:lints/recommended
      lib/voxel_core.dart               the barrel; lib/src/<area>/...
      test/
    voxel_scene/                        Flutter + flutter_scene
      pubspec.yaml                      flutter, flutter_scene: 0.23.0 (exact), voxel_core
      lib/voxel_scene.dart
      shaders/  tool/build_shaders.dart  assets/shaders/terrain.shaderbundle
      test/
```

`voxel_core` declares no `flutter` dependency, so a Flutter import in it fails to resolve
instead of slipping past review. Neither package ever imports `package:cubeworld_poc`.

## What moves, measured at HEAD + the stage 32 worktree

| POC file | Lines | Importers (lib / test) | Destination |
|:---|--:|:--|:---|
| `core/ivec3.dart` | 48 | 23 / 7 | `voxel_core`, as is |
| `world/chunk_mesher.dart` | 820 | 2 / 4 | `voxel_core` (`visibleForTesting` from `package:meta`) |
| `core/blocks.dart` | 454 | 16 / 10 | **split**: `BlockShape`, `CollisionBox`, boxes per shape → `voxel_core`; the 125 `BlockDef` rows and their queries stay in the POC and *build* a core block table |
| `world/chunk_worker.dart` | 168 | 1 / 0 | `voxel_core`, generic over a generator factory |
| `world/voxel_world.dart` | 722 | 18 / 9 | **split** (VP1.6, VP2.2): scheduler, edits, light store → `voxel_core`; nodes, materials, upload budget → `voxel_scene`; the POC's `VoxelWorld` stays as the facade, so its 18 importers do not change |
| `entities/voxel_body.dart` | 217 | 6 / 2 | `voxel_core` without the scene `Node` |
| `player/player.dart:340` `voxelRaycast` (+ `:1970` `liquidRaycast`) | ~45 | — | `voxel_core` free functions; `Player` delegates |
| `world/terrain_material.dart` + `shaders/` + `tool/build_shaders.dart` + bundle | 72 + 57 | 3 / 0 | `voxel_scene` |
| `world/terrain_generator.dart` | 1,308 | 3 / 5 | **stays** (a future `voxel_worldgen`) |
| liquid flow, `Circuits`, dimension rules, save magic | — | — | **stay** in the POC facade |

Four couplings the moves must cut, all found while measuring:

1. **The chunk size is declared three times**: 16×16×128 in `ChunkMesher`, `VoxelWorld` and
   `TerrainGenerator`. It becomes one constant set in `voxel_core`, which the other two read.
2. **The mesher's shape ints duplicate `BlockShape`**: `shapeCube = 0` through
   `shapeRailSlopeW = 24` follow the enum's order exactly. One source replaces both, the enum's
   `index`.
3. **The engine names content**: `VoxelBody.inLava` compares against `'lava'`, and the flow
   checks `'water'`, `'lava'` and `Blocks.has('obsidian')`. In the packages a liquid is an id
   with a kind index from the block table. Named kinds stay in the POC.
4. **The world imports the game**: `voxel_world.dart` builds `Circuits(this)`. The core
   streamer only emits block-changed events, and the POC facade wires circuits to them.

---

## Verification — the same four checks after every step

| Check | Command (from `poc_cubeworld/`) | Passes when |
|:---|:---|:---|
| Analyze | `flutter analyze` (covers `packages/` too — verified in VP0.1) | POC: no errors (stock lints, as today). Packages: zero issues |
| Tests | `flutter test` · `cd packages/voxel_core && dart test` · `cd packages/voxel_scene && flutter test` | all green |
| Parity | `test/voxel_parity_test.dart` (VP0.3) | the hashes committed before VP1 are unchanged |
| Probe logs | `tool/probe_baseline.sh` (VP0.2) re-run and diffed against `docs/baseline/` | identical except the lines carrying `ms` or `fps` |

At the end of VP1.5, VP2.2 and VP3 the performance loop from
`PERFORMANCE_VS_GODOT_2026-09-11.md` also runs: release build, radius 8, 12 and 16.

---

## VP0 — Scaffold & baseline

- **VP0.1** *(can start now: touches only `pubspec.yaml`, `pubspec.lock`, `packages/`,
  `docs/`)* Create both packages empty: pubspecs, analysis options, a barrel and one smoke
  test each. Add `workspace:` to the POC's pubspec with `resolution: workspace` in each
  package. Run `flutter pub get`. Confirm three things in writing below:
  - `flutter analyze` at the root reaches `packages/`;
  - `dart test` works in `voxel_core` under a workspace whose root is a Flutter app (if not,
    the check uses `flutter test` there);
  - the POC still builds and runs.
- **VP0.2** *(after stage 32 lands)* Write `tool/probe_baseline.sh`. It builds the debug app
  and runs `--new --seed=42 --frames=300 --settle=10` with `--stage31`, `--stage32` and a plain
  radius-8 window. Commit the three logs under `docs/baseline/` with the POC SHA they came from.
- **VP0.3** Write `test/voxel_parity_test.dart`, FNV-1a over every array the current code
  produces:
  - `TerrainGenerator(seed: 42)` for the 3×3 ring around (0,0) and (5,−3);
  - `ChunkMesher.build` on both rings, all four surfaces plus the two light volumes;
  - `editsToBytes` of a fixed set of edits.

  The expected hashes are pasted as constants. This test is never edited again until VP3 (VP3
  changes the mesh on purpose and re-pins it).

**Gate:** `flutter pub get` resolves; the four checks pass on untouched code; baseline logs and
hashes are committed.

**VP0 findings (2026-09-14, at `b57cf2a2`):**
- The workspace resolves from the POC root. `flutter pub get` rewrote both packages'
  `analysis_options.yaml` with its platform excludes (kept).
- `flutter analyze` at the root reaches `packages/`: a deliberate unused local in
  `voxel_core/lib` was reported with its `packages/voxel_core/...` path. Both packages
  analyze clean on their own.
- `dart test` under the workspace is proven at VP1.1, the first step with a package test. An
  empty package has nothing to run.
- The POC's 103 tests pass after the workspace change. `voxel_parity_test.dart` pins 48 hashes.
  Nine surfaces are empty in the fixture (hash `0x811c9dc5`): the glow surface in both rings
  and the cutout surface at (5,−3).
- `--stage32` hung once for 9 minutes inside the baseline script and finished in under a minute
  when run alone. The script now gives each probe 240 s and fails loudly.

## VP1 — `voxel_core`, by moves

Each step moves the code, rewrites the POC's imports mechanically, and changes behaviour in
nothing. **API polish waits for VP4**, so a diff here is a move plus the minimum seam.

- **VP1.1** `IVec3` → `voxel_core/lib/src/math/ivec3.dart`. 30 import lines rewritten.
- **VP1.2** Chunk dimensions (`ChunkSize.x/z/y`, `volume`, `index`) plus `BlockShape` and
  `CollisionBox` with the box list per shape → `lib/src/grid/`. `Blocks`, `ChunkMesher`,
  `VoxelWorld` and `TerrainGenerator` read the constants from there.
- **VP1.3** `ChunkMesher`, `ChunkMeshResult`, `MeshSurface` → `lib/src/mesh/`. The shape ints
  become `BlockShape.x.index`.
- **VP1.4** `VoxelBlockTable` → `lib/src/grid/`. Its fields:
  - per id: shape, solid, opaque, emission 0–15, linear rgba, liquid kind index (−1 for none),
    source flag;
  - typed-array views for the isolates (`palette`, `shapes`, `opaque`, `emission`);
  - queries (`isSolid`, `isOpaque`, `collisionBoxes`, `liquidKind`).

  Air is id 0, asserted. The POC's `Blocks` builds one table from its `defs`. `Blocks`' static
  API stays, so its 26 importers do not change.
- **VP1.5** `ChunkWorkerPool` + `WorkerConfig` → `lib/src/streaming/`, generic over
  `abstract interface class ChunkGenerator { Uint8List generate(int cx, int cz, int dimension); }`.
  `WorkerConfig` carries a `ChunkGenerator Function()` built by the POC
  (`() => TerrainGenerator(ids: ids, seed: seed)`) and a `VoxelBlockTable`. A test proves the
  factory crosses `Isolate.spawn`. The pool size stays **3** here, so the perf check measures
  the move alone.
  - **VP1.5b** Default the pool size to `max(1, Platform.numberOfProcessors - 1)`, in its own
    commit, and measure it. The 2026-09-11 run showed radius-16 fill going from 2,981 to
    1,956 ms at 10 isolates.
- **VP1.6** `ChunkStreamer` → `lib/src/streaming/`. It takes the scheduler out of
  `VoxelWorld`:
  - the window with its load and unload radii, the distance-sorted pending list;
  - 3×3 ring readiness, the gen and mesh in-flight sets, `remeshAgain`, the generation epoch;
  - chunk volumes and per-chunk edit deltas, `setBlock` with its remesh-neighbourhood rule;
  - light volumes and `lightAt`, block-changed listeners.

  Finished results go to `abstract interface class ChunkMeshSink { void apply(ChunkPos, ChunkMeshResult); void remove(ChunkPos); }`.
  The POC's `VoxelWorld` keeps its public members, delegates to the streamer, implements the
  sink with the nodes it still owns, and keeps flow, circuits, dimensions and the save magic.
  Unit tests use a fake sink and a flat generator.
- **VP1.7** `EditDeltaCodec` → `lib/src/persistence/`. Magic and version are parameters. The
  POC passes `0x4342574F` and version 2, so existing saves still load byte for byte.
- **VP1.8** `VoxelBody` → `lib/src/physics/`:
  - `late VoxelWorld world` becomes `VoxelQuery` (`int blockAt(x, y, z)`, `VoxelBlockTable table`);
  - the `Node` and `syncNode` leave, into a POC `SceneBody extends VoxelBody` that
    the four subclasses (`Player`, `Mob`, `Boat`, `ItemDrop`) extend;
  - `inWater` and `inLava` become `feetLiquid` / `headLiquid` kind indices; the POC keeps
    `inLava` as a getter.

  The POC's `VoxelWorld` implements `VoxelQuery`.
- **VP1.9** `voxelRaycast` and `liquidRaycast` → `lib/src/physics/raycast.dart`, as free
  functions over `VoxelQuery` with a hit predicate. `RayHit` moves with them.

**Gate:** the four checks; `grep -rn "dart:ui\|package:flutter/" packages/voxel_core` is empty;
the perf loop at VP1.5 lands within 10% of the baseline.

## VP2 — `voxel_scene`, by moves

- **VP2.1** `TerrainMaterial`, `terrain.frag`, `terrain_cube.frag`, `tool/build_shaders.dart`
  and the bundle → `voxel_scene`. The asset key becomes
  `packages/voxel_scene/assets/shaders/terrain.shaderbundle`. **Risk checked first:** whether
  `gpu.loadShaderLibraryAsync` resolves a package asset key. If it does not, the package
  exposes `loadLibrary(String assetKey)` and the POC keeps listing the asset.
- **VP2.2** `VoxelChunkView implements ChunkMeshSink`. It holds:
  - the root `Node` and one node per chunk;
  - `MeshGeometry.fromArrays` with light in `texCoords1`;
  - the 7 ms per-frame upload budget;
  - the four materials, `setSkyIntensity`, and the face and chunk counters the probe prints.

  The POC's `VoxelWorld` composes it and loses every `flutter_scene` import except
  `Vector3`.

**Gate:** the four checks; `grep -n flutter_scene lib/src/world/voxel_world.dart` is empty; the
perf loop within 10% of the baseline.

## VP3 — The render gap (measured in the POC, fixed in the packages)

- **VP3.1** Profile before fixing. Take a `--profile` DevTools timeline at radius 16, split into
  UI and raster time, and compare draw calls against vertex count. The ceiling today is 4
  surfaces × 1,225 chunks = 4,900 meshed nodes. Record the numbers here. They pick VP3.2 or
  VP3.3.
- **VP3.2** If vertex cost dominates, use greedy meshing. **Known blocker:** `_noise`
  multiplies every voxel's colour by a positional hash (±7%), so no two neighbouring faces share
  a colour and nothing can merge. Move the jitter into the terrain shader first, as a hash of
  the world cell. Then merge only quads with equal colour, AO and light. Re-pin the parity
  hashes in the same commit.
- **VP3.3** If draw calls dominate, batch chunks into regions: one node per surface per 4×4
  chunks, remeshed when one of its chunks changes.

**Gate:** radius-16 sustained fps above 70 in the release POC, recorded beside the
2026-09-11 table.

## VP4 — Release prep `0.0.1`

- **VP4.1** API review: public names, docs on every public symbol, nullable-return fallbacks
  removed (`IVec3.parse` returning null becomes a throw), barrel exports trimmed to intent.
  The POC follows in the same commits.
- **VP4.2** A standalone `example/` in each package with a small built-in generator, so the
  release runs without the POC. `voxel_scene`'s example is macOS, with `FLTEnableFlutterGPU`
  and **no app-level `hook/build.dart`** (the POC's hooks_runner gotcha).
- **VP4.3** README per package, `CHANGELOG.md` with a single `0.0.1` entry, LICENSE (`VD6`),
  `dart pub publish --dry-run` clean.
- **VP4.4** Export: copy both packages into a new repository as one commit. The POC may then
  consume them from that repository or stay on the workspace copy (developer's call then).

---

## Decision register

| ID | Question | Recommendation | Why |
|:---|:---|:---|:---|
| `VD1` | Packages under `poc_cubeworld/packages/` with the POC as workspace root, or at the worktree root? | **Under the POC** | The worktree root is the frozen 2D app with `flame`. Rooting the workspace in the POC keeps that app and its lockfile out of it |
| `VD2` | Move then polish, or design the final API while moving? | **Move then polish (VP4)** | A move with identical hashes is provable; a redesign mid-move is not. The POC stays playable at every commit |
| `VD3` | Package lint level | **strict-casts / inference / raw-types + `package:lints/recommended`, zero issues** | A published package is judged by pub.dev's analysis. The POC keeps its stock lints |
| `VD4` | `flutter_scene` pin | **Exact `0.23.0`** | `TerrainMaterial` imports the private `package:flutter_scene/src/gpu/gpu.dart`, which may move in any release |
| `VD5` | Web in `0.0.1`? | **No** | `dart:isolate` has no web implementation; the pool would need a web-worker twin, and the WebGL2 path is unmeasured |
| `VD6` | License for `0.0.1` | **MIT, decided at VP4.3** | Matches `flutter_scene`, and it is what the Flutter 3D packages found in the scan use |
| `VD7` | Terrain generator, liquid flow, circuits in `0.0.1`? | **No, they stay in the POC** | Their rules are content (biomes, named liquids, redstone); they become `voxel_worldgen` or similar after `0.0.1` |
