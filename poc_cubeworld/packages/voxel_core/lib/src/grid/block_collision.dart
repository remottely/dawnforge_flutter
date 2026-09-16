import '../physics/voxel_body.dart';
import 'block_shape.dart';
import 'voxel_block_table.dart';

/// The sides of a fence that reach toward a neighbour, as bits of a mask.
abstract final class FenceJoin {
  /// Toward -x.
  static const int west = 1;

  /// Toward +x.
  static const int east = 2;

  /// Toward -z.
  static const int north = 4;

  /// Toward +z.
  static const int south = 8;
}

/// The sides of the fence at ([x], [y], [z]) that join a neighbour: a fence or
/// an opaque block beside it. The mesher draws its rails by the same rule, and
/// the outline and the collider read it here, so the three cannot disagree.
int fenceJoinsAt(VoxelQuery q, int x, int y, int z) {
  final table = q.table;
  bool joins(int dx, int dz) {
    final n = q.getBlockXYZ(x + dx, y, z + dz);
    return n != VoxelBlockTable.air && (table.isOpaque(n) || table.shapeOf(n) == BlockShape.fence);
  }

  return (joins(-1, 0) ? FenceJoin.west : 0) |
      (joins(1, 0) ? FenceJoin.east : 0) |
      (joins(0, -1) ? FenceJoin.north : 0) |
      (joins(0, 1) ? FenceJoin.south : 0);
}

/// The boxes a fence with [joins] stops a body with, in the block's own 0..1
/// space: the post, stretched along each axis to the sides it joins. Every
/// piece is as tall as the post, so a joined run cannot be jumped anywhere.
/// Shared: never mutate.
List<CollisionBox> fenceBoxesOf(int joins) => _fenceBoxes[joins];

final List<List<CollisionBox>> _fenceBoxes = List.unmodifiable([
  for (var joins = 0; joins < 16; joins++) List<CollisionBox>.unmodifiable(_buildFenceBoxes(joins)),
]);

List<CollisionBox> _buildFenceBoxes(int joins) {
  const post = CollisionBox.fencePost;
  final alongX = joins & (FenceJoin.west | FenceJoin.east) != 0;
  final alongZ = joins & (FenceJoin.north | FenceJoin.south) != 0;
  if (!alongX && !alongZ) return const [post];
  return [
    if (alongX)
      CollisionBox(joins & FenceJoin.west != 0 ? 0 : post.x0, post.y0, post.z0, joins & FenceJoin.east != 0 ? 1 : post.x1,
          post.y1, post.z1),
    if (alongZ)
      CollisionBox(post.x0, post.y0, joins & FenceJoin.north != 0 ? 0 : post.z0, post.x1, post.y1,
          joins & FenceJoin.south != 0 ? 1 : post.z1),
  ];
}

/// The boxes a body collides with at the world cell ([x], [y], [z]), in the
/// block's own 0..1 space. Most blocks answer from their shape alone
/// ([VoxelBlockTable.collisionBoxes]); a fence also reads its neighbours.
List<CollisionBox> collisionBoxesAt(VoxelQuery q, int x, int y, int z) {
  final table = q.table;
  final id = q.getBlockXYZ(x, y, z);
  if (table.shapeOf(id) == BlockShape.fence && table.isSolid(id)) return fenceBoxesOf(fenceJoinsAt(q, x, y, z));
  return table.collisionBoxes(id);
}
