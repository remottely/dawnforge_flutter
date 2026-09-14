import 'dart:math' as math;

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

  /// Stage 23: a ghost passes through every block.
  bool noclip = false;

  /// The horizontal direction the last move was stopped in.
  Vector3 _blocked = Vector3.zero();

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
    _blocked = Vector3.zero();
    if (noclip) {
      position = next + velocity * dt;
      onFloor = false;
      _senseFluids();
      return;
    }
    next.x += velocity.x * dt;
    var hit = _solidBoxesAt(next);
    if (hit.isNotEmpty) {
      next.x = _resolveAxis(hit, 0, velocity.x > 0.0);
      _blocked.x = velocity.x > 0.0 ? 1.0 : -1.0;
      velocity.x = 0.0;
      hitWall = true;
    }
    next.z += velocity.z * dt;
    hit = _solidBoxesAt(next);
    if (hit.isNotEmpty) {
      next.z = _resolveAxis(hit, 2, velocity.z > 0.0);
      _blocked.z = velocity.z > 0.0 ? 1.0 : -1.0;
      velocity.z = 0.0;
      hitWall = true;
    }
    onFloor = false;
    next.y += velocity.y * dt;
    hit = _solidBoxesAt(next);
    if (hit.isNotEmpty) {
      if (velocity.y > 0.0) {
        next.y = _resolveAxis(hit, 1, true);
      } else {
        next.y = _resolveAxis(hit, 1, false);
        onFloor = true;
      }
      velocity.y = 0.0;
    }
    position = next;
    _senseFluids();
  }

  /// The coordinate along [axis] that puts the body flush against the boxes it
  /// just entered: moving positive, the nearest box face on the near side;
  /// moving negative, the farthest far face. The sweep is one axis at a time,
  /// so every box in [hit] was entered along this axis.
  double _resolveAxis(List<CollisionBox> hit, int axis, bool positive) {
    final extent = axis == 1 ? height : halfWidth;
    if (positive) {
      var face = double.infinity;
      for (final box in hit) {
        face = math.min(face, box.min(axis));
      }
      return face - extent - skin;
    }
    var face = double.negativeInfinity;
    for (final box in hit) {
      face = math.max(face, box.max(axis));
    }
    return face + skin + (axis == 1 ? 0.0 : extent);
  }

  void _senseFluids() {
    final feetId = world.getBlockXYZ(position.x.floor(), (position.y + 0.3).floor(), position.z.floor());
    final headId = world.getBlockXYZ(position.x.floor(), (position.y + height - 0.15).floor(), position.z.floor());
    inWater = Blocks.isLiquid(feetId) || Blocks.isLiquid(headId);
    headInWater = Blocks.isLiquid(headId);
    inLava = Blocks.liquidKind(feetId) == 'lava' || Blocks.liquidKind(headId) == 'lava';
  }

  /// Step up onto a low obstacle when walking into it: half a block first (a
  /// slab, the low step of stairs), then a full block. The lifted body is also
  /// tested a hair further in the blocked direction, so a half step never wins
  /// against a full-height wall.
  bool tryStepUp() {
    if (!hitWall || !onFloor) return false;
    final nudge = _blocked * 0.05;
    for (final lift in const [0.52, 1.02]) {
      final up = position + Vector3(0, lift, 0);
      if (_overlapsSolid(up) || _overlapsSolid(up + nudge)) continue;
      position = up;
      return true;
    }
    return false;
  }

  /// Cube-based on purpose: callers ask "is the body in this CELL" (a block
  /// about to be placed, a door), which does not depend on the block's shape.
  bool overlapsBlock(IVec3 b) =>
      b.x < position.x + halfWidth &&
      b.x + 1.0 > position.x - halfWidth &&
      b.y < position.y + height &&
      b.y + 1.0 > position.y &&
      b.z < position.z + halfWidth &&
      b.z + 1.0 > position.z - halfWidth;

  bool _overlapsSolid(Vector3 at) => _solidBoxesAt(at, true).isNotEmpty;

  /// Every collision box (world space) that overlaps the body placed at [at],
  /// shrunk by [skin]. The row below the feet is scanned too: a fence post is
  /// 1.5 tall and reaches into the cell above its own. [firstOnly] stops at the
  /// first hit (a yes/no query).
  List<CollisionBox> _solidBoxesAt(Vector3 at, [bool firstOnly = false]) {
    final out = <CollisionBox>[];
    final bx0 = at.x - halfWidth + skin;
    final bx1 = at.x + halfWidth - skin;
    final by0 = at.y + skin;
    final by1 = at.y + height - skin;
    final bz0 = at.z - halfWidth + skin;
    final bz1 = at.z + halfWidth - skin;
    final minX = bx0.floor();
    final maxX = bx1.floor();
    final minY = by0.floor() - 1;
    final maxY = by1.floor();
    final minZ = bz0.floor();
    final maxZ = bz1.floor();
    for (var y = minY; y <= maxY; y++) {
      for (var z = minZ; z <= maxZ; z++) {
        for (var x = minX; x <= maxX; x++) {
          // y < 0 is solid rock.
          final boxes = y < 0 ? const [Blocks.fullBox] : Blocks.collisionBoxes(world.getBlockXYZ(x, y, z));
          for (final box in boxes) {
            final p = box.shifted(x, y, z);
            if (p.x0 < bx1 && p.x1 > bx0 && p.y0 < by1 && p.y1 > by0 && p.z0 < bz1 && p.z1 > bz0) {
              out.add(p);
              if (firstOnly) return out;
            }
          }
        }
      }
    }
    return out;
  }

  /// Is there a solid block directly in front (for climbing)? Cube-based on
  /// purpose: climbing reads the cell, the shape inside it does not matter.
  bool wallAhead(Vector3 direction) {
    final probe = position + direction.normalized() * (halfWidth + 0.35);
    for (final dy in [0.3, 1.0, height - 0.2]) {
      if (world.isSolidXYZ(probe.x.floor(), (position.y + dy).floor(), probe.z.floor())) return true;
    }
    return false;
  }
}
