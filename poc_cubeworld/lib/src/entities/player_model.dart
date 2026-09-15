import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/items.dart';
import 'package:voxel_core/voxel_core.dart';
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
  double _moveWeight = 0.0; // how much of the walk cycle is in, eased
  double _airWeight = 0.0; // and how much of the airborne pose

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
    Vector3 mix(Vector3 a, Vector3 b, double t) => a + (b - a) * t;
    Vector3 shade(Vector3 c, double k) => c * k;
    // The class colour is softened toward a warm grey so it reads as dyed
    // cloth, with a darker trim for hems and cuffs.
    final cloth = mix(shirt, Vector3(0.52, 0.48, 0.44), 0.2);
    final trim = shade(cloth, 0.7);
    final pantsDark = shade(pants, 0.78);
    final boots = Vector3(0.38, 0.25, 0.15);
    final sole = Vector3(0.17, 0.12, 0.09);
    final belt = Vector3(0.30, 0.19, 0.11);
    final buckle = Vector3(0.88, 0.72, 0.32);
    final hairDark = shade(hair, 0.72);
    final white = Vector3(0.96, 0.96, 0.93);
    final iris = Vector3(0.22, 0.38, 0.62);
    final nose = shade(skin, 0.9);
    final cheek = mix(skin, Vector3(0.95, 0.55, 0.50), 0.3);
    final mouth = Vector3(skin.x * 0.72, skin.y * 0.48, skin.z * 0.46);
    // The front of every part is z = -4 (head) or z = -2 (body, limbs).

    var v = <IVec3, Vector3>{};
    VoxelMeshBuilder.box(v, const IVec3(-2, -9, -2), const IVec3(1, -1, 1), pants, 0.03);
    VoxelMeshBuilder.box(v, const IVec3(-2, -2, -2), const IVec3(1, -1, 1), pantsDark, 0.03);
    VoxelMeshBuilder.box(v, const IVec3(-2, -11, -2), const IVec3(1, -10, 1), boots, 0.04);
    VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -12, 1), sole, 0.02);
    legL = _part(v, Vector3(-0.11, 0.66, 0.0));
    legR = _part(v, Vector3(0.11, 0.66, 0.0));

    v = {};
    VoxelMeshBuilder.box(v, const IVec3(-4, 2, -2), const IVec3(3, 11, 1), cloth, 0.03);
    VoxelMeshBuilder.box(v, const IVec3(-4, 2, -2), const IVec3(3, 2, 1), trim, 0.03);
    VoxelMeshBuilder.box(v, const IVec3(-4, 0, -2), const IVec3(3, 1, 1), belt, 0.04);
    VoxelMeshBuilder.box(v, const IVec3(-1, 0, -2), const IVec3(0, 1, -2), buckle, 0.02);
    VoxelMeshBuilder.box(v, const IVec3(-2, 11, -2), const IVec3(1, 11, -2), skin, 0.02); // the neckline
    VoxelMeshBuilder.box(v, const IVec3(-1, 10, -2), const IVec3(0, 10, -2), skin, 0.02);
    torso = _part(v, Vector3(0.0, 0.66, 0.0));

    v = {};
    VoxelMeshBuilder.box(v, const IVec3(-2, -4, -2), const IVec3(1, -1, 1), cloth, 0.03);
    VoxelMeshBuilder.box(v, const IVec3(-2, -5, -2), const IVec3(1, -5, 1), trim, 0.03);
    VoxelMeshBuilder.box(v, const IVec3(-2, -12, -2), const IVec3(1, -6, 1), skin, 0.02);
    // The arm is 0.22 wide, so a pivot at 0.33 put its inner face exactly on
    // the torso's side (x = 0.22): the two faces fought for the same pixels
    // and flickered. A 1.5 cm gap keeps them apart.
    armL = _part(v, Vector3(-0.345, 1.30, 0.0));
    armR = _part(v, Vector3(0.345, 1.30, 0.0));
    hand.position = Vector3(0.0, -0.62, -0.04);
    armR.node.add(hand);

    v = {};
    VoxelMeshBuilder.box(v, const IVec3(-4, 0, -4), const IVec3(3, 7, 3), skin, 0.02);
    VoxelMeshBuilder.box(v, const IVec3(-4, 6, -4), const IVec3(3, 7, 3), hair, 0.06);
    VoxelMeshBuilder.box(v, const IVec3(-4, 1, 3), const IVec3(3, 5, 3), hair, 0.06);
    VoxelMeshBuilder.box(v, const IVec3(-4, 2, -3), const IVec3(-4, 5, 3), hair, 0.06);
    VoxelMeshBuilder.box(v, const IVec3(3, 2, -3), const IVec3(3, 5, 3), hair, 0.06);
    v[const IVec3(-4, 5, -4)] = hair; // the fringe falls over the left temple
    v[const IVec3(-3, 5, -4)] = hair;
    v[const IVec3(3, 5, -4)] = hair;
    v[const IVec3(-2, 5, -4)] = hairDark; // brows
    v[const IVec3(1, 5, -4)] = hairDark;
    v[const IVec3(2, 5, -4)] = hairDark;
    v[const IVec3(-3, 4, -4)] = white;
    v[const IVec3(-2, 4, -4)] = iris;
    v[const IVec3(1, 4, -4)] = iris;
    v[const IVec3(2, 4, -4)] = white;
    v[const IVec3(-1, 3, -4)] = nose;
    v[const IVec3(0, 3, -4)] = nose;
    v[const IVec3(-3, 3, -4)] = cheek;
    v[const IVec3(2, 3, -4)] = cheek;
    v[const IVec3(-1, 2, -4)] = mouth;
    v[const IVec3(0, 2, -4)] = mouth;
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
      // The shape is drawn flat in XY (shaft up Y, head across X). A quarter
      // turn about the shaft puts the head in the swing plane, then the shaft
      // tips forward: a pickaxe's points, an axe's blade and a sword's edge
      // lead the chop instead of facing left and right.
      held.rotation = Quaternion.axisAngle(Vector3(1, 0, 0), -math.pi / 2) * Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 2);
    }
    hand.add(held);
    _held = held;
  }

  void swing() {
    _swing = 1.0;
    _handSwing = 1.0;
  }

  // Stage 32: the held item's own 60-degree pivot (120 ms), the hit-stop (the
  // pose holds for 60 ms) and the white hit tint (100 ms).
  double _handSwing = 0.0;
  double _freeze = 0.0;
  double _flash = 0.0;
  static const double handSwingSeconds = 0.12;
  static const double swingSeconds = 0.3; // Minecraft's six ticks
  static UnlitMaterial? _flashMaterial;
  final Map<Object, Material> _saved = {};

  /// Stage 32: the white every model turns for [flash]; one material for all
  /// of them (Godot's unshaded, emissive `flash_material`).
  static UnlitMaterial flashMaterial() => _flashMaterial ??= UnlitMaterial()
    ..baseColorFactor = Vector4(1, 1, 1, 1)
    ..vertexColorWeight = 0.0; // pure white, not the voxel colours unlit

  /// Stage 32: hit-stop. The pose holds for [seconds] (the walk, the swing and
  /// the bob all wait; the body still moves).
  void freeze(double seconds) => _freeze = math.max(_freeze, seconds);
  bool isFrozen() => _freeze > 0.0;

  /// Stage 32: the whole model tints white for [seconds].
  void flash(double seconds) {
    _flash = math.max(_flash, seconds);
    _applyFlash(true);
  }

  bool isFlashing() => _flash > 0.0;

  void _applyFlash(bool on) {
    void walk(Node n) {
      final mesh = n.mesh;
      if (mesh != null) {
        for (final prim in mesh.primitives) {
          if (on) {
            _saved.putIfAbsent(prim, () => prim.material);
            prim.material = flashMaterial();
          } else {
            final m = _saved[prim];
            if (m != null) prim.material = m;
          }
        }
        refreshMeshMaterials(n);
      }
      for (final c in n.children) {
        walk(c);
      }
    }

    walk(root);
    if (!on) _saved.clear();
  }

  void animate(double dt, double speed, bool onFloor, bool gliding, bool climbing) {
    if (_flash > 0.0) {
      _flash -= dt;
      if (_flash <= 0.0) {
        _flash = 0.0;
        _applyFlash(false);
      }
    }
    if (_freeze > 0.0) {
      _freeze -= dt;
      root.rotation = eulerYXZ(tiltX, yaw, 0);
      root.position = Vector3(0, posY, 0);
      return;
    }
    if (_handSwing > 0.0) _handSwing = math.max(_handSwing - dt / handSwingSeconds, 0.0);
    hand.rotation = Quaternion.axisAngle(Vector3(1, 0, 0), -60.0 * math.pi / 180.0 * math.sin(_handSwing * math.pi));
    final moving = speed > 0.5;
    _walkPhase += dt * speed.clamp(0.0, 12.0) * 1.4;
    // The walk and the airborne pose are blended in and out, never switched.
    // Both booleans flicker where the ground is uncertain — a body in shallow
    // water leaves the floor for a frame at a time — and a hard switch made
    // the limbs and the body bob flutter at the frame rate.
    _moveWeight = lerpd(_moveWeight, moving ? 1.0 : 0.0, dt * 9.0);
    _airWeight = lerpd(_airWeight, (!onFloor && !climbing) ? 1.0 : 0.0, dt * 9.0);
    final walkA = math.sin(_walkPhase) * 0.65 * _moveWeight;
    final a = walkA + (0.35 - walkA) * _airWeight;
    legL.rx = a;
    legR.rx = -a;
    armL.rx = -a * 0.8;
    var swingAngle = 0.0;
    if (_swing > 0.0) {
      // Minecraft's HumanoidModel attack: the arm rises forward and chops down
      // in front of the body, ease-out, straight in the swing plane (a roll
      // toward the chest sinks the hand into the torso). A positive rx carries
      // the hand forward (-Z).
      _swing = math.max(_swing - dt / swingSeconds, 0.0);
      final t = 1.0 - _swing;
      final eased = 1.0 - math.pow(1.0 - t, 4.0);
      swingAngle = math.sin(eased * math.pi) * 1.2 + math.sin(t * math.pi) * 0.5;
    }
    armR.rx = a * 0.8 + swingAngle;
    // A positive rz carries a hanging hand to +X: outward for the right arm,
    // inward for the left. Every pose keeps the hands away from the torso.
    if (gliding) {
      armL.rz = -1.4;
      armR.rz = 1.4;
      legL.rx = 0.0;
      legR.rx = 0.0;
    } else if (climbing) {
      armL.rz = -0.3;
      armR.rz = 0.3;
      armL.rx = 2.6 + a;
      armR.rx = 2.6 - a;
    } else {
      armL.rz = lerpd(armL.rz, 0.0, dt * 10.0); // straight down, parallel to the torso
      armR.rz = lerpd(armR.rz, 0.0, dt * 10.0);
    }
    _bob = math.sin(_walkPhase).abs() * 0.03 * _moveWeight * (1.0 - _airWeight);
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
