# Roadmap — stages and status (Flutter port)

One stage = one commit or a few. A stage is DONE only when it was seen running (screenshot
probe or interactive run). Status: ☐ todo · ◐ in progress · ✅ done. The stage numbers are
the Godot POC's, so the two roadmaps line up.

## Design decisions (settled, do not re-litigate)

- **Look**: Cube World — flat vertex colours, per-voxel ±5% colour noise, baked AO (4-level),
  sky + block light in the vertex colour, PBR material with roughness 1 lit by one sun with
  cascaded shadows and a constant-diffuse ambient. No textures. Sun scale 0.6, ambient 0.6,
  ACES; fog 0.003 blended to the sky.
- **World**: dense chunks 16×128×16 (`Uint8List`, byte = block index), sea level 46, radius 8
  streamed, 3×3 neighbour ring generated before a chunk meshes. Generation + meshing on a
  pool of 3 isolates; one `Node` per chunk with up to three mesh children (solid, cutout,
  liquid), `shadowStatic`, replaced whole on remesh.
- **Block table is code** (`lib/src/core/blocks.dart`), index order is the save contract —
  append only, identical to the Godot table.
- **Player / RPG / Survival / Save**: as the Godot POC (see its ROADMAP). Save bytes and JSON
  keys are the same, so a `worlds/<name>` folder is interchangeable between the two.
- **Verification without a screen**: `--screenshot=<png> --frames=N` renders and quits; the
  PNG is read back. Never screencapture the desktop.

## Stages

| # | Stage | Status | Notes |
|:--|:---|:---|:---|
| 0 | Worktree + project skeleton (`flutter create`, `flutter_scene`, Flutter GPU on, args forwarded) | ✅ | |
| 1 | Block/item/recipe/species tables | ✅ | `lib/src/core/`, unit-tested |
| 2 | `TerrainGenerator` + `ChunkMesher` in pure Dart on isolates | ✅ | `lib/src/world/`, unit-tested |
| 3 | Streaming world + delta save + screenshot probe; first screenshot | ✅ | 225 chunks in ~1 s |
| 4 | Player: body, third-person camera, voxel model, mine/place, highlight, swim/climb/glide/ladders | ✅ | `lib/src/player/` |
| 5 | HUD, hotbar, inventory + crafting UI, drops and pickups, chests with loot | ✅ | `--open-inventory` seen |
| 6 | Mobs (17 species), AI, melee/bow/staff combat, abilities, XP, levels, classes, boss troll | ✅ | `--strike`: zombie 18 → 8 hp |
| 7 | Day/night, spawn manager, hunger, fall/lava/drowning damage, death + respawn | ✅ | `--time=0.9` seen |
| 8 | Main menu (new world: seed + class, continue), pause menu, save/load (autosave 60 s) | ✅ | Flutter widgets |
| 9 | Dungeons, towers, camps with loot chests; boss in the dungeon | ✅ | generator port |
| 10 | Armor from inventory; glider; ranged classes | ✅ | |
| 11 | Quests, minimap, wolf companions, villages + traders, procedural SFX (SoLoud), debris, mob levels | ✅ | `--map` seen |
| 12 | Rivers, falling sand, beds, farming, fly mode F5, boss bar, F2 screenshot, footsteps, pause settings | ✅ | `--fly` aerial probe |
| 13 | **Play it by hand** — mining feel, combat feel, inventory clicks, trading, sleeping, farming | ☐ | needs a human at the keyboard; pointer lock only verified by code |
| 14 | Weapon rarity + random bonuses, spawner blocks, TNT chains, the Boomer, roaming bosses | ✅ | |
| 13b | Ranged combat, Cube World style: simulation-owned projectiles, staff spray / arc, bow / fan, 8-way volley | ✅ | `--fire=secondary` with `--class=mage` seen |
| 16 | Doors, wall torches, boats, enchanting table, sleeping animation | ✅ | `--stage16` seen |
| 18 | **RPG depth + weather.** Status effects (poison, burning, slow, regen, speed, strength, resistance, haste, well fed; chips on the HUD, ticks as coloured damage numbers), potions brewed at the brewing stand, talents (six shared + one signature per class, three ranks) spent in the journal (J), elite mobs (8% of hostiles: Swift / Sturdy / Venomous / Burning / Chilling / Giant, an aura light, ×2.5 XP), dodge roll (Left Alt, 0.4 s invulnerable), 20 achievements, waypoint blocks that teleport, a bestiary, and weather (rain / storm / snow on `flutter_scene`'s `ParticleEmitterComponent`, overcast sky, lightning flash + thunder). Probe flags `--stage18`, `--weather=`, `--journal=`. | ✅ | seen: storm with rain streaks, effect chips, the journal's talent tab; headless: 2 effects, Venomous elite spider, a talent spent, 2 waypoints + travel, dodge invulnerable |
| 19 | **Sub-block shapes in the mesher.** `slab` (bottom half), `fence` (post plus rails toward every fence or opaque neighbour, across chunk borders through the padded fill), `stairsN/E/S/W` (low step in front, high step behind, four ids behind one item, orientation from the placer's yaw). Blocks oak/stone/cobblestone slab, oak fence, oak/stone stairs, and their recipes. Probe flag `--stage19`. | ✅ | face counts unit-tested; bodies collide with all three as a full block (`VoxelBody` knows no sub-shapes) |
| 20 | **Fishing, horses, shears, buckets.** Fishing rod: right click casts a `Bobber` at the first water cell along the aim ray (a liquid raycast beside the solid one), a line runs from the hand, the bobber dips after 3–8 s and a second right click inside 1.5 s catches 70% raw fish / 10% salmon / 15% junk / 5% treasure. Horse (plains + forest, `mount`), tamed with wheat or an apple, F mounts within 3.5 m and WASD drives it at 8.5 m/s (sprint ×1.4, Space jumps); a ridden mob skips its AI and a tamed mount follows without fighting. Shears drop 1–3 wool and shrink the sheep for 120 s, and break leaves instantly into themselves. Buckets scoop and pour water or lava, and milk a cow. Probe flags `--stage20`, `--ride`. | ✅ | seen: the rider on the horse's back, the line down to the bobber on a fresh water block, the sheared sheep beside them; `--ride` moved the horse 0.85 m in ten frames at -8.6 m/s, the same figures the Godot POC reported |
| 21a | **Four more world structures** in the generator, on a second 4x4-chunk grid with its own hash; a candidate is dropped within 48 blocks of any primary structure so the two layers never overwrite each other. **5 ruin** (broken stone/mossy-brick walls 2-4 high around a cracked cobblestone floor, a chest half the time), **6 well** (3x3 cobblestone ring, water 4 deep, two fence posts, plank roof), **7 abandoned mine** (fenced head frame, ladder shaft to y 24, a 3x3 corridor 20-30 long with log-and-plank beams every 4 and torches on every second, iron/gold veins in the walls, a chest at the end, a spawner a third of the time), **8 desert temple** (sandstone step pyramid 9x9, a hollow chamber with two chests and a lamp, TNT under its floor, a south entrance). Probe `--stage21a` (`--kind=5..8`, `--biome=N`, `--fp`). | ✅ | seed 42 has a ruin 29 m from spawn, the same as the Godot POC; the temple and the mine corridor (beams, torch glow, a gold vein, the spawner at the end) both captured |
| 15 | **Multiplayer probe** (TCP + JSON lines on 7777, host-authoritative, puppets, replicas, host clock) | ✅ | two processes: the host captured peer 2's puppet beside it, the client got `hello` (seed + 20 edit bytes), 6 mob puppets, the host clock and the host's puppet; a zombie spawned beside the puppet hit the client (HP 26/30) through `hurt` |

## Session log

- **2026-09-10 s5** — stage 21a, the generator half of `5817cae3f`. A straight port: the same
  hash, the same 4x4 grid, the same 48-block clearance from a primary structure, so seed 42
  puts a ruin 29 m from spawn exactly as it does in Godot. One probe lesson of its own: a ruin
  in a forest sits under the canopy and the orbit camera ends up inside the leaves, so the
  readable captures are the temple (open desert) and the mine (`--fp`, its corridor is its own
  air pocket).

- **2026-09-10 s4** — stage 20 (`551d9830b`). Two engine differences: Godot's `ImmediateMesh`
  line is redrawn every frame, but a `LineSegmentsGeometry` here uploads a device buffer at
  construction, so the fishing line is a thin cuboid stretched and rotated from the hand to the
  bobber each frame instead. And a probe cannot press `Input.action_press` here, so `GameInput`
  grew `probeHold(action, down)` which injects the action's physical key; `--ride` uses it and
  reproduces the Godot numbers exactly (0.85 m in ten frames at -8.6 m/s).

- **2026-09-10 s3** — stage 19 (`0c0188eb2`): one `_subBox` in the mesher emits any
  axis-aligned box in block-local space, culling and lighting a face flush with the block
  boundary exactly like a cube face and lighting an inner face from the cell with no AO.
  Twelve blocks appended. The face counts are a unit test rather than a screenshot, because a
  half-height box is hard to read from a frame: an isolated slab is 6 faces, a lone fence post
  6, two fences 32 (each rail's far face meets the same block id and is culled), and one
  stairs 11 (six for the bottom slab, five for the step whose underside is skipped).

- **2026-09-10 s2** — stage 18 ported from the Godot POC's `c07fd0f20`: `effects.dart`,
  `talents.dart`, `achievements.dart`, `weather.dart` and `journal_screen.dart` are new; the
  block table grew by `brewing_stand` and `waypoint` (appended, so the save bytes still match
  Godot's). Two engine differences: Godot's `GPUParticles3D` became a
  `ParticleEmitterComponent` with a `BoxEmitterShape` (rain uses `BillboardFacing.velocityStretched`
  so a drop stretches along its own velocity, which is what the Godot `BILLBOARD_FIXED_Y` quad
  did by hand), and the rate is `amount / lifetime` scaled by intensity rather than Godot's
  `amount_ratio`. The mob health bar is painted by the HUD here, so the affix colour arrives
  through `Mob.barColor()` instead of a bar mesh material.

- **2026-09-10 s1** — worktree `poc_cubeworld` created from `dev`; the Godot POC read whole;
  every file ported; first screenshot through the probe; look tuned against the Godot frames
  (fog toward sky, sun 0.6 / ambient 0.6); shadows confirmed with a low sun; stages 13b, 16
  and 15 seen through `--fire`, `--stage16`, `--strike` and the two-process `--wait-peer` run.
  Stage 13 (playing it by hand) is the one thing a probe cannot do.
