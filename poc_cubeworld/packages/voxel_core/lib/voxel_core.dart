/// Pure-Dart voxel engine core: chunk grid, meshing with light and ambient
/// occlusion, chunk streaming on isolates, voxel physics. Renderer-agnostic.
library;

export 'src/grid/block_shape.dart';
export 'src/grid/chunk_size.dart';
export 'src/grid/voxel_block_table.dart';
export 'src/math/ivec3.dart';
export 'src/mesh/chunk_mesher.dart';
export 'src/persistence/edit_delta_codec.dart';
export 'src/physics/voxel_body.dart';
export 'src/physics/voxel_raycast.dart';
export 'src/streaming/chunk_streamer.dart';
export 'src/streaming/chunk_worker_pool.dart';
