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

## Session log

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
