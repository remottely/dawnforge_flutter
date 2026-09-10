import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/items.dart';
import '../core/ivec3.dart';
import 'voxel_mesh_builder.dart';

/// A pivot with Euler angles applied every frame (Godot's Node3D rotation).
class Part {
  Part(this.node, this.base) {
    node.position = base.clone();
  }
  final Node node;
  final Vector3 base;
  double rx = 0, ry = 0, rz = 0;
  double sx = 1, sy = 1, sz = 1;
  double offX = 0, offY = 0, offZ = 0;

  void apply() {
    node.rotation = eulerYXZ(rx, ry, rz);
    node.position = Vector3(base.x + offX, base.y + offY, base.z + offZ);
    node.scale = Vector3(sx, sy, sz);
  }
}

/// A Cube World style humanoid built from voxels, with procedural walk / swing
/// animation.
class PlayerModel {
  static const double s = 0.055; // metres per voxel

  final Node root = Node(name: 'PlayerModel');
  late Part head, torso, armL, armR, legL, legR;
  final Node hand = Node();
  Node? _held;
  String _heldId = '';
  double _walkPhase = 0.0;
  double _swing = 0.0;
  double _bob = 0.0;

  /// Godot's rotation.y / rotation.x / position.y of the model node.
  double yaw = 0.0;
  double tiltX = 0.0;
  double posY = 0.0;

  /// Where the held item sits in world space (the fishing line starts there).
  Vector3 handWorldPosition() => hand.globalTransform.getTranslation();

  bool get visible => root.visible;
  set visible(bool v) => root.visible = v;

  void build(Vector3 skin, Vector3 shirt, Vector3 pants, Vector3 hair) {
    root.removeAll();
    final boots = Vector3(0.25, 0.18, 0.12);
    final eye = Vector3(0.12, 0.12, 0.16);

    var v = <IVec3, Vector3>{};
    VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -1, 1), pants);
    VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -10, 1), boots);
    legL = _part(v, Vector3(-0.11, 0.66, 0.0));
    legR = _part(v, Vector3(0.11, 0.66, 0.0));

    v = {};
    VoxelMeshBuilder.box(v, const IVec3(-4, 0, -2), const IVec3(3, 11, 1), shirt);
    VoxelMeshBuilder.box(v, const IVec3(-4, 0, -2), const IVec3(3, 1, 1), Vector3(0.35, 0.25, 0.15));
    torso = _part(v, Vector3(0.0, 0.66, 0.0));

    v = {};
    VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -1, 1), shirt);
    VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -5, 1), skin);
    armL = _part(v, Vector3(-0.33, 1.30, 0.0));
    armR = _part(v, Vector3(0.33, 1.30, 0.0));
    hand.position = Vector3(0.0, -0.62, -0.04);
    armR.node.add(hand);

    v = {};
    VoxelMeshBuilder.box(v, const IVec3(-4, 0, -4), const IVec3(3, 7, 3), skin, 0.03);
    VoxelMeshBuilder.box(v, const IVec3(-4, 6, -4), const IVec3(3, 7, 3), hair);
    VoxelMeshBuilder.box(v, const IVec3(-4, 3, 3), const IVec3(3, 5, 3), hair);
    VoxelMeshBuilder.box(v, const IVec3(-4, 2, -4), const IVec3(-4, 5, 3), hair);
    VoxelMeshBuilder.box(v, const IVec3(3, 2, -4), const IVec3(3, 5, 3), hair);
    v[const IVec3(-3, 4, -4)] = eye;
    v[const IVec3(-2, 4, -4)] = Vector3(1, 1, 1);
    v[const IVec3(1, 4, -4)] = Vector3(1, 1, 1);
    v[const IVec3(2, 4, -4)] = eye;
    head = _part(v, Vector3(0.0, 1.32, 0.0));
    _heldId = '';
    _held = null;
  }

  Part _part(Map<IVec3, Vector3> voxels, Vector3 at) {
    final pivot = Node();
    pivot.add(VoxelMeshBuilder.meshNode(voxels, s));
    root.add(pivot);
    return Part(pivot, at);
  }

  void setHeld(String itemId) {
    if (itemId == _heldId) return;
    _heldId = itemId;
    final old = _held;
    if (old != null) {
      hand.remove(old);
      _held = null;
    }
    if (itemId == '') return;
    final held = VoxelMeshBuilder.heldItem(itemId);
    if (!Items.isBlock(itemId)) {
      held.rotation = Quaternion.axisAngle(Vector3(1, 0, 0), -math.pi / 2);
    }
    hand.add(held);
    _held = held;
  }

  void swing() => _swing = 1.0;

  void animate(double dt, double speed, bool onFloor, bool gliding, bool climbing) {
    final moving = speed > 0.5;
    _walkPhase += dt * speed.clamp(0.0, 12.0) * 1.4;
    var a = moving ? math.sin(_walkPhase) * 0.65 : 0.0;
    if (!onFloor && !climbing) a = 0.35;
    legL.rx = a;
    legR.rx = -a;
    armL.rx = -a * 0.8;
    var swingAngle = 0.0;
    if (_swing > 0.0) {
      _swing = math.max(_swing - dt * 5.0, 0.0);
      swingAngle = -math.sin(_swing * math.pi) * 2.0;
    }
    armR.rx = a * 0.8 + swingAngle;
    if (gliding) {
      armL.rz = 1.4;
      armR.rz = -1.4;
      legL.rx = 0.0;
      legR.rx = 0.0;
    } else if (climbing) {
      armL.rz = 0.3;
      armR.rz = -0.3;
      armL.rx = -2.6 + a;
      armR.rx = -2.6 - a;
    } else {
      armL.rz = lerpd(armL.rz, 0.05, dt * 10.0);
      armR.rz = lerpd(armR.rz, -0.05, dt * 10.0);
    }
    _bob = moving && onFloor ? math.sin(_walkPhase).abs() * 0.03 : 0.0;
    torso.offY = _bob;
    head.offY = _bob;
    armL.offY = _bob;
    armR.offY = _bob;
    for (final p in [head, torso, armL, armR, legL, legR]) {
      p.apply();
    }
    root.rotation = eulerYXZ(tiltX, yaw, 0);
    root.position = Vector3(0, posY, 0);
  }
}
