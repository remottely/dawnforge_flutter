# voxel_content

Game content on top of `voxel_core`, by string id: blocks and items,
tags, mining times, inventories, crafting, loot tables and status effects.
Pure Dart.

> **Status: 0.0.0.** The API can still change. Not published yet.

## Features

- `BlockRegistry` / `BlockType`: blocks by id, numbered for the engine (`registry.table`).
- `ItemRegistry` / `ItemType`: tools, tiers, stack sizes, durability.
- `MiningRules`: how long a block takes to break, and whether it drops.
- `Inventory` / `ItemStack`: stacking, wear, listeners, JSON.
- `RecipeBook` / `Recipe`: all-or-nothing crafting, by station.
- `LootTable`: seeded rolls, the same on every machine.
- `StatusEffects` / `EffectType`: timed effects that deal damage, heal and change stats.

## Install

`voxel_content` is at 0.0.0 and not on pub.dev yet. Depend on it by path (or by git):

```yaml
dependencies:
  voxel_content:
    path: ../packages/voxel_content
```

Dart SDK `^3.13.0`.

## Usage

1. **Declare blocks.** Air first; the order numbers them.

   ```dart
   final blocks = BlockRegistry(const [
     BlockType('air', color: 0, solid: false, hardness: -1, drop: ''),
     BlockType('stone', color: 0x7F7F84, hardness: 1.5, tool: 'pickaxe', tier: 1, drop: 'cobblestone'),
     BlockType('cobblestone', color: 0x6E6E70, hardness: 2.0, tool: 'pickaxe'),
   ]);
   ```

   `blocks.table` is the `VoxelBlockTable` the engine needs.

2. **Declare items.** Every block you can hold is an item already.

   ```dart
   final items = ItemRegistry([
     ...ItemRegistry.forBlocks(blocks),
     const ItemType('wooden_pickaxe', color: 0xB08850, tool: 'pickaxe', tier: 1, stack: 1, durability: 60),
   ]);
   ```

3. **Mine.** `const MiningRules().mineTime(block, tool)` gives seconds, or -1 when it cannot be broken.

4. **Carry things.**

   ```dart
   final bag = Inventory(stackSize: (id) => items[id].stack, maxDurability: (id) => items[id].durability)
     ..add('cobblestone', 10);
   ```

5. **Craft.**

   ```dart
   final book = RecipeBook(const [Recipe('stone', 1, {'cobblestone': 1}, station: 'furnace')]);
   book.craft(book.available('furnace').first, bag);
   ```

## Example

```sh
dart run example/voxel_content_example.dart
```

[`example/voxel_content_example.dart`](example/voxel_content_example.dart) walks
through blocks, mining, an inventory, crafting, a loot chest, status effects
and saving.
