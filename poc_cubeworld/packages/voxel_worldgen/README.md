# voxel_worldgen

World generation for `voxel_core`, declared instead of coded: biomes chosen
by climate, terrain recipes, caves, ores, trees, plants and structures. A
`WorldGenSpec` compiles to a `ChunkGenerator` that runs on the worker
isolates. Pure Dart.

> **Status: 0.0.0.** The API can still change. Not published yet.

## Features

- `WorldGenSpec`: sea level, bedrock, biomes, beach, caves, ores, structures.
- `Biome` with a `Climate`, top and under blocks, `TreeSpec`s and `Plant`s.
- `TerrainRecipe`, `CaveSpec`, `Ore`.
- `StructureSpec` + `StructureSite`: build anything in a few calls (`level`, `fill`, `put`).
- `FastNoiseLite` for your own noise.

## Install

`voxel_worldgen` is at 0.0.0 and not on pub.dev yet. Depend on it by path (or by git):

```yaml
dependencies:
  voxel_worldgen:
    path: ../packages/voxel_worldgen
```

Dart SDK `^3.13.0`.

## Usage

1. **Name your blocks.** The spec uses string ids; you give it their numbers.

   ```dart
   const blocks = ['air', 'stone', 'dirt', 'grass', 'sand', 'water', 'log', 'leaves'];
   final ids = {for (var i = 0; i < blocks.length; i++) blocks[i]: i};
   ```

2. **Declare the world.**

   ```dart
   const world = WorldGenSpec(
     biomes: [
       Biome('forest', top: 'grass', under: 'dirt', climate: Climate.wet,
           trees: [TreeSpec.oak(log: 'log', leaves: 'leaves')], treeChance: 90),
       Biome('plains', top: 'grass', under: 'dirt'),
     ],
     beach: Biome('beach', top: 'sand'),
   );
   ```

3. **Compile it with a seed** and use it as any `voxel_core` generator.

   ```dart
   ChunkGenerator makeGenerator() => world.compile(ids, 2024);
   ```

4. **Ask it about the world** without generating chunks: `surfaceHeight(x, z)`,
   `biomeAt(x, z)`, `structuresNear(cx, cz)`.

5. **Add a structure** with a build function:

   ```dart
   void tower(StructureSite s) {
     s.level(-2, -2, 2, 2, 'stone', clearTo: 10);
     s.fill(-2, 0, -2, 2, 8, 2, 'stone', hollow: true);
   }
   // structures: [StructureSpec('tower', build: tower, biomes: ['plains'], radius: 3)]
   ```

## Example

```sh
dart run example/voxel_worldgen_example.dart
```

[`example/voxel_worldgen_example.dart`](example/voxel_worldgen_example.dart)
prints a text map of a four-biome world with towers, then generates 25 chunks
on isolates.
