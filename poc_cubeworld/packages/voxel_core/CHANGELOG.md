# Changelog

## 0.0.0

First version, not published.

- Block table: shapes, solidity, opacity, colour, light and liquids by id.
- Chunk grid, and meshing with block and sky light and ambient occlusion.
- Chunk streaming around a point, generated and meshed on worker isolates.
- Liquid flow, voxel physics (`VoxelBody`), rays (`VoxelRaycast`) and reach.
- A* pathfinding over blocks, with path costs.
- Voxel models, and a compact save format for edits (`EditDeltaCodec`).
- Pure Dart, renderer-agnostic.
