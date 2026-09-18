# voxel_core

The engine under a voxel game, in pure Dart: a chunk grid, meshing with
light and ambient occlusion, chunk streaming on worker isolates, liquids,
physics, rays, pathfinding and a save format for edits. It draws nothing:
a renderer (such as `voxel_scene`) takes the meshes.

> **Status: 0.0.0.** The API can still change. Not published yet.

## Features

- `VoxelBlockTable` / `VoxelBlockDef`: what each block id is (shape, solid, opaque, colour, light, liquid).
- `ChunkGenerator`: your world, as a pure function of the chunk position.
- `ChunkWorkerPool` + `ChunkStreamer`: generate and mesh around the player on isolates, hand meshes to a `ChunkMeshSink`.
- `ChunkMesher`: faces with block and sky light and ambient occlusion.
- `VoxelBody`, `VoxelRaycast`, `Reach`: walking, falling, colliding and aiming at blocks.
- `LiquidFlow`, `Pathfinder`, `VoxelModel`, `EditDeltaCodec`.

## Install

`voxel_core` is at 0.0.0 and not on pub.dev yet. Depend on it by path (or by git):

```yaml
dependencies:
  voxel_core:
    path: ../packages/voxel_core
```

Dart SDK `^3.13.0`.
No Flutter dependency: it runs in `dart test`, on servers and on isolates.

## Usage

1. **Describe your blocks.** Id 0 is air.

   ```dart
   final table = VoxelBlockTable(const [
     VoxelBlockDef(shape: BlockShape.cube, solid: false, opaque: false, r: 0, g: 0, b: 0, a: 0), // air
     VoxelBlockDef(shape: BlockShape.cube, solid: true, opaque: true, r: 0.4, g: 0.4, b: 0.45),  // stone
   ]);
   ```

2. **Write a generator.** It fills one chunk and must be pure in the position.

   ```dart
   class Flat implements ChunkGenerator {
     const Flat();
     @override
     Uint8List generateIn(int cx, int cz, int dimension) {
       final blocks = Uint8List(ChunkSize.volume);
       for (var z = 0; z < ChunkSize.sizeZ; z++) {
         for (var x = 0; x < ChunkSize.sizeX; x++) {
           for (var y = 0; y < 40; y++) {
             blocks[ChunkSize.index(x, y, z)] = 1;
           }
         }
       }
       return blocks;
     }
   }

   ChunkGenerator makeGenerator() => const Flat(); // top-level: sent to each isolate
   ```

3. **Stream chunks around a point.** The sink receives each finished mesh.

   ```dart
   final pool = ChunkWorkerPool(ChunkWorkerConfig(generator: makeGenerator, table: table));
   await pool.start();
   final streamer = ChunkStreamer(table: table, sink: mySink, loadRadius: 4)
     ..jobs = pool
     ..updateAround((x: 0, z: 0));
   // Once a frame:
   streamer.update();
   ```

4. **Read and edit the world.** `streamer.getBlockXYZ`, `streamer.setBlock`,
   `VoxelRaycast.solid(...)` for aiming, `VoxelBody` for anything that walks.

5. **Save only the edits** with `EditDeltaCodec`; the generator rebuilds the rest.

## Example

```sh
dart run example/voxel_core_example.dart
```

[`example/voxel_core_example.dart`](example/voxel_core_example.dart) streams
sine hills, casts a ray, places a lamp, saves the edit and drops a body onto
the ground.
