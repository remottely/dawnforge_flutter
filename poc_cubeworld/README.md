# Dawnforge Cubeworld POC (Flutter) — the Cube World + Minecraft clone, ported to `flutter_scene`

**What this is.** A self-contained Flutter project on branch `poc_cubeworld` of the
Dawnforge Flutter repo, in the worktree `../dawnforge_cubeworld_poc/`. It is the Flutter twin
of the Godot POC at `~/Documents/godot/remottely/dawnforge_cubeworld_poc/poc_cubeworld/`
(branch `poc_cubeworld` of `tessera_project`): same game, same block table, same save
format, same probe flags, ported file by file onto
[`flutter_scene`](https://pub.dev/packages/flutter_scene) (Flutter GPU / Impeller).
It shares NOTHING with `lib/src/core` of the study track on purpose: the brief is the same
as the Godot one — *"não foque em arquitetura, foque em entregar o clone do jogo
funcionando"*. Nothing here is merged as-is.

**Lineage.** Every file in `lib/src/` is a port of its Godot sibling (`src/**.gd` and
`csharp/*.cs`). The C# `TerrainGenerator` and `ChunkMesher` became pure-Dart classes that
run on a pool of isolates (`chunk_worker.dart`); the GDScript autoloads became static
tables; Godot's `CanvasItem` HUD became a `CustomPainter`; ENet became TCP + JSON lines.
`ROADMAP.md` is the stage list and the live status of the port.

## Running

```bash
cd poc_cubeworld
flutter run -d macos                                   # Flutter GPU is enabled in Info.plist
flutter build macos --debug                            # then:
build/macos/Build/Products/Debug/cubeworld_poc.app/Contents/MacOS/cubeworld_poc \
  --screenshot=/tmp/shot.png --frames=300 --seed=1337 --new    # self-report, exits when captured
flutter test                                           # tables, generator, mesher (pure Dart)
```

Probe flags (same as the Godot POC, plus a few for tuning): `--screenshot=<png> --frames=N
--seed=N --radius=N --class=warrior|ranger|mage|rogue --time=0..1 --fly --fp --tp=x,y,z
--look=yaw,pitch --settle=N --map --open-inventory --fire=primary|secondary --stage16
--strike --stage18 --stage19 --stage20 --ride --stage21a --kind=5..8 --biome=N --stage21b --stage22 --weather=clear|rain|storm|snow --journal=0..3 --host --join=<ip> --wait-peer --trace`, and for the look: `--sun=k --amb=k
--tm=aces|agx|neutral|linear --fogd=density --noshadow --shadowcache=0|1
--casterfaces=front|back`. The debug app forwards the process arguments to Dart
(`MainFlutterWindow.swift`), so no `--` separator is needed.

Saves live in `~/Library/Application Support/cubeworld_poc/dawnforge_cubeworld_poc/worlds/<name>/`
(`blocks.bin` edit delta + `player.json`, the same bytes as the Godot POC). F2 writes a
screenshot next to them.

| Key | |
|:---|:---|
| WASD / Space / Shift / Ctrl | move / jump / sprint / sneak |
| Menu | **Host** opens port 7777 on your world; type an address and **Join** to play in someone's world |
| F | board or leave a boat (place one with the Boat item on water); talk to a villager |
| Mouse | look (third person orbit; the pointer is locked with `pointer_lock`, Esc opens the pause menu and releases it) · LMB attack or mine (hold to keep firing a bow or staff) · RMB place or use · RMB with a bow = fan shot, with a staff = arc |
| 1-9, wheel | hotbar |
| E / Tab | inventory + crafting |
| Q / H / F / V / G / R | drop · eat · interact · first/third person · glider · class ability |
| F1 / F2 / F5 / M / Esc | debug text · screenshot · fly mode · minimap · pause |

## What the port taught (the case study for `dev`)

- **`flutter_scene` carries the whole rendering stack** the Godot POC leaned on: vertex
  colours through `MeshGeometry.fromArrays`, a `GradientSkySource` that doubles as the
  `SunLight` with cascaded shadows, exponential fog blended toward the sky, ACES tone
  mapping, `PointLightComponent` for the held torch. 225 chunks / ~300k faces render at 60
  fps on an M-series Mac in a debug build.
- **Isolates replace `WorkerThreadPool`.** Generation and meshing are pure Dart on three
  isolates; results cross as `TransferableTypedData`. The first 13×13 window fills in about
  1 s. `FastNoiseLite` from `flutter_scene/noise.dart` is the same algorithm family as
  Godot's (OpenSimplex2S, fBm, ridged), so the biome recipe ported unchanged.
- **Front faces wind counter-clockwise** in `flutter_scene` (glTF), clockwise in Godot: every
  quad's diagonals are mirrored in the mesher and the voxel builder.
- **Flutter has no pointer lock**; `pointer_lock` (macOS) supplies relative deltas drained
  once per fixed step, which is exactly the shape `InputHelper` would want.
- **The camera collision ray works the same**, but the model must hide when the orbit
  camera is pulled inside it (`camDistance < 1.1`).
- **The Flutter tool's build-hook runner rejects symlinks** under the package root
  (`hooks_runner` `wrapLink` → `UnimplementedError`) and the macOS SwiftPM plugin links
  live there, so this project has no app-level `hook/build.dart`: `flutter_scene` compiles
  its own shaders with its own hook, and the game has no asset pipeline to run.
- **Screenshots come from a `RepaintBoundary`** around the `SceneView` + HUD + overlays,
  captured after `endOfFrame` (capturing inside the tick trips `debugNeedsPaint`).
