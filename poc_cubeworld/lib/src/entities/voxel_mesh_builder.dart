import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/items.dart';
import 'package:voxel_core/voxel_core.dart';

/// Builds a MeshGeometry from a small voxel map {IVec3: colour} at a given
/// scale. Used for creatures, the player, held items and drops (Cube World
/// style characters).
class VoxelMeshBuilder {
  VoxelMeshBuilder._();

  static PhysicallyBasedMaterial? _material;

  static PhysicallyBasedMaterial material() => _material ??= PhysicallyBasedMaterial()
    ..roughnessFactor = 0.9
    ..metallicFactor = 0.0;

  static const List<int> _faceVerts = [
    0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1,
    0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0,
    1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1,
    0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1,
    0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0,
  ];
  static const List<IVec3> _faceNormals = [
    IVec3(0, 1, 0), IVec3(0, -1, 0), IVec3(1, 0, 0), IVec3(-1, 0, 0), IVec3(0, 0, 1), IVec3(0, 0, -1),
  ];
  static const List<double> _faceTint = [1.0, 0.6, 0.84, 0.84, 0.74, 0.74];

  /// voxels: {IVec3: colour}. scale: metres per voxel. origin: voxel-space point
  /// that maps to the node origin (so a leg can pivot at its hip). Returns null
  /// for an empty map.
  static MeshGeometry? build(Map<IVec3, Vector3> voxels, double scale, [Vector3? origin]) {
    final o = origin ?? Vector3.zero();
    var faces = 0;
    for (final p in voxels.keys) {
      for (var f = 0; f < 6; f++) {
        if (!voxels.containsKey(p + _faceNormals[f])) faces++;
      }
    }
    if (faces == 0) return null;
    final positions = Float32List(faces * 12);
    final normals = Float32List(faces * 12);
    final colors = Float32List(faces * 16);
    final indices = Int32List(faces * 6);
    var v = 0, ii = 0;
    for (final e in voxels.entries) {
      final p = e.key;
      final color = e.value;
      for (var f = 0; f < 6; f++) {
        if (voxels.containsKey(p + _faceNormals[f])) continue;
        final tint = _faceTint[f];
        final n = _faceNormals[f];
        final first = v;
        for (var i = 0; i < 4; i++) {
          final k = f * 12 + i * 3;
          positions[v * 3] = (p.x + _faceVerts[k] - o.x) * scale;
          positions[v * 3 + 1] = (p.y + _faceVerts[k + 1] - o.y) * scale;
          positions[v * 3 + 2] = (p.z + _faceVerts[k + 2] - o.z) * scale;
          normals[v * 3] = n.x.toDouble();
          normals[v * 3 + 1] = n.y.toDouble();
          normals[v * 3 + 2] = n.z.toDouble();
          colors[v * 4] = color.x * tint;
          colors[v * 4 + 1] = color.y * tint;
          colors[v * 4 + 2] = color.z * tint;
          colors[v * 4 + 3] = 1.0;
          v++;
        }
        // Godot's winding (clockwise seen from the normal side), drawn front
        // facing through `MirroredCamera`.
        indices[ii++] = first;
        indices[ii++] = first + 1;
        indices[ii++] = first + 2;
        indices[ii++] = first;
        indices[ii++] = first + 2;
        indices[ii++] = first + 3;
      }
    }
    return MeshGeometry.fromArrays(positions: positions, normals: normals, colors: colors, indices: indices);
  }

  /// Fills a box [from, to] inclusive with a colour, with ±jitter noise per voxel.
  static void box(Map<IVec3, Vector3> voxels, IVec3 from, IVec3 to, Vector3 color, [double jitter = 0.05]) {
    for (var x = from.x; x <= to.x; x++) {
      for (var y = from.y; y <= to.y; y++) {
        for (var z = from.z; z <= to.z; z++) {
          final h = (x * 73856093) ^ (y * 19349663) ^ (z * 83492791);
          final n = 1.0 + ((h.abs() % 1000) / 1000.0 - 0.5) * 2.0 * jitter;
          voxels[IVec3(x, y, z)] = Vector3(color.x * n, color.y * n, color.z * n);
        }
      }
    }
  }

  /// The same voxels mirrored across the x = 0 plane. A voxel at x covers
  /// [x, x+1], so its mirror covers [-x-1, -x]. Rebuilding the map is how a
  /// left wing is made from a right one: scaling a node by -1 would mirror it
  /// too, but it also reverses the winding, and this renderer draws Godot's
  /// winding front-facing (see `MirroredCamera`).
  static Map<IVec3, Vector3> mirrorX(Map<IVec3, Vector3> voxels) => {
        for (final e in voxels.entries) IVec3(-e.key.x - 1, e.key.y, e.key.z): e.value,
      };

  static Node meshNode(Map<IVec3, Vector3> voxels, double scale, [Vector3? origin]) {
    final g = build(voxels, scale, origin);
    final node = Node();
    if (g != null) node.mesh = Mesh(g, material());
    return node;
  }

  static Vector3 blockColor(int id) {
    final d = Blocks.def(id);
    return Vector3(d.r, d.g, d.b);
  }

  static Vector3 itemColor(String id) {
    final d = Items.def(id);
    return Vector3(d.r, d.g, d.b);
  }

  static final Map<String, ItemShape> _shapes = {};

  /// A quarter turn about a held model's shaft: a flat tool is built with its
  /// head across X, and both hands turn it so the head runs along the swing.
  static final Quaternion headInSwingPlane = Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 2);

  /// What [itemId] looks like — one voxel model, built once, that the hand
  /// (both views), the drop on the ground and the inventory icon all draw.
  static ItemShape itemShape(String itemId) => _shapes[itemId] ??= _buildShape(itemId);

  /// [itemId]'s model as a scene node, standing up its own +Y from its grip.
  static Node heldItem(String itemId) {
    final shape = itemShape(itemId);
    final root = Node();
    root.add(meshNode(shape.voxels, shape.scale, shape.origin));
    return root;
  }

  static ItemShape _buildShape(String itemId) {
    final v = <IVec3, Vector3>{};
    final color = itemColor(itemId);
    if (Items.isBlock(itemId)) {
      final block = Items.blockOf(itemId);
      final c = blockColor(block);
      final shape = Blocks.shapeOf(block);
      // The blocks that are not a box in the world are not one in the hand
      // either: the same post, sprout and flower the chunk mesher draws.
      if (shape == BlockShape.torch) {
        box(v, const IVec3(3, 0, 3), const IVec3(4, 3, 4), Vector3(0.45, 0.32, 0.18), 0.03);
        box(v, const IVec3(3, 4, 3), const IVec3(4, 4, 4), c, 0.0);
        return ItemShape(v, 0.045, Vector3(4, 0, 4), flat: false, block: false);
      }
      if (shape == BlockShape.cross) {
        for (var i = 0; i < 8; i++) {
          final top = 2 + (i * 5 + 3) % 3 + (i > 1 && i < 6 ? 1 : 0);
          box(v, IVec3(i, 0, i), IVec3(i, 1, i), c * 0.7, 0.04);
          box(v, IVec3(i, 2, i), IVec3(i, top, i), c, 0.04);
          box(v, IVec3(i, 0, 7 - i), IVec3(i, 1, 7 - i), c * 0.7, 0.04);
          box(v, IVec3(i, 2, 7 - i), IVec3(i, top - 1, 7 - i), c, 0.04);
        }
        return ItemShape(v, 0.045, Vector3(4, 0, 4), flat: false, block: false);
      }
      if (shape == BlockShape.flower) {
        box(v, const IVec3(3, 0, 3), const IVec3(3, 3, 3), Vector3(0.30, 0.55, 0.22), 0.03);
        box(v, const IVec3(2, 4, 2), const IVec3(4, 4, 4), c, 0.04);
        return ItemShape(v, 0.045, Vector3(3.5, 0, 3.5), flat: false, block: false);
      }
      final height = shape == BlockShape.slab ? 1 : 3;
      box(v, IVec3.zero, IVec3(3, height, 3), c, 0.06);
      return ItemShape(v, 0.09, Vector3(2, 0, 2), flat: false, block: true);
    }
    final kind = Items.kind(itemId);
    final handle = Vector3(0.45, 0.32, 0.18);
    // Tools and weapons are drawn flat in XY, a shaft up +Y from the grip and
    // a head across X.
    if (kind == ItemKind.tool) {
      box(v, const IVec3(0, 0, 0), const IVec3(0, 9, 0), handle);
      final tool = Items.toolOf(itemId);
      if (tool == ToolType.pickaxe) {
        box(v, const IVec3(-3, 9, 0), const IVec3(3, 9, 0), color);
        box(v, const IVec3(-4, 8, 0), const IVec3(-4, 8, 0), color);
        box(v, const IVec3(4, 8, 0), const IVec3(4, 8, 0), color);
      } else if (tool == ToolType.axe) {
        box(v, const IVec3(0, 8, 0), const IVec3(2, 10, 0), color);
        box(v, const IVec3(3, 9, 0), const IVec3(3, 9, 0), color);
      } else {
        box(v, const IVec3(-1, 9, 0), const IVec3(1, 11, 0), color);
      }
      return ItemShape(v, 0.045, Vector3(0.5, 0, 0.5), flat: true, block: false);
    }
    if (kind == ItemKind.weapon) {
      final style = Items.styleOf(itemId);
      if (style == 'bow') {
        box(v, const IVec3(0, -4, 0), const IVec3(0, 4, 0), color);
        box(v, const IVec3(1, -5, 0), const IVec3(1, -3, 0), color);
        box(v, const IVec3(1, 3, 0), const IVec3(1, 5, 0), color);
        box(v, const IVec3(-1, -5, 0), const IVec3(-1, 5, 0), Vector3(0.9, 0.9, 0.85), 0.0);
      } else if (style == 'staff') {
        box(v, const IVec3(0, 0, 0), const IVec3(0, 12, 0), handle);
        box(v, const IVec3(-1, 12, -1), const IVec3(1, 14, 1), color);
      } else {
        final length = style == 'melee_fast' ? 6 : 10;
        box(v, const IVec3(0, 0, 0), const IVec3(0, 2, 0), handle);
        box(v, const IVec3(-1, 3, 0), const IVec3(1, 3, 0), Vector3(0.5, 0.5, 0.5));
        box(v, const IVec3(0, 4, 0), IVec3(0, 3 + length, 0), color, 0.02);
      }
      return ItemShape(v, 0.045, Vector3(0.5, 0, 0.5), flat: true, block: false);
    }
    if (kind == ItemKind.food) {
      // A round lump: a 5-wide cube with its edges filed off.
      box(v, const IVec3(-2, 1, -1), const IVec3(2, 3, 1), color);
      box(v, const IVec3(-1, 0, -1), const IVec3(1, 4, 1), color);
      box(v, const IVec3(-1, 1, -2), const IVec3(1, 3, 2), color);
      return ItemShape(v, 0.045, Vector3(0.5, 0, 0.5), flat: false, block: false);
    }
    if (kind == ItemKind.equipment) {
      // A chest piece seen from the front: shoulders, a body and a neck gap.
      box(v, const IVec3(-3, 4, 0), const IVec3(-1, 6, 0), color);
      box(v, const IVec3(1, 4, 0), const IVec3(3, 6, 0), color);
      box(v, const IVec3(-2, 0, 0), const IVec3(2, 5, 0), color);
      box(v, const IVec3(-2, 0, 0), const IVec3(2, 0, 0), color * 0.75, 0.02);
      return ItemShape(v, 0.045, Vector3(0.5, 0, 0.5), flat: true, block: false);
    }
    // A material: a small cut gem, wider at its girdle.
    box(v, const IVec3(-1, 0, 0), const IVec3(1, 0, 0), color * 0.8);
    box(v, const IVec3(-2, 1, 0), const IVec3(2, 2, 0), color);
    box(v, const IVec3(-1, 3, 0), const IVec3(1, 3, 0), color * 1.15);
    box(v, const IVec3(0, 4, 0), const IVec3(0, 4, 0), color * 1.15);
    return ItemShape(v, 0.045, Vector3(0.5, 0, 0.5), flat: true, block: false);
  }
}

/// One item's voxel model. Every place an item is drawn reads this, so a
/// pickaxe is the same pickaxe in the hand, on the ground and in the bag.
class ItemShape {
  ItemShape(this.voxels, this.scale, this.origin, {required this.flat, required this.block});

  /// {voxel: colour}.
  final Map<IVec3, Vector3> voxels;

  /// Metres per voxel.
  final double scale;

  /// The voxel-space point the model's node sits on: its grip, on the floor
  /// of the model.
  final Vector3 origin;

  /// Drawn in the XY plane, one voxel deep: a tool, a weapon, a flat piece.
  /// An icon looks at its face; a block is looked at from a corner.
  final bool flat;

  /// Carried the way a block is (a box against the palm) rather than
  /// standing up out of the fist.
  final bool block;

  /// The model's bounds in metres, in its node's space.
  Aabb3 bounds() {
    final lo = Vector3.all(double.infinity), hi = Vector3.all(double.negativeInfinity);
    for (final p in voxels.keys) {
      final a = Vector3((p.x - origin.x) * scale, (p.y - origin.y) * scale, (p.z - origin.z) * scale);
      final b = a + Vector3.all(scale);
      Vector3.min(lo, a, lo);
      Vector3.max(hi, b, hi);
    }
    return Aabb3.minMax(lo, hi);
  }
}

/// Euler helpers shared by every animated part (Godot's rotation.x/y/z).
Quaternion eulerYXZ(double x, double y, double z) {
  final qy = Quaternion.axisAngle(Vector3(0, 1, 0), y);
  final qx = Quaternion.axisAngle(Vector3(1, 0, 0), x);
  final qz = Quaternion.axisAngle(Vector3(0, 0, 1), z);
  return qy * qx * qz;
}

double lerpAngle(double from, double to, double t) {
  var d = (to - from) % (2 * 3.141592653589793);
  if (d > 3.141592653589793) d -= 2 * 3.141592653589793;
  if (d < -3.141592653589793) d += 2 * 3.141592653589793;
  return from + d * t;
}

double lerpd(double a, double b, double t) => a + (b - a) * t;

/// Stage 32: flutter_scene 0.23 copies a primitive's material into its render
/// item when the mesh is assigned to the node, so writing `primitive.material`
/// alone never reaches the screen. Re-assigning the same primitives as a new
/// [Mesh] keeps the render items (same geometry) and refreshes their materials.
/// Call after swapping the materials of [n]'s mesh.
void refreshMeshMaterials(Node n) {
  final mesh = n.mesh;
  if (mesh == null) return;
  n.mesh = Mesh.primitives(primitives: mesh.primitives);
}
