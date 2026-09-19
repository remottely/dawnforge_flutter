# voxel_game

A Minecraft-like game in a few lines. You declare the blocks, the world,
the player and the creatures in one `VoxelGameSpec` and call
`runVoxelGame`. You get a playable 3D world: mining and placing, an
inventory and crafting, day and night, creatures with goals, saves and
multiplayer.

It is the kit over `voxel_engine`, `voxel_scene` and `sound_recipes`, and it
re-exports what a game needs, so a game imports only this library.

> **Status: 0.0.0.** The API can still change. Not published yet.

## Features

- `VoxelGameSpec`: blocks, items, recipes, world, player, mobs, sky, sounds, circuits, liquids.
- `runVoxelGame` / `VoxelGameWidget`: the 3D view, a HUD, the inventory and crafting screen.
- Controls for keyboard and mouse, gamepad; first and third person.
- `MobSpec` with a `Rig` (humanoid, quadruped, bird, blob), a `Gait` and a brain of goals:
  `Wander`, `Hunt`, `MeleeAttack`, `RangedAttack`, `FleeWhenHurt`, `Explode`, `LookAtPlayer`, or `Behavior.custom`.
- `Goal` / `GoalSelector`: the same goal system for your own creature classes.
- `SpawnRule.daylight()` / `SpawnRule.dark()`, `Drop`s.
- Save slots, and `hostPort` / `join` for multiplayer.
- Hooks: `onBlockBroken`, `onBlockPlaced`, `onMobKilled`, `onTick`, and `GameSystem`s.

## Install

`voxel_game` is at 0.0.0 and not on pub.dev yet. Depend on it by path (or by git):

```yaml
dependencies:
  voxel_game:
    path: ../packages/voxel_game
```

Dart SDK `^3.13.0`.

- **macOS for now.** Turn Flutter GPU on in `macos/Runner/Info.plist`:

  ```xml
  <key>FLTEnableFlutterGPU</key>
  <true/>
  ```

- For multiplayer, add the `com.apple.security.network.server` and
  `com.apple.security.network.client` entitlements.

## Usage

1. **Declare your blocks.** Air is added for you.

   ```dart
   const blocks = [
     BlockType('stone', color: 0x7F7F84, hardness: 1.5, tool: 'pickaxe', tier: 1),
     BlockType('dirt', color: 0x8A5E3B, hardness: 0.5, tool: 'shovel'),
     BlockType('grass', color: 0x5C9E3A, hardness: 0.6, tool: 'shovel', drop: 'dirt'),
     BlockType('sand', color: 0xDCCB8A, hardness: 0.5, tool: 'shovel'),
   ];
   ```

2. **Declare the world.**

   ```dart
   const world = WorldGenSpec(
     bedrock: 'stone',
     biomes: [Biome('plains', top: 'grass', under: 'dirt')],
     beach: Biome('beach', top: 'sand'),
   );
   ```

3. **Add creatures.** The brain is a list of goals; the lower priority wins.

   ```dart
   const zombie = MobSpec('zombie', hp: 20,
       rig: Rig.humanoid(skin: 0x5E9A5A, armsForward: true),
       brain: [MeleeAttack(damage: 3), Hunt(range: 18), Wander()],
       spawn: SpawnRule.dark());
   ```

4. **Run it.**

   ```dart
   void main() => runVoxelGame(
         const VoxelGameSpec(blocks: blocks, world: world, mobs: [zombie]),
         saveSlot: 'world1',
       );
   ```

5. **Grow it** with `items`, `recipes`, `player: PlayerSpec(startingItems: {...})`,
   `sky`, `sounds`, `signals`, and the `on...` hooks.

6. **Play together (optional):** `runVoxelGame(spec, hostPort: 7777)` on one
   machine and `runVoxelGame(spec, join: '192.168.0.10')` on another.

## Example

```sh
cd example
flutter run -d macos
```

[`example/lib/main.dart`](example/lib/main.dart) is a small game in one file:
twelve blocks, two biomes with trees and coal, a few recipes, a player with a
pickaxe, sheep by day and zombies by night.
