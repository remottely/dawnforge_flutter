import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/ivec3.dart';
import '../world/voxel_world.dart';

/// An AABB anchored at the feet, swept against the block volume one axis at a
/// time. Owns the scene node that carries its visuals.
class VoxelBody {
  static const double skin = 0.001;
  static const double gravity = 26.0;
  static const double waterGravity = 4.0;

  final Node node = Node();
  Vector3 position = Vector3.zero();
  double halfWidth = 0.3;
  double height = 1.75;
  Vector3 velocity = Vector3.zero();
  bool onFloor = false;
  bool inWater = false;
  bool headInWater = false;
  bool inLava = false;
  bool hitWall = false;
  late VoxelWorld world;
  bool removed = false;

  void setup(VoxelWorld w, double hw, double h) {
    world = w;
    halfWidth = hw;
    height = h;
  }

  Vector3 centre() => position + Vector3(0, height * 0.5, 0);

  /// Pushes the position into the scene node. Call after moving.
  void syncNode() => node.position = position.clone();

  double rayDistance(Vector3 origin, Vector3 direction, [double inflate = 0.0]) {
    final mn = position - Vector3(halfWidth + inflate, inflate, halfWidth + inflate);
    final mx = position + Vector3(halfWidth + inflate, height + inflate, halfWidth + inflate);
    var near = double.negativeInfinity;
    var far = double.infinity;
    for (var axis = 0; axis < 3; axis++) {
      final d = direction[axis];
      final inv = d != 0.0 ? 1.0 / d : double.infinity;
      final a = (mn[axis] - origin[axis]) * inv;
      final b = (mx[axis] - origin[axis]) * inv;
      final lo = a < b ? a : b;
      final hi = a > b ? a : b;
      if (lo > near) near = lo;
      if (hi < far) far = hi;
    }
    if (far < near || far < 0.0) return -1.0;
    return near > 0.0 ? near : 0.0;
  }

  void applyGravity(double dt) {
    if (inWater) {
      velocity.y = (velocity.y - waterGravity * dt).clamp(-3.0, double.infinity);
    } else {
      velocity.y -= gravity * dt;
    }
  }

  void move(double dt) {
    final next = position.clone();
    hitWall = false;
    next.x += velocity.x * dt;
    if (_overlapsSolid(next)) {
      next.x = velocity.x > 0.0
          ? (next.x + halfWidth).floorToDouble() - halfWidth - skin
          : (next.x - halfWidth).floorToDouble() + 1.0 + halfWidth + skin;
      velocity.x = 0.0;
      hitWall = true;
    }
    next.z += velocity.z * dt;
    if (_overlapsSolid(next)) {
      next.z = velocity.z > 0.0
          ? (next.z + halfWidth).floorToDouble() - halfWidth - skin
          : (next.z - halfWidth).floorToDouble() + 1.0 + halfWidth + skin;
      velocity.z = 0.0;
      hitWall = true;
    }
    onFloor = false;
    next.y += velocity.y * dt;
    if (_overlapsSolid(next)) {
      if (velocity.y > 0.0) {
        next.y = (next.y + height).floorToDouble() - height - skin;
      } else {
        next.y = next.y.floorToDouble() + 1.0 + skin;
        onFloor = true;
      }
      velocity.y = 0.0;
    }
    position = next;
    _senseFluids();
  }

  void _senseFluids() {
    final feetId = world.getBlockXYZ(position.x.floor(), (position.y + 0.3).floor(), position.z.floor());
    final headId = world.getBlockXYZ(position.x.floor(), (position.y + height - 0.15).floor(), position.z.floor());
    inWater = Blocks.isLiquid(feetId) || Blocks.isLiquid(headId);
    headInWater = Blocks.isLiquid(headId);
    inLava = (feetId != Blocks.air && Blocks.idOf(feetId) == 'lava') || (headId != Blocks.air && Blocks.idOf(headId) == 'lava');
  }

  /// Step up one block when walking into a low wall.
  bool tryStepUp() {
    if (!hitWall || !onFloor) return false;
    final up = position + Vector3(0, 1.02, 0);
    if (_overlapsSolid(up)) return false;
    position = up;
    return true;
  }

  bool overlapsBlock(IVec3 b) =>
      b.x < position.x + halfWidth &&
      b.x + 1.0 > position.x - halfWidth &&
      b.y < position.y + height &&
      b.y + 1.0 > position.y &&
      b.z < position.z + halfWidth &&
      b.z + 1.0 > position.z - halfWidth;

  bool _overlapsSolid(Vector3 at) {
    final minX = (at.x - halfWidth + skin).floor();
    final maxX = (at.x + halfWidth - skin).floor();
    final minY = (at.y + skin).floor();
    final maxY = (at.y + height - skin).floor();
    final minZ = (at.z - halfWidth + skin).floor();
    final maxZ = (at.z + halfWidth - skin).floor();
    for (var y = minY; y <= maxY; y++) {
      for (var z = minZ; z <= maxZ; z++) {
        for (var x = minX; x <= maxX; x++) {
          if (world.isSolidXYZ(x, y, z)) return true;
        }
      }
    }
    return false;
  }

  /// Is there a solid block directly in front (for climbing)?
  bool wallAhead(Vector3 direction) {
    final probe = position + direction.normalized() * (halfWidth + 0.35);
    for (final dy in [0.3, 1.0, height - 0.2]) {
      if (world.isSolidXYZ(probe.x.floor(), (position.y + dy).floor(), probe.z.floor())) return true;
    }
    return false;
  }
}
