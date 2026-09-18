# Changelog

## 0.0.0

First version, not published.

- `WorldGenSpec`: a world declared as biomes, terrain, caves, ores, trees, plants and structures.
- Biomes chosen by climate, with a beach and a sea level.
- Oak and spruce trees, ore veins, caves, scattered plants.
- Structures built from a `StructureSite` (`level`, `fill`, `put`), placed on a grid.
- Compiles to a `voxel_core` `ChunkGenerator` that runs on worker isolates.
- `FastNoiseLite` exported for custom noise.
