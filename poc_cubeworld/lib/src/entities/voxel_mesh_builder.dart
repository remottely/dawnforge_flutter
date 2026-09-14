import 'dart:typed_data';

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/blocks.dart';
import '../core/items.dart';
import '../core/ivec3.dart';

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
        // facing through `GodotCamera`.
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

  static Node meshNode(Map<IVec3, Vector3> voxels, double scale, [Vector3? origin]) {
    final g = build(voxels, scale, origin);
    final node = Node();
    if (g != null) node.mesh = Mesh(g, material());
    return node;
  }

  /// A single-block item icon mesh in 3D (a small cube of the block's colour).
  static Node blockCube(Vector3 color, double size) {
    final v = <IVec3, Vector3>{};
    box(v, IVec3.zero, const IVec3(3, 3, 3), color, 0.06);
    return meshNode(v, size / 4.0, Vector3(2, 2, 2));
  }

  static Vector3 blockColor(int id) {
    final d = Blocks.def(id);
    return Vector3(d.r, d.g, d.b);
  }

  static Vector3 itemColor(String id) {
    final d = Items.def(id);
    return Vector3(d.r, d.g, d.b);
  }

  /// A tool/weapon shape held in a hand: a handle and a head, coloured by the item.
  static Node heldItem(String itemId) {
    final root = Node();
    final v = <IVec3, Vector3>{};
    final color = itemColor(itemId);
    if (Items.isBlock(itemId)) {
      box(v, IVec3.zero, const IVec3(3, 3, 3), blockColor(Items.blockOf(itemId)), 0.06);
      root.add(meshNode(v, 0.09, Vector3(2, 0, 2)));
      return root;
    }
    final kind = Items.kind(itemId);
    final handle = Vector3(0.45, 0.32, 0.18);
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
    } else if (kind == ItemKind.weapon) {
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
    } else {
      box(v, const IVec3(-1, 0, -1), const IVec3(1, 2, 1), color);
    }
    root.add(meshNode(v, 0.045, Vector3(0.5, 0, 0.5)));
    return root;
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
