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
--strike --stage18 --stage19 --stage20 --ride --stage21a --kind=5..9 --biome=N --stage21b --stage22 --stage23 --stage24 --slot=<name> --open-map --open-settings --stage25 --reject-one --stage26 --shot=biome|village|trade|portal|fortress|cavern|tutorial --stage27 --stage28 --stage29 --kind=4 --stage30 --title-probe --stage31 --no-light --shot=room|cave --stage32 --shot=combat|mining --open-worlds --open-credits --credits-t=N --no-tutorial --weather=clear|rain|storm|snow --journal=0..4 --host --join=<ip> --wait-peer --trace`, and for the look: `--sun=k --amb=k
--tm=aces|agx|neutral|linear --fogd=density --noshadow --shadowcache=0|1
--casterfaces=front|back`. The debug app forwards the process arguments to Dart
(`MainFlutterWindow.swift`), so no `--` separator is needed.

Stage 30 probes: `--stage30 --title-probe --frames=200 --settle=10 --screenshot=<png>` runs the
title half (the buttons, a world created / listed / renamed / deleted through `Worlds`, the
credits rows parsed from the bundled `ROADMAP.md`), then starts a creative mage world in
slot `probe30_stats` through the same path as Play (damage ignored, a free block, fly, the
tutorial driven through seven steps and skipped, the stats saved and read back in a rebuilt
session; the slot is removed at the end, the tutorial flag goes to `settings_probe30.cfg`).
Captures: `--title-probe --screenshot=<png>` (the title) · `--title-probe --open-worlds` (the
world list with the form) · `--title-probe --open-credits [--credits-t=seconds]` (Flutter
only) · `--new --seed=42 --stage30 --shot=tutorial` (the card on step 4).

Stage 31 probe: `--new --seed=42 --frames=300 --settle=10 --stage31 --screenshot=<png>` builds a
torch-lit room, a pit with an overhang and an S maze east of spawn, then prints the sky / block
light at the room centre, under the overhang and outside, the room going dark after the torch
is removed (the 3x3 ring remesh), the AO vertex count, the spawn gate dark / lit, a zombie
through the maze on A* against the straight-chase control, and the mesher's own clock (add
`--no-light` to skip both light BFS for the cost comparison). Captures: `--shot=room --time=0.0`
(inside the room at night) · `--shot=cave` (the pit's mouth by day).

Stage 32 probe: `--new --seed=42 --frames=300 --settle=10 --stage32 --screenshot=<png>` builds a
stone pad across the border between the spawn chunk's east neighbour and the chunk west of it,
then prints a torch's block light on the far side of the seam (and the mesher's clock), the
knockback / flash / hit-stop of a swing and the shake / vignette / flash of the player's hit, the
crit count over 200 swings, the crack overlay at progress 0.5 and the break burst with its family
voice, the footsteps over a 5 m walk, the daylight rule for a zombie in the sun, under a roof and
in a pool, the topple-and-fade death clock, and two merged apple toasts with the low-HP pulse.
Captures: `--shot=combat` (a zombie mid-knockback, the flashes, the numbers and the red vignette)
· `--shot=mining` (cracks and chips on a raised stone block, first person).

### The terrain shader (stage 31)

The lit terrain draws with `shaders/terrain.frag`, flutter_scene's standard lit fragment
shader with the voxel light term folded into the albedo (`lib/src/world/terrain_material.dart`).
It is compiled by hand into `assets/shaders/terrain.shaderbundle` (committed, a plain pubspec
asset; there is no app-level build hook):

```bash
cd poc_cubeworld
dart tool/build_shaders.dart   # after editing shaders/*.frag, and after every Flutter upgrade
```

The script runs the SDK's `bin/cache/artifacts/engine/darwin-x64/impellerc` (an arm64 binary on
Apple silicon) with the arguments flutter_gpu_shaders' hook uses, `--gles-language-version=300`
(without it spirv_cross aborts on the lighting code) and flutter_scene's `shaders/` on the
include path. A bundle is tied to the engine that compiled it: a stale one fails at boot with
a message naming the script.

Saves live in `~/Library/Application Support/cubeworld_poc/dawnforge_cubeworld_poc/worlds/<name>/`
(`world.json` from the New World form, `blocks.bin` edit delta + `player.json`, the same bytes
as the Godot POC). F2 writes a screenshot next to them.

## Starting the game

The game boots into the **title screen** (stage 30): a slowly orbiting voxel vista behind
**Play**, **Multiplayer**, **Settings**, **Credits** and **Quit**. A probe boot (`--new`,
`--slot=`, `--seed=`, `--continue`, `--screenshot=`, `--host`, `--join=`) skips it and lands in
the world as before; `--title-probe` forces the title even then.

- **Play** lists your worlds (`worlds/<slot>/`): name, mode, class, seed, dimension, play time
  and last played. Select one and **Play** (or double-click), **Rename** it, or **Delete** it
  (asks first). **New world** opens the form: a name, a seed (a number, any text — hashed —, or
  empty for a random one), **Survival** or **Creative**, and the class; **Start** creates the
  slot and boots it.
- **Creative** worlds take no damage, never get hungry, place blocks without spending them and
  fly with **F5** (Space up, Ctrl down). Survival keeps its feet on the ground.
- **Tutorial**: a new world made from the title shows a card at the top of the screen with the
  next thing to do and the key for it — walk, look, jump, break a block, open the bag (E), craft
  a pickaxe, place a block, eat (H), sleep (or last until sunrise), open the journal (J). Each
  step completes when you do it; the card's button or **F6** skips the rest. Done once, it stays
  done (`settings.cfg`; the Settings screen can re-arm it). `--no-tutorial` keeps a probe quiet.
- **Multiplayer** hosts one of your worlds on port 7777 or joins an address with a class.
- **Settings** is the same panel as the pause menu; **Credits** scrolls the engine, the fonts,
  the audio and every stage of `ROADMAP.md` (bundled as an asset, read at runtime; Esc closes).
- **Esc** in-game: settings, a **Stats** block (play time, metres walked, blocks broken and
  placed, mobs killed, deaths, dimension trips), save, **Save & back to title** (solo), quit.

| Key | |
|:---|:---|
| WASD / Space / Shift / Ctrl | move / jump / sprint / sneak |
| Title → Multiplayer | **Host** opens port 7777 on the selected world; type an address and **Join** to play in someone's world |
| F | board or leave a boat (place one with the Boat item on water); on a villager: the trade screen (three offers, click a row; gold ingots are the coin, sell wheat or melon slices to earn them; Esc / F closes) |
| Mouse | look (third person orbit; the pointer is locked with `pointer_lock`, Esc opens the pause menu and releases it) · LMB attack or mine (hold to keep firing a bow or staff) · RMB place or use · RMB with a bow = fan shot, with a staff = arc |
| Portal | Lava touched by water turns to obsidian (a diamond pickaxe mines it). Build a frame 4 wide and 5 tall with a 2 x 3 hole, aim a Flint and Steel (iron + flint) inside it, and stand in the purple glow for two seconds: you arrive in the **Underworld** — hellstone caverns over a lava sea, soul sand that slows you, glowstone, quartz, blazes, wither skeletons and magma cubes, and somewhere a nether-brick **fortress** whose throne room holds the Underworld Lord and, once he falls, the core that gives up the Underworld Heart. A return portal waits where you arrive. No sun, no weather, no sleeping, and water hisses away down there. In multiplayer everyone in the same dimension sees each other, a different dimension is invisible, and mobs exist only where the host is |
| RMB on a lever / button / door | flips the lever, presses the button (1 s), opens a wooden door; an iron door only opens when powered — wires carry power 15 cells from a lever, button or pressure plate to lamps, iron doors, pistons and TNT |
| Rails | RMB with a Rail (6 iron + stick = 16) lays it turned toward the rails beside it — straight, corner, or a slope when the next rail is a block higher; a Powered Rail (6 gold + stick + redstone dust = 6) speeds a cart up while a lever, button or wire powers it and brakes it when nothing does. RMB with a Minecart (5 iron) on a rail sets it down; F within 2 m sits in it, W / S push it, F gets off; hit an empty cart to pick it up. A Chest Minecart (minecart + chest) carries 36 slots — F opens them (host / solo only). Every abandoned mine has a rail down its corridor and a chest cart of loot at the end |
| 1-9, wheel | hotbar |
| E / Tab | inventory + crafting |
| Q / H / F / V / G / R | drop · eat · interact · first/third person · glider · class ability |
| F1 / F2 / F5 | debug text · screenshot · fly mode |
| M | minimap, again: world map with markers (waypoints, structures, mounts, spawn), again: off |
| J | journal: talents, bestiary, achievements, waypoints, quests |
| Esc | menu: render distance, mouse, FOV, volume, weather, FPS overlay (saved in `settings.cfg` beside `worlds/`), save & quit — the world keeps running behind it |

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
