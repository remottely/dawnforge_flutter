# Roadmap — stages and status (Flutter port)

One stage = one commit or a few. A stage is DONE only when it was seen running (screenshot
probe or interactive run). Status: ☐ todo · ◐ in progress · ✅ done. The stage numbers are
the Godot POC's, so the two roadmaps line up.

## Design decisions (settled, do not re-litigate)

- **Look**: Cube World — flat vertex colours, per-voxel ±5% colour noise, baked AO (4-level) in
  the vertex colour; since stage 31 sky + block light ride the second UV set and the terrain
  shader (`shaders/terrain.frag`, flutter_scene's standard lit shader plus the voxel light term)
  scales the sky half by the time of day. PBR roughness 1, specular 0, lit by one sun (Godot's
  0.6) with cascaded shadows and a constant-diffuse ambient. No textures. Sun scale 0.6,
  ambient 0.6, ACES; fog 0.003 blended to the sky.
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
| 17 | **Close the stage 15 gaps.** Melee hit owned by the simulation: `meleeStrike(dir, dmg, followUp, attacker)` runs the reach check from the attacker's own centre; a client sends `melee` and the host resolves it against the puppet it owns. Mobs hunt the nearest body in `targets()` (the local player + `puppetBodies()` on the host); a `RemotePlayer` answers `centre()` / `isDead` / `takeDamage()` through the `Target` interface and forwards the damage to its peer as `hurt`; damage numbers reach clients as `dmg`. Probe flag `--strike`. | ✅ | re-verified 2026-09-14: solo zombie 18 → 8 at 2.01 m, the Godot figure; the host-side resolve and `hurt` were seen in the stage 15 two-process run. Engine difference: Godot splits mob packets into ≤6-row unreliable ENet packets with an epoch to stay under the MTU; TCP + JSON lines is a stream, so one `mobs` line carries every row and needs no split |
| 18 | **RPG depth + weather.** Status effects (poison, burning, slow, regen, speed, strength, resistance, haste, well fed; chips on the HUD, ticks as coloured damage numbers), potions brewed at the brewing stand, talents (six shared + one signature per class, three ranks) spent in the journal (J), elite mobs (8% of hostiles: Swift / Sturdy / Venomous / Burning / Chilling / Giant, an aura light, ×2.5 XP), dodge roll (Left Alt, 0.4 s invulnerable), 20 achievements, waypoint blocks that teleport, a bestiary, and weather (rain / storm / snow on `flutter_scene`'s `ParticleEmitterComponent`, overcast sky, lightning flash + thunder). Probe flags `--stage18`, `--weather=`, `--journal=`. | ✅ | seen: storm with rain streaks, effect chips, the journal's talent tab; headless: 2 effects, Venomous elite spider, a talent spent, 2 waypoints + travel, dodge invulnerable |
| 19 | **Sub-block shapes in the mesher.** `slab` (bottom half), `fence` (post plus rails toward every fence or opaque neighbour, across chunk borders through the padded fill), `stairsN/E/S/W` (low step in front, high step behind, four ids behind one item, orientation from the placer's yaw). Blocks oak/stone/cobblestone slab, oak fence, oak/stone stairs, and their recipes. Probe flag `--stage19`. | ✅ | face counts unit-tested; bodies collide with all three as a full block (`VoxelBody` knows no sub-shapes) → stage 22 |
| 20 | **Fishing, horses, shears, buckets.** Fishing rod: right click casts a `Bobber` at the first water cell along the aim ray (a liquid raycast beside the solid one), a line runs from the hand, the bobber dips after 3–8 s and a second right click inside 1.5 s catches 70% raw fish / 10% salmon / 15% junk / 5% treasure. Horse (plains + forest, `mount`), tamed with wheat or an apple, F mounts within 3.5 m and WASD drives it at 8.5 m/s (sprint ×1.4, Space jumps); a ridden mob skips its AI and a tamed mount follows without fighting. Shears drop 1–3 wool and shrink the sheep for 120 s, and break leaves instantly into themselves. Buckets scoop and pour water or lava, and milk a cow. Probe flags `--stage20`, `--ride`. | ✅ | seen: the rider on the horse's back, the line down to the bobber on a fresh water block, the sheared sheep beside them; `--ride` moved the horse 0.85 m in ten frames at -8.6 m/s, the same figures the Godot POC reported |
| 21a | **Four more world structures** in the generator, on a second 4x4-chunk grid with its own hash; a candidate is dropped within 48 blocks of any primary structure so the two layers never overwrite each other. **5 ruin** (broken stone/mossy-brick walls 2-4 high around a cracked cobblestone floor, a chest half the time), **6 well** (3x3 cobblestone ring, water 4 deep, two fence posts, plank roof), **7 abandoned mine** (fenced head frame, ladder shaft to y 24, a 3x3 corridor 20-30 long with log-and-plank beams every 4 and torches on every second, iron/gold veins in the walls, a chest at the end, a spawner a third of the time), **8 desert temple** (sandstone step pyramid 9x9, a hollow chamber with two chests and a lamp, TNT under its floor, a south entrance). Probe `--stage21a` (`--kind=5..8`, `--biome=N`, `--fp`). | ✅ | seed 42 has a ruin 29 m from spawn, the same as the Godot POC; the temple and the mine corridor (beams, torch glow, a gold vein, the spawner at the end) both captured |
| 15 | **Multiplayer probe** (TCP + JSON lines on 7777, host-authoritative, puppets, replicas, host clock) | ✅ | two processes: the host captured peer 2's puppet beside it, the client got `hello` (seed + 20 edit bytes), 6 mob puppets, the host clock and the host's puppet; a zombie spawned beside the puppet hit the client (HP 26/30) through `hurt` |

| 21b | **Replicate what stage 15 left local.** Drops: the host owns every `ItemDrop`, a client's spawn becomes a request, a client draws replicas that only fall and spin, and a drop pulled to a peer's puppet is handed over into that peer's own bag. Chests: the inventory lives on the host, a client opens a view and every grid click travels as the whole grid (last writer wins). Weather: the host broadcasts its roll on change and every 10 s. Mounts: mob rows carry `tamed` and `riddenBy`, a puppet copies both, a rider's puppet sits on that horse's puppet, and a client's ride input travels inside its pose. Effects: a mob's species or affix effect on a puppet reaches the peer's own player. Probe `--stage21b` (with `--wait-peer`). | ✅ | two processes: the host gave peer 2 iron_ingot x2 and reported it picked up; the client's capture shows the host puppet riding its horse puppet on the stone pad in a storm, poisoned, with the two ingots in its bag and the host's chest read as 3 apples |
| 22 | **Sub-block collision + liquid flow.** `Blocks.collisionBoxes(index)` gives every solid block its boxes in 0..1 space (slab = bottom half, fence = the 6/16 post 1.5 tall, stairs = bottom half + the mesher's back half); `VoxelBody` sweeps its AABB against those boxes instead of whole cells (`_solidBoxesAt` scans one row below the feet for the fence's extra half, `_resolveAxis` lands on the face of the box that was entered) and `tryStepUp` tries 0.52 then 1.02, each also nudged 0.05 into the blocked direction so a half step never beats a wall. `wallAhead` / `overlapsBlock` stay cube-based. **Liquids**: two appended ids `water_flow` / `lava_flow` (`Blocks.liquidKind` answers water / lava for both forms, `isLiquidSource` tells them apart); `VoxelWorld.tickFlow` runs on the host / solo only (`flowEnabled`), every 0.25 s for water and 0.6 s for lava, at most 400 cells a tick, over a queue only `setBlock` feeds. A cell falls first, spreads sideways only on a solid or a source (water 4 steps, lava 2), a flowing cell with no strictly closer feeder becomes air, lava touching water hardens to cobblestone. Buckets scoop sources only; every flow edit rides the existing per-block `block` message. Probe flag `--stage22`. | ✅ | seed 42, same site as Godot (x0 11, y0 66, z0 8): slab top 67.501, stairs top 68.001 with max vy 0 (no jump), fence stopped at 20.074 against the 20.375 post face with a jump peaking 1.35 m, water 43 cells at max dist 4 (42 flow writes), 0 after the source went, lava + water → 7 cobblestone: every figure inside Godot's. The capture shows the pad, the second puddle, the cobblestone crust, the slab, the stairs against its plank and the fence post. Unit-tested headless in `test/stage22_test.dart` (boxes, the three walks, a two-plank wall that a half step must not beat, 43 cells / drain / hardening, a client world that never flows) |
| 23 | **Temple boss + trap, loot tables, second abilities, three mobs, durability.** **Mummy King** (`mummy_king`, boss, 120 hp, speed 1.8, hits apply `slow`, XP 48, drops 2–5 gold + a guaranteed `ancient_blade`, a tier-4 14-damage sword) wakes once per temple when the player is within 6 m of the chamber centre (`Game._checkStructures`, key = chamber + `templeBossKeyY` 1000 in `_bossesSpawned`, so it rides the save). **Pressure plate** (appended id after `lava_flow`, dark `slab`, passed through `generatorIds()` last; the generator sets the temple chamber floor centre to it over the buried TNT): `Game._tick` checks the feet cell of the player, every mob and every pet each simulation tick on host / solo and, on `overlapsBlock`, clicks once per visit and lights the TNT below through `igniteTnt`; `litTntCount` / `probeDefuseTnt` read and undo the fuses. **Loot tables** in `lib/src/game/loot.dart` (`LootTables.tables` temple / mine / ruin / well / dungeon / camp as `LootEntry(item, min, max, chance)`, `roll(table, Random)`, `tableNear` = the nearest structure within 48 m, else camp); dungeon and temple chests keep the 45% bonus weapon. **Q abilities** (`GameAction.ability2`, `PlayerClass.ability2` / `mana2` through `manaCost`): Warrior *Shield Bash* (12 m/s lunge, every mob in the 3.5 m half-space ahead takes 0.8x melee and `Mob.stun(2)`: AI frozen, model tinted yellow), Ranger *Volley* (5 arrows over 40°), Mage *Frost Nova* (4 damage + `slow` 4 s within 5 m, half speed), Rogue *Smoke Bomb* (3 s invulnerable + Swiftness, mobs within 12 m `loseTarget(3)` and cannot aggro); the HUD stacks `[Q]` under `[R]`. **Mobs**: `bat` (cave only, `maxY` 50 through `Species.candidates(..., y)`; `flying`: no gravity, a new random 3D heading every 0.2–0.6 s, dives when nothing solid is 3 m below, steers at the target's centre when chasing), `bear` (forest, neutral, 40 hp, hits 6), `ghost` (ruins at night only through `_tickRuinGhosts`, at most two per ruin; `VoxelBody.noclip` skips the sweep, 45% alpha tint, slow flier, `slow` on hit); weight 0 keeps structure-only rows out of the spawner, `Spawner.forceSpawn` places one. **Durability**: weapons get `durability` 40 + 50 x tier (tools already 60 x tier²), the live count is `ItemStack.dur` (-1 = never worn, saved as `dur` only when set), `Player._wearHeld` takes one per melee swing, arrow, fan and tool-broken block, at 0 the slot empties with a break sound and a notice; the hotbar draws a green→red bar under a worn icon. Probe flag `--stage23` (with `--kind=8`; builds a 5x5x3 chamber beside the player if no temple is within 48 chunks). | ✅ | seed 42, same temple as Godot, 494 m out at (414, 54, -274): `Mummy King Lv 3 hp=163` (path temple, plate (414, 54, -274)), `tnt lit=true` after three ticks on the plate, Shield Bash 3/3 stunned, Volley 2/3 hit, Frost Nova 3/3 slowed, Smoke Bomb 3/3 lost the player, bat / bear / ghost alive after 60 ticks and the ghost drifted 2.04 m out of solid stone, iron sword 190 → 185 over five swings and the slot emptied from `dur` 1: every figure Godot's. The loot lines are seeded but not Godot's (Dart's `Random(23)` is not Godot's RNG). The capture, first person in the south corridor: the Mummy King between the two chests under the lamp, its boss bar on top, `[Q] Shield Bash (10s)` under `[R] Whirlwind`, "Your Iron Sword broke!" in the notices. `--strike` unchanged (18 → 8). Unit-tested in `test/stage23_test.dart` (plate id, durability numbers, wear + save round trip + break, loot ranges / determinism / real items, spawn filter, noclip) |
| 24 | **Save what lived outside the save, maps with markers, the quest tab, a settings screen, the bed checked.** **Persistence**: `saveGame` also writes Godot's keys `boats` (`pos`, `yaw`), `pets` (every tamed `Mob`: `species`, `pos`, `hp`, `max_hp`, `level`, `affix`, `tamed`, `name`, `yaw` through `Mob.toJson` / `fromJson` / `restoreTamed`), `mount` (the index of the ridden pet, restored through `Player.mountHorse`, so the rider boots seated), `drops` (`item`, `count`, `bonus`, `pos`), `visited` (`"x,z"` for every chunk the player stood in, marked once a second) and `structures` (`"x,y,z"` → kind for anything within 48 m of the once-a-second `_checkStructures` pass); a restored boat, drop or mob waits for its chunk before its physics run; the save's seed wins over the menu default unless `--seed=` is given. `--slot=<name>` points a run at `worlds/<name>`. **Maps**: M cycles minimap → world map → off (`Game.cycleMap`); both draw markers (`HudPainter._drawMarkers`): cyan diamond waypoints, a coloured square per structure kind 1–8, brown dots for tamed mounts, a white dot for the spawn; the world map (`WorldMap`, one pixel per block, rebuilt every 2 s through `decodeImageFromPixels`) covers every loaded chunk plus every visited one (flat grey out of the window), with labels, a "You" arrow and a legend. **Journal**: a fifth tab `Quests` (`JournalTabs.questEntries`): done greyed with a tick, the active one lit with a progress bar, the rest dim. **Settings** (`lib/src/game/settings.dart`, `settings.cfg` beside `worlds/` in Godot's `ConfigFile` text, loaded in `main`): the Escape menu holds render distance 4–10 (`Game.applyRenderDistance` + `VoxelWorld.trimWindow`), mouse sensitivity, FOV, master volume (`SoLoud.setGlobalVolume`), weather on/off (`Weather.setEnabled`: off forces Clear), an FPS overlay (when F1 text is hidden), Resume / Save / Save & Quit; the world never pauses. **Bed respawn** was already right; the probe proves it. Probe `--stage24` (with `--slot=probe24`): the first session builds the scene, saves, writes `probe24.flag` and asks the view for a fresh session; the second sees the flag, loads that save and prints the verify half. `--open-map` / `--open-settings`. | ✅ | seed 42: pre-save and post-load both `boats=1 tamed=2 drops=2 mounted=true waypoints=1 visited=3`, `horse pos delta=0.00`, `markers: waypoints=1 structures=1 mounts=1` (the ruin at (19, 56, 36), 30 m off spawn), `quests tab entries=12 active=Gather wood`, `radius 8->6 chunks loaded before=289 after=169`, `weather off -> Clear`, `settings.cfg written=true` (to `settings_probe24.cfg`), `respawn at bed … delta=0.00`: every line Godot's. Seen: the world map with You / Spawn / Horse / Waypoint 1 / Ruin labelled over the coast, the legend under it, the minimap beside it with the same markers; the menu (`--slot=probe24 --open-settings`) with four sliders, two switches and four buttons over the running world, the restored horse and boat behind it; the journal's Quests tab (`--journal=4`). `--strike` unchanged (18 → 8 at 2.02 m). Unit-tested in `test/stage24_test.dart` (boat / drop / tamed-mob keys and round trip, visited + structures codec, settings file + clamps, quest entries, trim) |
| 25 | **The host owns what moved on its own; the client predicts what it touches.** **Drop poses**: the host streams `drop_poses` (10 Hz, only drops that moved > 0.05 m, ≤40 rows a message) and an `ItemDrop.replica` no longer simulates — it lerps to the streamed pose (`setNetPose`, snaps beyond 8 m). **Bag overflow**: `Inventory.roomFor(item, count)`; the client's `give` answers `give_rest` for what did not fit and the host drops it at the puppet's feet (2 s pickup delay); a client re-declares its bag as `bag` 0.2 s after any change (`Player.bagDirty`) and the host pulls a drop toward a puppet only when that declared bag has room (`Net.peerHasRoom`). **Chests**: `chest_set` is one slot (`slot`, `stack`, `from_bag`), accepted only from a peer that has the chest open on the host and only when what enters is paid for — from the declared bag (debited) or from the escrow of what that peer took out and still holds (`Net.chestEditVerdict`, pure); a refused edit gets the standing state re-sent; `InventoryScreen` tracks `_cursorFromChest`. **Boats**: host-owned like drops (`Boat.netId` / `replica`, `boat` / `boat_poses` (10 Hz, moved > 0.02 m or turned) / `boat_free`, late joiners get the list after `hello`); a client's `spawnBoat` is `boat_req`; boarding a replica is `board_req` (`Player.boardBoat` / `leaveBoat`), the steer rides in the pose's `ride` field (x = steer, z = throttle) and the host's boat carries the puppet; breaking one is `break_boat_req`. **Crops**: a client no longer runs `_growCrops`; the host registers a `wheat_0` a client placed. **Bobber**: every peer streams its own bobber at 5 Hz (`bobber`, `bobber_gone`); the others draw a `Bobber.replica` hanging from that peer's puppet hand. **Flow batch**: `Game._tick` wraps `tickFlow` in `Net.beginBlockBatch` / `endBlockBatch`, so a tick's cells leave as one `blocks` message (flat x, y, z, id, ≤200 cells a message); single edits stay on `block`. **Prediction**: a client's edit is applied at once and sent as `block_req` with a `seq` (`BlockPrediction`); the host answers `block_ack` with the id that stands and the client rolls back when it differs; a host `block` / `blocks` for a cell with a pending prediction waits for the ack. Host flag `--reject-one` refuses the first client edit. Probe `--stage25` (host + client, `--wait-peer`; the host takes `--reject-one`). | ✅ | two processes, seed 42, Godot's site cells: host `drop poses sent=9` (Godot 10), `give rest spawned=1`, `chest edit rejected(not open)=1 accepted=1`, `boat spawned net_id=1 client aboard=true`, `flow batch rpcs=4 cells=24`, `rejected client edit seq=1`, `crop (5, 50, 8) grew to wheat_1 through setBlock`; client `bag got=1 rest dropped seen=true`, `chest state slots=3` (Godot 2: the loot roll is Dart's RNG), `aboard boat net_id=1 moved=1.95` (Godot 1.95), `predicted=1 rollbacks=1 (cell a back to stone: true, cell b oak_planks)`, `replica drop delta to host pose=0.000 (replicas 2)`, `flow cells seen=24`, `bobber replica of host seen=true`, `crop reads wheat_1`. The client's capture: the host puppet on the pad with its line down to the replica bobber in the basin, the boat the client rowed, the apple replica on the basin wall. `--stage21b` pair and `--strike` (18 → 8 at 2.02 m) unchanged. Unit-tested in `test/stage25_test.dart` (`roomFor`, prediction bookkeeping, chest accounting, the walled pool as 24 cells in 4 batches, the 200-cell split, replica lerps). Simplifications are Godot's (per-slot chest check with escrow, a trusted bag snapshot, prediction covers `setBlock` only, boat poses carry no velocity) |
| 26 | **Swamp and jungle, villages with traders, ambient music.** **Swamp** (biome 7, now low and flat: `surfaceHeight` presses the swamp climate band to two blocks over the sea): one-deep pools (`_swampPool`, a new `_detail` noise → water over `mud`), mud / clay / grass top patches, willows (`_placeWillow`), `reeds` on every pool edge. **Jungle** (biome 8, `t > 0.22 && hum > 0.28`): `jungle_log` trees 8–14 tall under a radius-3 canopy with `vines` hanging 2–5 below the rim, dense `fern`, `melon` patches (breaks into 3–5 `melon_slice`, food). Six blocks appended after `pressure_plate` (`mud reeds jungle_log vines fern melon`), `generatorIds()` extended at the end (+ `bed farmland wheat_2 oak_slab`). Maps tint the two biomes (`Hud.mapPixel`, biome sampled per 4×4 cell, shared by the minimap and the world map). **Spawns**: `slime` (12 hp, `splits` into two `slime_small` on death), spider and slime ×2.5 in the swamp (`SpeciesDef.biomeWeight`, `Species.weightIn`), `parrot` (passive flier, tamed with wheat seeds, hovers over its owner) and `ocelot` (neutral, 6.8 m/s) in the jungle. **Village** (kind 4, plains / forest only, trees felled in a radius 19): 4–7 huts (`_hutCount` / `_hutAt` ring) with a cobblestone floor, plank walls, slab roof, door gap, torch, bed and chest (`LootTables.tables['village']`, `tableByKind[4]`), gravel paths to the well, a fenced wheat plot; 3–5 `villager`s (`persistent`: never despawn, saved in `pets` with `trades` and `home`, turn back beyond `Mob.homeRadius` 16). **Trade**: each villager rolls 3 offers from `Mob.tradePool` (`TradeOffer`); F opens `ScreenKind.trade` (`TradeScreen`, a row per offer, click to trade through `Game.tradeRow`, Esc / F closes). **Music** (`lib/src/game/music.dart`): moods Meadow / Dunes / Jungle / Frost / Marsh / Deep (+ " Night": minor pentatonic, 0.8× tempo), picked once a second by `Game._updateMusic`, a `♪ <mood>` notice on change. Probe `--stage26` (`--shot=biome|village|trade`, `--kind=4` reaches a village through the 21a helper). | ✅ | seed 42, every generator figure Godot's: `swamp=48 jungle=44` chunks in the window; swamp `mud=768 pools=391 reeds=110` at chunk (-3, 3); jungle `jungle_log=458 vines=1413 fern=335 melon=20` at (2, 5); village at (-165, 152) `huts=4 chests=4 beds=4`. Random rolls are Dart's: villagers 4 or 5 (Godot 5), the probe's first offer `gold_ingot x1 -> bread x4` (Godot `gem_shard x3 -> diamond x1`), traded through the screen; slime split children=2; parrot tamed after 1–6 seeds (Godot 2); ocelot 6.8; moods Meadow → Meadow Night → Jungle → Deep, loops rendered and live on SoLoud (`playing=true`). Seen: the jungle (tall trunks, ferns, canopy, `♪ Jungle`), a swamp pool with reeds and willows (`♪ Marsh`), the village from a hover (four huts with slab roofs, gravel paths, villagers, `A village! F on a villager to trade`), the trade screen with three rows. `--strike` unchanged (18 → 8 at 2.02 m). Unit-tested in `test/stage26_test.dart` (block order, seed 42 swamp / jungle counts, village ring + a chest and bed per hut, offers + trade, villager save, weights, moods + a rendered loop) |
| 27 | **Redstone-lite.** `Circuits` (`lib/src/game/circuits.dart`, owned by `VoxelWorld`, host-only through the `flowEnabled` gate the flow already uses, ticked every simulation step inside the flow's `blocks` batch, recompute at most every 0.1 s): every state is a block id appended after the melon in Godot order (`redstone_ore`, `lever_off/on`, `button/_on`, `wire_off/on` — new `BlockShape.wire`, a 1/8 slab through the mesher's `_subBox` —, `redstone_lamp_off/on` (light 14), `iron_door_z/x` + `_open` mirroring the wooden door, `piston_n/e/s/w` + `_on`), so a flip is a plain `setBlock` and meshing, the save and the network batch come free. Sources: a lever on, a button for 1 s (`touch` starts the timer when `button_on` lands, from any side), a pressure plate while a body stands on it (`Game`'s plate check now collects the pressed set and hands it to `setPressedPlates`; the temple's TNT ignites through `onTntPowered` -> `igniteTnt`). Power runs along wires at strength 15 beside a source, one less per cell (15 cells reach, `strengthAt`); wires link on the same plane plus one step up/down along a block edge (the staircase rule). A live wire or a source powers its six neighbours: lamp on, iron door open (both halves), piston extends (pushes the block in front one cell when the cell past it gives way; the pushed block stays on retract), TNT ignites. An edit on or beside a circuit block marks its cell dirty; the tick floods every wire network the dirty cells touch (capped at 400) and recomputes it from scratch. Items: `redstone_dust` from the ore (veins below y 30 at about a third of coal's share), recipes for lever, button, wire x4, lamp, iron door, piston; RMB toggles a lever or presses a button (`click`), doors creak (new `door` voice); pistons and iron doors take the placer's facing like stairs; a wire needs a solid below like a plant. Strong emitters (light >= 10) draw on a fourth `glow` surface with an `UnlitMaterial` so a lamp reads at night. Probe `--stage27 --slot=probe27` (two boots like stage 24; `--time=0.05` for the night capture). Unit tests `test/stage27_test.dart`. | ✅ | seen on seed 42, same site as Godot (x0 11, y 67, z0 8), every line green and matching Godot's session log: lamp on/off through the lever (wire x5 `wire_on` while on), button lamp on at t=0.02 off at t=1.00 (simulation ticks), plate lamp on while standing / off after leaving, iron door closed-solid -> powered open (upper half too) -> walked through to x 16.29, wooden door by hand, strength 1 at 15 cells / 0 at 16, TNT under a live wire lit then defused, piston pushed a cobblestone from x 12 to 13, **3531 redstone ore below y 30 in 49 chunks (Godot: 3531)**, 21 recomputes, and after the reload lamp + wire on, door `iron_door_x_open`, lever `lever_on`. Captures: `stage27_day.png` (the bright 15-cell run with its dark 16th cell, the dark TNT run after the lever went off, the lit lamp, the grey iron door and the brown wooden door open, the extended piston with the gap before the pushed cobblestone) and `stage27_night.png` (the lamp glowing cream on the unlit surface, the rest dim). Simplifications as Godot: power to all six neighbours (no wire pointing), no sticky piston, `_power` rebuilt per tick and not saved. `--stage22` (same numbers as its row), `--stage23 --kind=8` (trap lit through the powered path) and `--strike` (18 -> 8) unchanged. |
| 28 | **Rails and minecarts.** Fourteen rail ids appended after `piston_w_on` in Godot order behind two items (`rail`: straights `rail_ns/ew`, curves `rail_ne/nw/se/sw`, slopes `rail_slope_n/e/s/w`; `powered_rail_ns/ew` + `_on` twins, light 4), each its own `BlockShape.rail*` (enum 15–24), so the mesher's `_subBox` draws two thin bars over wooden ties (tie colour × the cell noise), a curve as the two half-axes it joins, a slope as four rising steps; non-solid, a solid below needed like a wire, `rail_ew` last in `generatorIds()`. **`Rails`** (`lib/src/game/rails.dart`, static, pure over `VoxelWorld`): `connections(id)` (a slope's high end steps up), `orient(world, cell, base)` (a rail one up on a side over a solid makes a slope toward it, two sides a straight or a corner with the rails that face this cell first, one side a straight along it, none keeps the axis), `place` (orient, set, refresh the twelve neighbours, refresh itself once more), `removed`, `nextCell` / `endToward` (a flat end also finds a slope one cell down that climbs back). RMB with the rail item goes through `Rails.place`; `Game.onBlockBroken` calls `Rails.removed`. **Powered rails** are a circuit reactor: `Circuits._reactPoweredRails` floods the run of powered rails (four sides, cap 64) and lights every cell within eight of one that is directly powered. **`Minecart`** (`lib/src/entities/minecart.dart`, a plain object with a `Node`, no `VoxelBody`, `Game.carts`, stepped in `_tick` after the boats): `cell`, the entry / exit ends, `t` 0..1, a scalar `speed` (max 8); per tick 4 m/s² down a slope and against it up, 0.4 m/s² friction, +6 on a powered rail that is on and a 12 brake on one that is off, ±2 from the rider's push; a crossing takes the next rail, a line that ends stops and turns the cart round; a curve is two half segments through the centre, a slope the line between its end heights. `minecart` (5 iron) and `chest_minecart` (minecart + chest, an `Inventory`) are placed with RMB on an aimed rail; F within 2 m boards a plain cart or opens a chest cart's slots on the chest screen (`Game.openCartCargo`, host / solo only), F leaves, a melee swing at an empty cart drops it as its item (a chest cart spills). **Network**, host-owned like the stage 25 boats: `cart` / `cart_poses` (10 Hz with the boat poses, moved > 0.02 m or turned) / `cart_free`, late joiners get the list, `cart_req`, `cart_board_req`, `cart_unboard_req`, `break_cart_req`, the push rides in the pose's `ride.z`; replicas lerp. **Save**: `carts` rows (`kind`, `cell`, `from`, `to`, `t`, `speed`, `cargo`) beside the boats. **Mines**: `_mine` lays `rail_ew` from x 1 to len − 1 on the corridor's centre line before the chest (the spawner, a third of the time, overwrites one), and the first visit within 48 m spawns a chest minecart with `mine` loot at the corridor's last rail (`_checkStructures`, key `mineCartKeyY` 2000, set only once both corridor ends are loaded). Recipes: rail x16, powered rail x6, minecart, chest minecart. Probe `--stage28 --kind=7 --slot=probe28` (two boots like stage 27). Unit tests `test/stage28_test.dart`. | ✅ | seen on seed 42, same site as Godot (x0 11, y 59, z0 8), every line Godot's session log: `placed 24 rails: ns=6 ew=15 curves=1 slopes=2`; coasting from 6 m/s reached the west end (x 11.00) and stopped; **uphill 6 -> 3.93 m/s at the top, 3.07 m/s back down from rest (Godot 3.93 / 3.07)**; entered the corner heading +x and left heading +z; stopped dead on the unpowered rail, **peak 5.23 m/s within 2 s of the lever (Godot 5.23)**, both ends of the leg `powered_rail_ns_on`; F boarded, the push carried the player 0.86 m (Godot 0.89), F left; three apples through the chest cart's screen; **the mine at (-111, 53, -344) with 22 rails and its chest cart (Godot: the same mine, 22)**; after the reload `carts=3 rails intact=24`, lever on, leg lit, hp 30/30. Captures: `ride.png` (the player seated in the cart on the straight, ties and bars readable, the chest cart ahead, the stepped slope and plateau leading to the corner) and `mine.png` (`--stage21a --kind=7 --fp --look=-90,-20`: the rail down the corridor under the beams, the loot cart at the far end). Simplifications as Godot (no arcs, no rider on a chest cart, chest cart slots host-only, no power across a gap, the cart RPCs mirror the boat path without a paired probe). `--stage27` (every line of its row, 3531 ore) and `--strike` (18 -> 8 at 2.01 m) unchanged. |
| 29 | **The Underworld, a second dimension.** Eight blocks appended after `powered_rail_ew_on` in Godot order (`obsidian` tier 4, `portal` non-solid translucent light 11 and never an item, `hellstone`, `soul_sand` with the new `BlockDef.speedMult` 0.5, `glowstone` light 15 dropping 2–4 `glowstone_dust`, `nether_quartz_ore` → `quartz`, `nether_brick`, `fortress_core` light 8 → `underworld_heart`), six of them at the end of `generatorIds()`. **Generator** (`lib/src/world/terrain_generator.dart`): `generateIn(cx, cz, dimension)` beside `generate`, `setDimension` picks what `biomeAt` / `structuresNear` answer, dimension 1 is the cavern slab between bedrock at y 0 / 7 / 100 carved by the `_hell` 3D noise with edge bias, lava in every open cell at y ≤ 28, soul sand patches (`_hellPatch`), glowstone clusters from the ceilings and quartz veins by the integer hash, biome 9; the **fortress** (kind 9, `_fortressAt` per 8×8-chunk region, 60%) with the hall, pillars, windows and sconces, two side rooms with a chest each, the 9×9×7 throne room with the sunk lava moat and the core, and `fortressLayout` as a record (`length`, `hallEnd`, `throne`, `core`, `blaze`, `chestA`, `chestB`). **Isolates**: the `gen` job carries the dimension (`ChunkWorkerPool.generate(cx, cz, dimension)` → `generateIn`), and `VoxelWorld` stamps each gen / mesh future with `_genEpoch`, so a result that lands after a travel is dropped. **VoxelWorld**: one `dimension` at a time, `switchDimension` (keeps the live delta under `_editsByDimension`, bumps the epoch, clears in-flight, flow queue and circuits — the TNT callback carried over — and resets), `storeEdit` for a dimension not loaded, `editCountIn(d)`, `blocks.bin` **version 2** (both deltas after the seed; version 1 still loads as dimension 0). **Portal** (`lib/src/game/portals.dart`, static like `rails.dart`; Godot keeps them in `main.gd`): `light` (the hollow in either vertical plane), `buildAt` (frame, hollow, cleared front and a floor), `near`, `findSafeY` (y 30..90 outward from 64, the ring of columns with a bridge, a carved pocket); `Game.tryLightPortal` from the flint and steel (iron + flint), `_portalTick` (2 s in a portal, `_portalHold` until the body steps out; a client sends `travel_req`), `travelToDimension` (wild mobs freed, pets / villagers / drops / boats / carts tagged with their dimension through an `Expando` — Godot's `dim` meta — hidden and not stepped while elsewhere, rides dropped, weather suppressed) and `_arriveTick` (holds the player until the 3×3 ring is generated, then the safe spot and a return frame 2 north when no portal is within 16). **Fortress**: `_checkFortress` (announced within 48 m + *Into the Fire*, two blazes at the hall's middle within 20 m, the Underworld Lord within 14 m of the core, keys lifted by 5000 / 3000), `coreLocked` refuses the core until the lord's death sets the 4000 key (`onUnderworldLordDied` from `Mob._die`), the heart unlocks *Heart of the Underworld* on pick-up; `fortress` loot table (kind 9). **Mobs**: `blaze`, `dark_skeleton` (`wither` effect), `magma_cube`, `underworld_lord` (200 hp boss) with `projectile` / `volley` as data (as in Godot, the ranged AI still picks arrow / frost by body); a `fire` projectile sets the player burning 4 s; soul sand scales a walker's speed under the player's and a mob's feet; the spawner searches an air-over-solid pocket in the underworld and picks from biome 9. **Player**: waits for its chunk like a mob; beds refuse and a water bucket hisses away in the underworld. **Sky**: sun 0, sun disc colour 0, a dark red gradient, a warm constant-diffuse ambient, fog 0.014 red — set in `Game._updateSky` and left the moment the dimension is 0 again; `Weather.suppressed`; `Music` mood **Underworld**; the clock label reads *Underworld*; debug line shows `dim`. **Net**: `block` / `block_req` / `blocks` carry `dim` (an edit for another dimension waits via `storeEdit`, the host stores and relays a client's unchecked), the pose carries `dim` and a `RemotePlayer` in another dimension is hidden, `mobs` carries the host's `dim` (parked mobs are not sent, puppets hidden across dimensions), `travel_req` → the host checks the puppet's feet when they share a dimension → `set_dim`. HUD: Fortress marker and underworld map tint. Probe `--stage29 --kind=9 --slot=probe29` (two boots); windowed `--shot=portal --time=0.745` / `--shot=fortress`, plus a Flutter-only `--shot=cavern`. Unit tests `test/stage29_test.dart`. | ✅ | seen on seed 42, every line Godot's session log: site x0 11 y 66 z0 8; obsidian=true, cobblestone=true (lava_flow=true); 6 portal blocks lit; **travelled to dimension 1 at (19,63,11) on hellstone after 2 s in the portal (Godot the same cell)**; **hellstone 378100 / lava 43743 / glowstone 1604 / quartz 13947 / soul sand 2450 over the 5×5 core — identical to Godot** (the 3D noise ported unchanged; the unit test's raw generator reads hellstone 378101, one less edit); return portal at (19,63,9); **fortress at (34,27): 1557 bricks, 2 chests, 2 blazes, Underworld Lord hp 308 (Godot the same)**, origin y 56, length 45, core (84,56,27); core refused before the kill, heart ×1 after, both achievements; soul sand 2.30 m/s under a 4.6 walk (Godot 2.30); fireball → burning (hp 37/39); back home at (19,66,9) on the surface, weather Clear, clock label back; saved in dimension 1 with edits 436 / 59 (Godot 436 / 59); after the reload dimension 1, edits 436 / 59, the return portal's 6/6 cells intact, label *Underworld*, mood *Underworld*. Captures: `portal.png` (the obsidian frame on the pad at dusk, the hollow lit — only faintly purple: the portal draws on the translucent PBR liquid surface and the low sun washes its colour out; in the underworld it reads purple), `fortress.png` (the throne room from its door: the lord under its boss bar, glowstone sconces and ceiling lights, the orange lava moat along the walls, the purple core), `cavern.png` (hellstone walls, the lava sea below, a glowstone block), and the reload boot's capture (dark red hellstone, the return portal's purple glow). Simplifications as Godot (a client in a dimension the host does not hold sees no mobs and its edits are stored unchecked; the puppet's portal timer is the client's; parked drops and boats frozen; a fireball burns only the player; the probe's blaze fires through `spawnProjectile`; `deep` also fires under y 20 in the underworld; no ghast; no volley AI), plus: puppet mobs are not tagged on a travel (the `mobs` message hides them), and parked villagers stay in `Game.mobs` for aim and projectile tests (hidden, not stepped). `--strike` (18 -> 8 at 2.03 m), `--stage28 --kind=7` (every line of its row, 22 mine rails, 3 carts / 24 rails after the reload) and the `--stage25` pair (host `--reject-one`: drop poses 8, give rest 1, chest 1 / 1, boat aboard, flow 4 / 24, rollback seq 1, flow cells seen 24, bobber, wheat_1) unchanged. |
| 30 | **Title screen, world list, creative mode, tutorial, credits, stats.** The launcher in `main.dart` now shows `TitleScreen` (`lib/src/ui/title_screen.dart`; `main_menu.dart` is gone): Play / Multiplayer / Settings / Credits / Quit over a slowly orbiting vista — a second `VoxelWorld` (radius 3, seed 42) in its own `Scene` + `SceneView` with its own sky and sun, the Meadow mood once SoLoud is up; leaving for a world disposes the vista's isolate pool first. A probe boot (`--new`, `--slot=`, `--seed=`, `--continue`, `--screenshot=`, `--host`, `--join=`) still skips it, `--title-probe` forces it. **Worlds** (`lib/src/game/worlds.dart`): `worlds/<slot>/world.json` (name, seed, mode, class, created — Godot's keys) beside `player.json`; `list()` overlays the save's seed, dimension, play time, class / creative and mtime, newest first; `create` (slug = lower-case `validate_filename` with underscores, `_2`… when taken) / `rename` / `delete` / `start`; `WorldList` (`lib/src/ui/world_list.dart`): the rows, Play (or double-click), Rename, Delete behind an `AlertDialog`, and the New World form (name, seed text — a number as itself, other text FNV-1a hashed, empty random —, Survival / Creative, the four classes). `Worlds.start` fills `GameState` (`worldName` = the slot, seed, class, `creative`, `freshWorld` when no save exists) and the game boots from it as it did from `--slot=`. **Creative** (`GameState.creative`, saved in the stats block): `Player.takeDamage` returns, hunger never drains, every placement path goes through `Player._consumeHeld()` which costs nothing, and F5 flies only when `Game.flyAllowed()` (creative or `--fly`; survival says so). **Tutorial** (`lib/src/game/tutorial.dart`, a `ChangeNotifier` singleton drawn by `TutorialCard` over the HUD): ten steps (move, look, jump, break, inventory, craft a tool, place, eat, sleep or survive to sunrise, journal); `Tutorial.instance.event(id)` is called where the game does the thing (the walk vector, the look delta / `setLook`, `Player._jump`, `onBlockBroken`, `openStation`, `Player.craft` — the inventory click moved there —, `onBlockPlaced`, `_eatHeld`, `sleepInBed` or the 0.25 sunrise crossing, `openJournal`) and only the current step's event advances; Skip is the card's button or F6 (`GameAction.skipTutorial`); `Settings.tutorialDone` persists as `[tutorial] done` in `settings.cfg` (a switch in Settings re-arms it); it begins on a world the title just created (or under `--stage30`), never on a bare `--new`, a client or `--no-tutorial`. **Credits** (`CreditsScreen`): engine, fonts, the procedural audio, the lineage, then every `\| N \| title` row of this file — declared as a plain asset in `pubspec.yaml` and read with `rootBundle.loadString`, no build hook — scrolling up at 42 px/s; Esc closes. **Settings** are one `SettingsPanel` widget used by the pause menu (live) and the title (`game` null). **Stats**: the pause menu's Stats button unfolds play time, metres walked (`GameState.distanceWalked`, the ground displacement per tick), blocks broken / placed, mobs killed, deaths and dimension trips (`GameState.dimensionVisits`, counted in `travelToDimension`); the pause menu also gained Save & back to title in solo. Probe `--stage30 --title-probe` (two sessions, slot `probe30_stats`, removed at the end); `--title-probe` captures with `--open-worlds` / Flutter-only `--open-credits`; `--new --seed=42 --stage30 --shot=tutorial`. Unit tests `test/stage30_test.dart`. | ✅ | `--stage30 --title-probe`, every line green and matching Godot's session log: buttons=5, 'Probe World' seed 4242 created / listed / renamed / deleted (slot `probe30_probe_world`), **33 credits rows (Godot 33)**, creative damage ignored + block placed without consuming + fly, tutorial 7/10 by events (move … place, next eat) then skipped and read back from the file (`settings_probe30.cfg`), the stats saved and equal after the session rebuild (broken 1, placed 2, play 2.1 s → 3.5 s, still creative, no card), `probe30_ slots removed=1`. Seen: `stage30_title.png` (the vista from 16 m over the coast — trees, cliffs, the sea — behind the five buttons), `stage30_worlds.png` (`--open-worlds`: the developer's nine slots with mode, class, seed, dimension, play time and last played, and the New World form), `stage30_credits.png` (`--open-credits`: the engine / fonts / audio / lineage block, then stages 0–18 scrolling), `stage30_tutorial.png` (the gold card "Step 4/10 Break a block" with its skip button over the world), and the rebuilt session's capture of the creative mage world (HP 18/18, the stone still in slot 1). `--strike` (18 → 8 at 2.02 m), a plain `--screenshot` boot (straight into the world, no title) and `--stage29 --kind=9 --slot=probe29` unchanged — every figure of its row except `blazes=3` against the row's 2, a count of every blaze in `mobs` near the hall that this run did not explain (not a stage 30 path). |
| 31 | **Voxel lighting with AO in the shader, light-gated spawns, A* for walkers.** The mesher stops baking the light into the vertex colour: the colour keeps block tint x face tint x AO (the 4-level corner count, the diagonal flipped when anisotropic, mirrored for CCW winding) and `MeshSurface.light` (the second UV set, `texCoords1`) carries `(sky / 15, block / 15)` of the cell the face points into (a plant, a door, a torch stick read their own cell; a flame is full bright). Skylight floods each column from the top and spreads sideways at -1 per step, block light spreads from every emitter (`Blocks.emission()`), both inside the padded 18x18x128 volume of the job, and the two chunk-sized volumes ride `ChunkMeshResult` (with `aoVerts` and the job's own `ms`) back from the isolate so `VoxelWorld.lightAt(cell)` answers `(sky, block)`. **Shader**: `TerrainMaterial` (`lib/src/world/terrain_material.dart`) is a `PhysicallyBasedMaterial` whose fragment shader is `shaders/terrain.frag` — flutter_scene's standard lit shader with Godot's `terrain_light` folded into the albedo (`level = max(sky * sky_intensity, block)`, `0.02 + 0.98 * level^4`) and `emission_mix` 0.5 of the lit albedo added as emission — plus a cube-radiance twin, compiled by `dart tool/build_shaders.dart` (SDK impellerc) into the committed asset `assets/shaders/terrain.shaderbundle`; the only extra input is a `TerrainInfo` uniform block bound in `bind`. Solid, cutout and liquid use it (specular 0 on solid / cutout: Godot's `specular_disabled` and no sky reflection); the stage 27 glow surface stays `UnlitMaterial`. `Game._updateSky` sets `skyIntensity` (1.0 noon, 0.35 night, 0.0 underworld, storms dim it) through `VoxelWorld.setSkyIntensity`, and the sun drops from Godot's 0.85 to 0.6. The title vista loads the library too. A placed or removed block that is opaque or emits remeshes the whole 3x3 ring (`VoxelWorld.setBlock`). **Spawns**: `Spawner.hostileAllowedAt(cell)` is `block + sky * Game.dayFactor < 7` (`lightAllowsHostile`, pure); `Species.candidates(biome, night, cave, dark, rng)` drops the height, and the bat's `maxY` is gone. **Pathfinding** (`Pathfinder`, `lib/src/game/pathfinder.dart`): A* on feet cells, 4 horizontal moves, a step up with head room, a drop of up to 3 onto a landing, lava never, water x3, soul sand x2, Manhattan heuristic, 600 expansions then the best partial path, a binary heap on f then deeper g; `Mob._steer` follows the waypoints for a chasing or homing walker (replan every 0.6 s or when the next waypoint got blocked, three partial paths in a row fall back to the straight chase for 3 s); fliers and puppets untouched. Probe `--stage31` (`--no-light` for the cost comparison, `--shot=room|cave` for the captures). Unit tests `test/stage31_test.dart`. | ✅ | seen on seed 42, every probe line Godot's: site chunk (1, 0), walk floor y 67; **outside sky 15 / block 0, room centre sky 1 / block 10, under the overhang sky 7 (Godot the same)**; torch removed -> block 0 after **9 chunks remeshed**; **4107 AO vertices** in the room chunk; spawn gate dark=true / lit=false (day factor 0.35 at night, 1.00 by day); **the zombie reaches the player through the S maze in 9.7 s along a 28-cell path (straight line 10), 17 replans; the no-path control stays stuck (closest 7.2 m in 6 s)** — all Godot's figures; A* on that maze 0.4–1.6 ms; mesh time **6.5 / 7.4 / 7.7 ms per chunk lit** over 341–353 jobs against **6.2 ms with `--no-light`** (Godot 7.5–13.8 lit, 5.5–17.3 unlit on a busier pool). Plain boot seed 42: window 361 chunks / 649942 faces in 1.65–1.70 s at 86–87 fps against 1.58–2.40 s at 94–102 fps for the stage 30 build on this machine (the terrain shader is the standard one plus a few ops; the spread between runs is about as large). Captures: `stage31_room.png` (night, the torch wall bright around the torch, the far corners and edges dark, every face flat-lit from its cell), `stage31_cave.png` (the pit's mouth bright by day fading to grey at the back), the plain day boot (the same coast as stage 30, lighter and a little paler: the emission share adds to the lit albedo), the plain night boot (darker than stage 30: the field near black away from the moonlit sky), the title vista (trees, grass, water, readable), `--stage29` (underworld: hellstone dark, the portal's purple glow and glowstone lit), `--stage27 --time=0.05` (the lamp throws a pool of block light on the dark pad). Regression: `--stage29 --kind=9 --slot=probe29` (hellstone 378100, fortress 1557 bricks / lord 308, edits 436 / 59 after the reload), `--stage27 --slot=probe27` (3531 ore, reload lamp + wire on), `--strike` (18 -> 8 at 2.01 m) and `--title-probe` (81 vista chunks, 5 buttons) unchanged. Engine differences: Godot's `ShaderMaterial` + `EMISSION`/`ALBEDO` keeps the engine's lighting; flutter_scene's raw `ShaderMaterial` binds no sun, shadow, ambient or fog, so the terrain shader is the standard PBR fragment shader with the light term folded in and the material subclasses `PhysicallyBasedMaterial` (sun, cascaded shadows, ambient and sky fog all kept); it keeps every sampler of the standard shader because the material binds them by name. The bundle is built by hand (no app hook) with `--gles-language-version=300`, is tied to the engine and holds every backend (1.7 MB). Under ACES the 0.35 night with the fourth power reads darker than Godot's filmic tonemapper made it; the numbers are Godot's. Simplifications as Godot (~~the light BFS inside the one-cell pad, so a torch across a chunk border does not light the neighbour~~ → stage 32, the pad is the whole 3x3 ring; the fourth-power curve; `--no-light` still pays the AO pass). Fixed on the way: a remesh requested while that chunk's job was already in flight was dropped when the stale result landed (`VoxelWorld._remeshAgain`), which let a probe read pre-edit light. |
| 32 | **Polish: seam-free light, combat feel, breaking feel, mob life, HUD.** **Light** — `ChunkMesher.pad` = 16: the padded volume is the whole 3x3 ring (48x48x128, filled chunk by chunk by `_copyChunk`), so the skylight and block BFS see every emitter up to 15 cells past a border; the four buffers are static (one set per worker isolate, Godot's `[ThreadStatic]`, the queue sized 2x the volume); the sky BFS is seeded only from cells with a darker side neighbour (`ChunkMesher.fullSkySeed` keeps stage 31's rule for the equivalence test); Flutter-only and result-identical, the layers above the volume's highest block are filled with 15 at once so neither the column pass nor the seeding scan walks them. **Combat** — every hit adds `Mob.knockbackVelocity` (4 m/s away on the ground plane, a projectile's or explosion's larger push wins, + 3 m/s up) and a 0.3 s stagger the steering lerp does not brake (`Mob._moveAndAnimate`, `Player` on foot and flying; a puppet rides the host's pose), a 60 ms hit-stop on the victim's model (`Mob._freeze`, `PlayerModel.freeze`: the pose holds, the body and the clock keep going), a 100 ms white flash through one shared `UnlitMaterial` (`PlayerModel.flashMaterial`, `vertexColorWeight` 0), a hurt voice per group (`Mob.hurtGroup`: small / large / undead / flying), the player's camera shake (0.15 s, damage / 10 capped at 0.3 m, added to the camera only, never the aim) and the HUD's radial red vignette (1 -> 0 over 0.4 s); damage numbers read `-N`, rise 1 m over 0.8 s and fade from 0.2 s to 1 s; one melee hit or arrow in ten is a critical (`Game.rollCrit`, `critChance` 0.1, x`critMult` 1.5 rounded, yellow `-N!`; the `dmg` message carries `crit`); the held item pivots 60 degrees over 120 ms on every swing and every 0.35 s mining tick (`PlayerModel.hand`). **Breaking** — four crack stages (`Player._buildCrackStages`: a box darkening 0.16 a stage plus two jagged four-segment polylines per face per stage from `Random(32)`, one `LineSegmentsGeometry` node per stage and face built once, a face turned away from the camera hidden), `Game.spawnDebris(at, colour, count, speed)` with one shared unit cube (12 on a break, 2 per mining tick at 0.7, 8 white at 0.5 for a spawn poof, 1 ember for a burning mob), and `Blocks.materialFamily` (metal / glass / stone / plant / wood / earth by id substring in that order, liquid by shape, stone otherwise) picks the `break_` / `place_` / `step_` voice (21 new SoLoud voices, plus `hurt_*` x4 and `heartbeat`); footsteps every 0.45 m (0.3 m sprinting), softer on sand and soul sand (`Player.stepsTaken`). **Mobs** — breathing (2% on the height, not blobs or creepers), a passive mob's head turns to the player within 6 m (clamped to 1.2 rad), `Spawner` spawns in a poof, death = topple 90 degrees over 0.4 s, fade over 0.3 s, removed (drops at t = 0), and the classic rule (`Mob.burnsInDaylight`: zombie / skeleton / dark_skeleton whose head cell reads sky 15 while `dayFactor >= 0.9`, not in water, not tamed; checked every 0.5 s, 0.5 HP each, orange tint, an ember). **HUD** — `HudState` (`lib/src/ui/hud_state.dart`, advanced by `Game.onFrame`, Godot's `hud._process`): the selected hotbar slot tweens to 1.1 over 80 ms, pickups are toasts bottom-right that merge a repeat within 1 s (`Player.pickUp` calls `hud.addPickup` instead of a note), under 25% HP the vignette pulses and a heartbeat plays every 0.9 s, the XP fill tweens, the boss bar carries a portrait block in the species colour and shakes 0.25 s on a hit. Probe `--stage32` (`--shot=combat|mining` as Godot, Flutter-only `--shot=seam`). Unit tests `test/stage32_test.dart`. | ✅ | seen on seed 42, every probe line Godot's: site chunk (1, 0), border at x 16; **a torch 5 steps from the west chunk lights its first cell to 8 and the third to 6 (Godot 8 / 6), the same 5 steps inside the torch's chunk 8**, the west chunk remeshed with the ring of 9; **the zombie moved 1.62 m and rose (Godot 1.62)**, flash + hit-stop on, the player's hit shook the camera with **vignette 0.90 (Godot 0.90)** and a model flash; crits 17 / 16 / 23 / 31 / 25 / 15 over 200 swings across six runs (Godot 24-25), 200 numbers; **crack alpha 0.48 at progress 0.5 (Godot 0.48)**, stage 2 with 9 face nodes shown, 12 cubes and the stone voice on the break; **12 steps over 5.3 m (Godot 12 over 5.3)**; **sun zombie burning, roofed one (head sky 13) and pooled one (in water) not (Godot the same)**, day factor 1.00; the kill freed the body after 0.72 s (43 ticks; Godot 0.70 wall time) with the drops at t = 0; `+3 Apple` twice -> `+6 Apple`, low HP pulsing. **Mesh time**: the in-app job clock (24 jobs in flight on the isolate pool) read 8.6-10.2 ms per chunk over 315-327 jobs in nine `--stage32` runs and 9.9 / 11.0 ms in two `--stage31` runs of this build, against stage 31's 6.5-7.7 ms; single-threaded on the same 49 seed-42 chunks (no pool contention) the stage 31 mesher takes 3.0-3.2 ms and this one 4.5-4.75 ms (5.0 before the empty-layer shortcut), so the 3x3 pad costs about 1.5 ms per chunk here where Godot's C# measured it as about the same. **Window fill** (plain boot seed 42, 361 chunks / 649942 faces): 1.91 / 2.12 / 2.36 s at 76-82 fps against stage 31's 1.65-1.70 s at 86-87 fps (these runs shared the machine with another session's headless Godot test run at ~97% CPU). Captures: `stage32_combat.png` (the player and the zombie both white mid-flash, the zombie shoved back with its health bar over it, `-1` yellow on it and `-3` red on the player, the red vignette, a `+6 Apple` toast), `stage32_mining.png` (first person, a raised stone block darkened with cracks on its top and front faces, a chip in the air, the progress ring), Flutter-only `stage32_seam.png` (`--shot=seam`: the torch back at midnight seen from 7 m above the border, its diamond of light fading a step a cell straight across the border column into the west chunk with no cut; the probe's row along the torch reads 3 4 5 6 7 8 | 9 10 11 12 13 12 11 ... across the border at x 16). Regression: `--stage31` (sky 1 / block 10 at the room centre, sky 7 under the overhang, 9 remeshed, 4107 AO, the maze in 9.7 s along 28 cells, the control stuck at 7.2 m), `--stage29 --kind=9 --slot=probe29` (hellstone 378100, fortress 1557 bricks / lord 308, soul sand 2.30, edits 436 / 59 after the reload), `--strike` (10 damage at 2.01 m: 17.5 -> 7.5, the zombie now burning in the morning sun before the swing, where stage 31 read 18 -> 8) and `--title-probe` (81 vista chunks, 5 buttons) unchanged; the `--stage21b` pair was not run. Engine differences: a material swap in flutter_scene 0.23 only reaches the renderer when the mesh is re-assigned (`refreshMeshMaterials`, used by the flash, the burn tint and the death fade); the crack lines draw over the terrain, so faces turned away are hidden per node where Godot's depth test hides them; the vignette is a canvas radial gradient stretched to the screen like Godot's `GradientTexture2D`, over Flutter's existing full-screen damage flash, so a hit reads redder than Godot's capture; Godot's crit label sets `font_size` 80 then 64, so a crit number is the same size here too; the death topple is linear (Godot's `EASE_IN` on a linear transition); the probe counts ticks, `Mob.probeDrops` stands in for Godot's duplicated species dictionary, the combat capture waits one tick (the flash is 100 ms and the capture lands a few frames later) and the mining hold ends at progress 0.6 rather than after 40 frames, so the block is still standing when captured. Simplifications as Godot: no first-person hand (the flash shows on the third-person model only), the crack overlay is line-drawn, the bursts are pooled cube nodes rather than particles (counted by the probe), the crit rides the damage-number message, the hit-stop is per model and never the clock. Fixed on the way: `HudPainter` projected mob bars and damage numbers with the camera captured when the widget was built, so they drew at the player's first position (now the camera of the frame); `Mob._setTint` (stage 23 stun) never reached the screen after spawn for the same material reason; `VoxelWorld._refreshWindow` dropped every queued remesh when the window re-centred, which left an edited chunk with its pre-edit mesh and light (the stage 31 probe passed only when a dispatch frame ran before that tick, and failed once here with sky 15 in the roofed room); `GameInput.probeHold` crashed on the mouse-button actions. |

## Session log

- **2026-09-15** — four requests from a hand play. (1) **Night**: the terrain shader's curve is now Minecraft's light
  map (`l / (4 - 3l)`, sky factor 0.24 night .. 1.0 noon mapped from the game's 0.35 .. 1.0 `skyIntensity`,
  gamma 0.5, `x 0.96 + 0.03`, raised to 2.2 for the linear albedo) instead of Godot's `0.02 + 0.98 * level^4`,
  and `_updateSky` raises the moon (0.18 -> 0.45) and the night ambient (energy 0.10 -> 0.90 at night, 0.40 by
  day as before) so the engine's lighting stops darkening the night a second time. `skyIntensity` itself is
  unchanged, so the spawn gate and the daylight burn read the same numbers. Plain boot seed 42, mean luma of the
  lower screen band: noon 142.8, midnight 34.6 before -> 40.4 (curve + moon) -> **47.9** (0.34 of noon); the
  Minecraft map gives about 0.46 for a moonlit field at default brightness, ACES keeps the rest. (2) **Step
  teleport** behind `Settings.stepTeleport` (`[gameplay] step_teleport`, switch in the panel, `--step-teleport`),
  off: `VoxelBody.tryStepUp(fullBlock: false)` still lifts the half step, and a full block the body fits over
  (`VoxelBody.stepFits(1.02)`) is jumped instead. (3) **Wall climbing** behind `Settings.climbWalls`
  (`climb_walls`, `--climb`), off; the tutorial and the menu line stop mentioning it. It also stalled under the
  top (Godot's `wall_ahead` has the same bug): the lowest probe was 0.3 above the feet, lost the wall with the
  feet still below its top, gravity pulled the climber back and it climbed again. The probe now reads the feet
  cell. (4) **Underwater**: `Game._updateSubmerged` reads the camera's eye cell (a pool's top cell counts only
  under its 0.875 surface) and turns the fog deep blue at density 0.05 with no sky influence (lava: orange,
  1.2), and the HUD washes the screen blue (orange in lava). `--move-probe` on seed 42: teleport off, the step
  is climbed with a largest one-tick rise of 0.265 m (a jump) to y 59.001; on, 1.020 in one tick to the same
  top; climbing off, a jump to 59.495 against the 3-high wall; on, feet 61.001 on the wall top, on floor. Unit
  tests in `voxel_core/test/physics/physics_test.dart` (the climber stands on a 3-high wall, the step is jumped,
  a 2-high wall is not). `--underwater` frames the sea floor through the blue; `--stage22` unchanged (slab 67.5,
  stairs 68, fence blocked); `--stage31 --shot=room --time=0.0` still reads the torch room.

- **2026-09-14** — deterministic loot seeds. Stage 26 noted that a structure chest seeded its loot from
  `IVec3.hashCode ^ seed`. Dart's `hashCode` / `Object.hash` are seeded per process, so the same chest held
  different items after a restart, and a host and its client could roll it differently. `LootTables.seedFor(at,
  worldSeed)` is now the one explicit integer hash, `(x*73856093 ^ y*19349663 ^ z*83492791 ^ seed) & 0x7FFFFFFF`.
  The chest roll, the mine chest-minecart cargo (the private `_cellHash`) and `Mob.traderSeed` all seed through it.
  For a world seed below 2^31 the cart and trader seeds are bit-for-bit what they were, so only chests change.
  A grep for `hashCode` / `Object.hash` in `lib/` finds nothing else seeding a roll: `IVec3.hashCode` remains only a
  map key. `loot_seed_test.dart` pins the seed (1205562705 for (12, 40, -7) in world 42) and the first draw, and checks
  that two separate `Random` constructions roll every table identically.

- **2026-09-14** — probe determinism. Two probes drifted from their rows because of what stage 32 added around them.
  - **`--stage29` counted a third blaze now and then.** The count takes every blaze in `mobs`, as Godot's does
    (`main.gd` `_probe_stage29`). The fortress spawns exactly two, but the underworld spawner could add one more during
    the probe's teleport waits. Nulling `spawner`, the port's usual stand-in for Godot's `set_process(false)`, would
    have silenced the fortress too, because `_checkFortress` spawns its blazes through `forceSpawn`. So `Game` gained
    `spawnerPaused`: natural spawns stop and `forceSpawn` keeps working. The probe pauses from the trip down to the
    trip home. Two runs read `blazes=2`, and every other figure of the row came back (1557 bricks, the lord at 308 HP,
    soul sand 2.30, edits 436 / 59). Godot's probe has the same latent flake; it was not touched.
  - **`--strike` read 17.5 -> 7.5, and once 17.5 -> 2.5.** Since stage 32 a zombie under the morning sun burns
    0.5 HP per half second before the swing, and one melee hit in ten is a x1.5 critical. The probe now runs at night
    unless `--time=` is given, and sets `critsEnabled = false`. It reads 18 -> 8 at 2.01 m, as its row does. Godot's
    `--strike` is the same code, so it carries both latent flakes.

- **2026-09-14** — the render was mirrored left-right against Godot since the first port commit. flutter_scene's
  `PerspectiveCamera` builds `right = up x forward` and projects +forward into the screen, a left-handed view; the port
  fed it Godot's right-handed world unchanged, so world +X landed on screen-LEFT at yaw 0. `--stage22` and `--stage27`
  prove it: the same camera pose as Godot put +X on the opposite side. The port had compensated piece by piece instead
  of fixing it: a mirrored `rightVec`, `yaw += look.dx` against Godot's `_yaw -= relative.x`, quads wound the other
  way in both mesh builders, and the boat steering and roll signs flipped.
  - **One conversion, at the camera.** `GodotCamera` (`lib/src/world/godot_camera.dart`) is a `PerspectiveCamera`
    whose lens negates clip-space x, used by the player and the title vista. The world, the lights, raycasts and
    `worldToScreen` stay in Godot's coordinates. Everything compensated went back to Godot's form: `rightVec =
    (cos, 0, -sin)`, the mouse sign, the mesher's and `VoxelMeshBuilder`'s winding (Godot's `Quad` index for index),
    the boat's `steer * -1.7` and `-steer` roll, and the boat dismount offset.
  - **What the mirror costs.** Screen winding reverses. The engine's own `CuboidGeometry` and `SphereGeometry` (the
    crack box, debris, effects, TNT, bobber, fireball trail) sit in a child scaled (-1, 1, 1): they are symmetric,
    and flutter_scene re-winds a mirrored transform. The shadow pass is not mirrored, so the caster-faces default is
    now `front`, which draws the same real back faces `back` drew before. The engine-derived `cameraRight` used by
    SSAO, SSR, GI and contact shadows would disagree with the view, but the game enables none of them.
  - **A second convention bug of the same family.** flutter_scene's `lookAtFrom` turns local +Z toward the target,
    while Godot's `look_at` turns -Z. Arrows and bolt trails flew backwards; the projectile now aims at the point
    behind.
  - Verified: `handedness_test.dart` (+X at yaw 0 projects to NDC x > 0, while the plain camera gives < 0; strafe
    and forward are Godot's; a mouse move to the right turns right; stairs ids from yaw match Godot's `facing_suffix`),
    and the stage 31 winding test now expects clockwise. Captures: `--stage22` looking south shows the slab (west)
    right and the fence post and lava (east) left; `--stage27` looking north puts the lever end x0 of every row on the
    left; `--stage19` reads oak slab, stone slab, fences, stairs from left to right; the plain boot shows the ocean to
    the west on the left, and the `--map` minimap has the same ocean to the north-west, north up. `--stage31` (sky
    1 / block 10, sky 7, 4107 AO vertices, 28 cells in 9.7 s, 7.2 m), `--stage32` (seam 8/6, 1.62 m, vignette 0.90,
    crack alpha 0.48, 12 steps, 0.72 s, `+6 Apple`, damage numbers on the zombie) and `--title-probe` (81 vista
    chunks, 5 buttons) are unchanged. No face is inside out, and the shadows fall as before.

- **2026-09-14** — stage 32, the port of `82ff6b52e9`. Every `--stage32` line printed Godot's figures: the seam cell
  at 8 and the third at 6, the zombie shoved 1.62 m, vignette 0.90, crack alpha 0.48, 12 steps over 5.3 m, the sun /
  roof / pool zombies, the death clock and the merged `+6 Apple`. `--stage31`, `--stage29`, `--strike` and the title
  vista were unchanged. Engine differences:
  - **The pad buffers are isolate statics.** C#'s `[ThreadStatic]` becomes static fields of `ChunkMesher`: Dart statics
    live per isolate, so each worker binds one 48x48x128 set and reuses it for every job.
  - **The pad costs more here than in C#.** Single-threaded on the same 49 chunks the mesher went from 3.1 to 5.0 ms.
    Filling every layer above the volume's highest block with 15 at once (the result is identical, the equivalence
    test proves it) brought it to 4.6 ms. In the app the job clock reads 9-10 ms under the pool's contention (stage
    31: 6.5-7.7), and the window fills in 1.9-2.4 s (stage 31: 1.7 s).
  - **Swapping a material needs a mesh re-assign.** flutter_scene 0.23 copies each primitive's material into its render
    item when the mesh is attached. Writing `primitive.material` changed nothing on screen until
    `refreshMeshMaterials` re-assigned the same primitives. The stage 23 stun tint had the same silent bug.
  - **The crack lines ignore depth.** `LineSegmentsGeometry` draws over the terrain, so there is one node per stage and
    per face, and a face turned away from the camera is hidden.
  - **The HUD state is a class.** Godot's `hud.gd` `_process` becomes `HudState`, advanced once per frame by `Game`;
    the painter stays stateless.
  - Probe details: the waits count ticks (the death clock reads 0.72 s, 43 ticks), `Mob.probeDrops` replaces the
    duplicated species dictionary, `probeHold` now holds the mouse buttons, and a Flutter-only `--shot=seam` shows the
    torch across the border at night.

  Probe lessons: the first combat captures showed no damage numbers and no mob bars. `HudPainter` held the camera from
  the widget's build, so every projection used the player's spawn position; it now asks for this frame's camera. The
  flash was invisible twice over: `UnlitMaterial` multiplies the vertex colours by default, and the material swap never
  reached the render item. A `--stage31` regression read sky 15 in the roofed room. The probe moves the player into
  the next chunk right after its edits, and `_refreshWindow` cleared the queued remeshes; stage 31 had passed by
  timing. The fix keeps them queued. Also, a window that opens behind other windows gets no frames on macOS, so the
  probe runs bring the app to the front through System Events.

- **2026-09-14** — stage 31, the port of `455d8746de`. Every `--stage31` line printed Godot's figures (sky 1 / block 10 at
  the room centre, sky 7 under the overhang, 9 chunks remeshed, 4107 AO vertices, the maze in 9.7 s along 28 cells, the
  control stuck at 7.2 m), and `--stage29`, `--stage27`, `--strike` and the title vista were unchanged. Engine differences:
  - **The terrain shader is flutter_scene's standard lit shader with one term added.** A raw `ShaderMaterial` gets no
    sun, shadows, ambient or fog, so copying Godot's shader into one would have lost the whole look. `TerrainMaterial`
    subclasses `PhysicallyBasedMaterial`, swaps in `shaders/terrain.frag` (the standard shader, albedo x light, plus an
    emission share) and binds one extra `TerrainInfo` block. The shader keeps every texture read of the original: the
    material binds samplers by name, and one the compiler strips would crash the draw.
  - **The bundle is compiled by hand.** There is no app-level build hook, so `dart tool/build_shaders.dart` runs the SDK's
    impellerc (`darwin-x64`, an arm64 binary here) into `assets/shaders/`. Without `--gles-language-version=300` impellerc
    aborts inside spirv_cross. The material's `bind` signature is typed against flutter_scene's internal gpu shim, so
    `package:flutter_gpu` cannot be imported directly (the analyzer resolves the shim to a stub type).
  - **The light volumes cross the isolate boundary** as two more `TransferableTypedData`, beside a fifth array per surface.
  - **Night looks darker than Godot's** under ACES with Godot's 0.35 and fourth power; the numbers stay Godot's.
  - Probe lesson: the first light read once came back as the pre-room mesh. A chunk edited while its mesh job was in flight
    lost the new request when the stale result landed, so it is now kept pending (`_remeshAgain`).

- **2026-09-14** — stage 30, the port of `1ffac7c81c`. Both halves of `--stage30 --title-probe` printed Godot's
  lines: the title's five buttons, the world round trip, 33 credits rows, creative, the tutorial's seven events, and
  the stats read back after the session rebuild. Engine differences:
  - **The vista is a second `Scene` + `SceneView`.** Godot puts a `VoxelWorld`, a `WorldEnvironment` and a
    `Camera3D` under the title's `Control`. Here the title owns its own `Scene` (gradient sky, sun, ACES, fog) and a
    `VoxelWorld` with its own isolate pool. `_leave()` disposes that pool before the launcher builds the game, so
    two worlds never generate at once. The music waits for `Sfx.ready`, because the title can be up before SoLoud.
  - **Scene changes are widget swaps.** `change_scene_to_file` becomes `_Launcher` swapping `TitleScreen` and
    `GameView`, each under a fresh key. "Save & back to title" is `Game.exitToTitle`, and a title shown again does
    not re-run the probe flags.
  - **The credits read the roadmap as an asset.** An app-level build hook is not allowed, so `ROADMAP.md` is listed
    under `flutter: assets:` and read with `rootBundle.loadString`; the unit test parses the file on disk. The
    bundled copy is only as new as the last build.
  - **The tutorial card is a widget.** Godot's autoload owns a `CanvasLayer`. Here `Tutorial` is a
    `ChangeNotifier`, and `TutorialCard` sits inside the game view's `RepaintBoundary` over the HUD, so a capture
    sees it. F6 is a new `GameAction.skipTutorial`.
  - **The typed seed.** Godot hashes text with `hash()`. Dart's `hashCode` is seeded per process (gotcha 7), so
    text goes through FNV-1a: stable, but not Godot's number. Numbers and the empty (random) seed behave as Godot's.
  - **Counters reset on start.** Godot's `GameState` autoload keeps the last world's counters until a load replaces
    them, so a fresh world made after playing another inherits its stats. `Worlds.start` (and Join) call
    `GameState.resetStats()` first. This is a deliberate difference, not an engine one.
  - **The probe's settings file.** Godot's probe writes `tutorial/done` into the real `settings.cfg`. `main.dart`
    loads the real file, then points a `--stage30` run at `settings_probe30.cfg`.
  - Flutter-only capture flags: `--open-credits` and `--credits-t=` (seconds into the scroll).

  Probe lesson: the first run parsed 32 credits rows, not 33. The binary had been built before this row was
  added, and the asset bundle is a build product. The rerun after a rebuild read 33. The unit test counts the
  table rows of the file itself, so it follows every future row. Second lesson: the regression capture of a plain
  `--screenshot --new` boot showed the tutorial card on step 1. Flutter's launcher marks a bare `--new` as
  `freshWorld` (Godot's title never did), so "a fresh world" had to exclude `--new` explicitly; the recapture
  shows no card, and `--stage30` still begins it.

- **2026-09-14** — stage 29, the port of `3d46f2f410`. The generator's underworld and the fortress went across
  line for line, and every `--stage29` figure landed on Godot's session log. The census over the 5×5 core
  (hellstone 378100, lava 43743, glowstone 1604, quartz 13947, soul sand 2450) is identical, so
  `flutter_scene`'s FastNoiseLite 3D noise matches Godot's for this recipe too. The fortress (1557 bricks), the
  arrival cell, soul sand 2.30 and the saved edit counts 436 / 59 match as well. Engine differences:
  - **The job carries the dimension, the future carries the epoch.** Godot binds `(pos, dimension, epoch)` into
    a `WorkerThreadPool` task and filters `_gen_out` by epoch. Here the isolate's `gen` message gets a fourth
    field, and each `then` closure captures `_genEpoch` at dispatch and returns when it changed. A stale mesh or
    gen result therefore never touches `chunks` or the in-flight sets of the new dimension.
  - **`dim` meta → `Expando`.** Entities are plain objects in `Game`'s lists, so the dimension tag is an
    `Expando<int>` (untagged = the loaded dimension). "Hidden + `PROCESS_MODE_DISABLED`" is `node.visible` plus an
    `isHere` check in the `_tick` loops, the save and the mob broadcast.
  - **Portal logic moved to `portals.dart`** so the unit tests reach the frame check, the return frame and the
    safe spot without a scene. `Game.tryLightPortal` / `_arriveTick` call it where Godot's `Main` does.
  - **Sky.** The underworld branch sets `SunLight.intensity` and the sky's sun colour to 0, the gradient's three
    colours, a constant-diffuse ambient and red fog. The day branch rewrites all of them every frame, so the way
    back needs no restore.
  - **Probe timing.** The flow waits and the soul-sand walk count 60 Hz ticks (`_stage28Settle` /
    `_stage28Until`). Standing in the portal re-pins the player from the per-tick hook until `travels` moves.
    The arrival and chunk waits are wall-clock frames, as in Godot.
  - **IVec3** gained `* int` and `length` (Godot's `Vector3i` ops that `try_light_portal` uses).
  - Test fixes: `stage28_test` asserted `Blocks.count` after the rails (now "the next id is `obsidian`"), and
    `world_test` counts 29 species.

  Probe lessons: the first `--shot=portal` capture showed the trees the pad had cleared, not the frame. The
  capture waited 30 frames, and the pad's remeshes had not all landed; both shots now wait for `world.isIdle`
  too. Also, Godot's windowed captures do not show the lava sea, so a Flutter-only `--shot=cavern` hovers over
  the nearest open column above it.

- **2026-09-14** — stage 28, the port of `3a180ea741`. `rails.gd` and `minecart.gd` went across nearly line
  for line, and every `--stage28` figure landed on Godot's session log: the orientation counts, 3.93 / 3.07 on
  the slope, 5.23 off the powered leg, and the same seed 42 mine with 22 rails. The mine count comes from the
  generator's integer hash, so it matches exactly. Engine differences:
  - **The cart is not a scene node.** Godot's `Minecart extends Node3D` and joins the `carts` group. Here it is
    a plain class that owns a `Node`, listed in `Game.carts`, stepped in `_tick` after the boats and pruned
    like them. `setupCart` takes `model: false` so the unit tests step real carts without a GPU.
  - **Probe timing.** Godot waits with `_stage22_settle` (wall time) and `_stage28_until` (physics frames against
    the wall clock). Here both count 60 Hz simulation ticks (`_stage28Settle`, `_stage28Until`, gotcha 7).
    That is why the slope and the powered peak match to the hundredth. The rider's 0.86 m against Godot's
    0.89 is the one figure a frame early or late would move.
  - **The wire.** The five cart RPCs are JSON message types (`cart`, `cart_poses`, `cart_free`, `cart_req`,
    `cart_board_req`, `cart_unboard_req`, `break_cart_req`). A cart gets a counter net id like the boats, and a
    replica is built from the spawn message's cell and kind. As in Godot, no paired probe exercises them.
  - **The loot seed.** Godot seeds the mine cart's roll with `hash(ckey) ^ seed`. Dart's `hashCode` is seeded
    per process (gotcha 8), so `Game._cellHash` is an explicit integer hash. The roll is deterministic, but its
    stacks are not Godot's.
  - **F on a cart** is reached through a new `Player.probeInteract()`, where Godot's probe calls the private
    `_interact_pressed`. The rails need no raycast change: `voxelRaycast` already stops on any non-air,
    non-liquid block.
  - Test fix: `stage27_test` asserted `Blocks.count == melon + 22`. That becomes "`rail_ns` is melon + 22".

  Probe lesson: macOS has no `timeout` binary. The first run printed nothing because `timeout: command not
  found` went through the same grep as the probe lines. The app is now run bare, with its log written to a file.

- **2026-09-14** — stage 27, the port of `734b8cea2f`. `circuits.gd` went across nearly line for line
  as `lib/src/game/circuits.dart`, and every probe line matched Godot's session log. The ore count
  (3531 below y 30 in 49 chunks) matched exactly, because the veins come from the generator's integer
  hash. Engine differences:
  - **Host gate.** Godot asks `Net.is_client()` in `set_block` and `_process`. Here `VoxelWorld.flowEnabled`
    (false on a client) gates both `circuits.touch` and `circuits.tick`, so the circuits and the flow
    share one switch. The tick runs inside the stage 25 `beginBlockBatch` / `endBlockBatch`, after
    `tickFlow`.
  - **Signal -> callback.** `tnt_powered` is `Circuits.onTntPowered`, set to `igniteTnt` in `Game.init`.
    TNT is set to air inside the recompute's `_applying` window, so the ignition never re-dirties
    the cell.
  - **Glow surface.** Godot's unshaded `StandardMaterial3D` with vertex albedo is a flutter_scene
    `UnlitMaterial` (`vertexColorWeight` 1). `ChunkMeshResult` carries a fourth surface, the isolate
    reply packs 16 arrays, and the chunk node gets a fourth child. As in Godot, the vertex colour
    still holds the baked light, and the old `lamp` (15) and `waypoint` (10) move to that surface
    too.
  - **Probe timing.** Godot's `_stage22_settle(0.3)` is wall time. Here every wait is 18 simulation
    ticks, and the button is timed as ticks × 1/60 through `_probeTick` (gotcha 7). That gives
    0.02 / 1.00, Godot's numbers.
  - **Two boots.** `reloader` rebuilds the session like stage 24. The flag `probe27.flag` holds
    `x0,y,z0` as plain text and is read and deleted at init (Godot writes JSON and deletes it in the
    verify half). `_loadGame` honours it like the stage 24 flag.
  - **Capture.** A first-person hover pinned 6.5 m over the pad and 12 m south of the rows, looking
    at the middle rows. Godot's third-person camera would put the player model in the frame, and
    Godot's framing was too far to tell a lit wire from a dark one. Night alone shows the lamp; the
    day capture shows the rest.
  - **Plates.** `_platesFired` is now the set pressed on the last tick (the click and the "floor rumbles"
    note fire on a new press). `platesFired()` still reports 1 in `--stage23`. `Player._toggleDoor` became
    `toggleDoor` so the probe can use it.
  - Test fix: `stage26_test` asserted `Blocks.count == plate + 7`. That becomes "`redstone_ore` is
    plate + 7", since stage 27 appends after the melon.
  - Seen and not investigated: in the captures, the lever end of each row (the lowest x) sits on the
    right of a frame that looks north. The camera's handedness predates this stage.

- **2026-09-14** — stage 26, the port of `f931355a2e`. The generator diff went across line for
  line, and every block count on seed 42 landed on Godot's number. The biome map, the pools
  and the village layout all come from hash and noise, so they match exactly. Engine
  differences:
  - **Music.** Godot fills two `AudioStreamGenerator` voices, at most 4096 frames each per
    `_process`. SoLoud has no pull generator on desktop here, so `Music.render` runs the same
    pentatonic random walk for 32 eighth notes. That buffer loads as a looping WAV
    (`Sfx.wav16`), and a mood change crossfades the two handles with `fadeVolume` +
    `scheduleStop` over 3 s. The walk is seeded by an FNV hash of the mood name, so a mood
    repeats as a loop instead of wandering forever. Volume is the global SoLoud volume the
    stage 24 settings already set, not a per-voice `× Settings.volume`. The probe cannot
    hear. It reports the moods it picked, the samples rendered, the loops started
    (`handlesPlayed`) and whether the active handle is a live SoLoud voice. When four moods
    change inside one frame, a loop still loading is skipped for the newer mood (3 or 4
    loops started).
  - **Split and trader timing.** A slime dies inside loops over `Game.mobs` (projectiles,
    abilities), so its two children wait in `Game.pendingSplits` until the end of the tick.
    Godot adds them at once, so the probe counts after one tick. `setupMob` runs before the
    position is known here, so traders get their offers from `Mob.makeTrader(bornAt)`.
  - **Deterministic offers.** The first probe runs showed different offers for the same
    villager, because `IVec3.hashCode` is Dart's per-process seeded `Object.hash`. Offers
    now seed from a fixed spatial hash (`Mob.traderSeed`), and two runs rolled the same
    offer. Chest loot (`Game.chestInventory`, from stage 23) still seeds with
    `IVec3.hashCode`, so a chest's loot changes across restarts and between peers. Noted,
    not changed here.
  - **Trade screen.** A Flutter widget under a transparent `Material`. The rows are
    `CustomPaint` using `Hud.drawItemIcon`, and the flash state lives on `Game`
    (`tradeFlash`). The first capture showed all three rows piled at the left edge, because
    a `CustomPaint` gets no width in a start-aligned `Column`. Each row now takes the full
    width.

  Probe lesson: the village hover uses fly mode with nobody at the keys, so the camera is
  pinned to the hover point before the shot.

- **2026-09-14** — stage 25, the port of `40f3068dd4`. Every `--stage25` line landed green on
  both processes, with Godot's boat figure (1.95 m) and flow figure (24 cells in 4 batches).
  Engine differences:
  - **The wire.** Godot's 15 new RPCs are JSON message types on the TCP line: `drop_poses`,
    `give_rest`, `bag`, `boat` / `boat_poses` / `boat_free`, `boat_req` / `board_req` /
    `unboard_req` / `break_boat_req`, `bobber` / `bobber_gone`, `blocks`, `block_ack`, and
    `chest_set` / `block_req` grew their fields. Godot's reliable / unreliable split and its
    MTU limits (≤40 pose rows, ≤200 cells a packet) are moot on a TCP stream. The splits are
    kept, so the counters mean the same thing.
  - **Net ids.** A boat gets a counter id like drops, where Godot uses `get_instance_id`. A
    bobber replica takes the puppet's hand as a closure, the same trick `ItemDrop` uses to
    avoid naming `RemotePlayer`. The host does not relay one client's bobber to another,
    because a client only knows the host's puppet here.
  - **Pure pieces.** The chest accounting is `Net.chestEditVerdict`, and the prediction
    bookkeeping is `BlockPrediction`. Both are unit-tested without a socket. The flow batch
    wraps `tickFlow` in the fixed 60 Hz `_tick`, where Godot wraps `_process`.
  - **Probe timing.** Godot's host waits a flat 1.5 s before dropping the iron stack. The
    Flutter client can still be filling its window then, so the host also waits (up to 15 s)
    for the declared bag to show room for exactly one. The client waits at least Godot's
    4.5 s, and on until the rest drop shows. Boat rowing goes through `probeWalk`, as in
    Godot's headless run.

  Probe lessons: a Python port check before starting the client counts as a peer (the host
  logged "peer 2 joined" and a broken pipe on its `hello`), so the second pair waited on the
  host's "window filled" log line instead. The client's HP read 13/30 in the capture. The
  `--wait-peer` zombie is spawned on the client too in Flutter, while Godot spawns it on the
  host only. That comes from the stage 15/17 port; noted, not changed here.

- **2026-09-14** — stage 24, the port of `a7e167737f`. Every `--stage24` line landed on Godot's
  figures, and the three screens were captured. Engine differences:
  - **The scene reload.** Godot's probe saves, then calls `reload_current_scene`. Here
    `GameView` keys a `_GameSession` by a generation number, and `Game.reloader` bumps it.
    The old `Game` is disposed (its isolate pool too), and a fresh one runs `init` with the
    same arguments. The singletons (`GameState`, `Net`, `Settings`) survive, as Godot's
    autoloads do. `probe24.flag` sits beside `worlds/`, standing in for `user://`.
  - **Where the pieces live.** `Settings` is a static singleton loaded in `main` before
    `runApp`, not an autoload. `settings.cfg` is written as Godot's `ConfigFile` text by a
    small hand-written reader/writer. Master volume is `SoLoud.setGlobalVolume`, where Godot
    sets bus 0's dB; it is applied again once SoLoud finishes its background init.
  - **Map and journal.** The world map image is built on the UI thread every 2 s and
    uploaded with `decodeImageFromPixels`, like the stage 11 minimap. The panel scales
    down when the window is smaller than Godot's 1040x760. The tab list and
    `questEntries` live in `quests.dart` as `JournalTabs`, so `Game` never imports the
    UI; Godot keeps them on `JournalScreen`.
  - **Save details.** The "pets" group is `Game.pets`: the loader puts a tamed mob there
    itself instead of relying on `restore_tamed`'s `add_to_group`. A restored drop goes
    through `Net.onDropSpawned`, so a host announces it. A visited chunk is keyed by the
    floored position, not Godot's truncating `Vector3i`, which only differs a block west
    or north of the origin.
  - **A bug the capture found.** The first `--open-settings` capture showed Flutter's red
    "No Material widget found" over every slider and switch, and yellow-underlined text.
    The overlay sits in the game's `Stack` with no `Scaffold` above it. That was already
    true of the stage 12 pause-menu sliders and the death screen, so both screens are now
    wrapped in a transparent `Material`.

  Probe lesson: two app instances launched at once hang the second one (2 s of CPU in
  five minutes, no output), so the captures ran one at a time. The minimap's new second
  legend line wraps to two lines at 240 px and can run into the notifications column;
  left as is.

- **2026-09-14** — stage 23, the port of `ae79edbd53`. The Godot diff went across almost line
  for line, and every probe figure landed on Godot's except the loot lines. Engine differences:
  - Q is `GameAction.ability2`, and it shares the physical key with `dropItem`, exactly as
    Godot's `project.godot` binds `drop_item` and `ability2` both to Q. One press does both
    in each engine; not fixed here, because the spec does it too.
  - The table class is `LootTables`, because `Loot` already names the loot-weapon record in
    `game.dart`. Rows are `LootEntry` consts rather than dictionaries.
  - `ItemStack.dur` uses -1 for Godot's absent `dur` key, and is saved only when it is set.
    `copy` and `takeFromSlot` carry it, so a worn sword keeps its wear when it moves slots.
  - The plate check runs inside the fixed 60 Hz `_tick`, right after the bodies move. That
    stands in for Godot's `Main._physics_process`. It also scans pets, which Godot's "mobs"
    group includes. A lit fuse is the existing `_Tnt` entry, so defusing removes its node
    and puts the block back.
  - The stun and ghost tint swaps every part's `MeshPrimitive.material` for one blended
    `PhysicallyBasedMaterial` per mob, in place of Godot's `material_override`. The shared
    vertex-colour material comes back when the stun ends.
  - The probe's `await physics_frame` walks are `_ticks(n)` on the stage 22 per-tick hook.
    Only the capture loop counts rendered frames.
  - The stage 21a teleport is reused with radius 48, and it now returns the structure
    origin. Flutter's air pocket for the orbit camera is still carved there, 6–16 m south
    of the temple centre, outside the pyramid.

  Not Godot's numbers: the four loot lines, since the RNG differs. The boss bar reads
  "164 / 163" because `hp.ceil()` shows 163.2 as 164 while `maxHp.toInt()` shows 163; that
  rounding was already in the HUD. `test/world_test.dart` now expects 22 species.

- **2026-09-14** — stage 22, the port of `9a86811525`, and the missing row for stage 17
  (already in the code; `--strike` re-run, 18 → 8). The Godot diff went across almost line
  for line. Engine differences:
  - A `CollisionBox` holds min/max corners where Godot's `AABB` holds position + size.
  - The flow queue is an insertion-ordered `Set<IVec3>` standing in for Godot's
    `Dictionary` keys.
  - `tickFlow` is called from the fixed 60 Hz `_tick`, not from the frame's `_process`.
  - The client gate is a `flowEnabled` flag the game sets from `Net`, because
    `VoxelWorld` does not import the network.
  - Godot's probe walks `await physics_frame`. A per-frame `nextFrame()` here would drop
    ticks whenever one frame runs several (the probe run held 80 fps against 60 Hz ticks),
    so `Game` grew a `_probeTick` hook called right after each simulation step. The walks
    then count ticks exactly as Godot's do, and all three landed on Godot's numbers.

  One figure moved without a code cause I could find: `--stage20 --ride` reported 0.71 m
  at -8.1 m/s, against 0.85 m at -8.6 on 2026-09-10. That measurement counts ten *frames*,
  not ticks, and this run held 80 fps, so about 7.5 ticks fell inside the window. The ride
  is on a flat grass pad that the new box sweep resolves exactly like the old cube sweep.
  It was not re-measured against the previous commit.

- **2026-09-10 s6** — stage 21b, the network half of `5817cae3f`, as 11 new JSON message
  types. One real bug fell out of it: the client used to build its world before the host's
  `hello` arrived, so the spawn search ran on the default seed and the client started hundreds
  of metres from the host on terrain that was then replaced. The launcher now waits up to 8 s
  for `connected` before entering the game, and both peers spawn together. Two smaller notes:
  `ItemDrop` reaches a peer's puppet through the `Target` interface rather than naming
  `RemotePlayer` (the same import cycle Godot dodged by duck-typing), and the captured frame
  needed the camera pinned one more time right before the shot, because a body is swept out of
  whatever it stands in on every tick.

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
