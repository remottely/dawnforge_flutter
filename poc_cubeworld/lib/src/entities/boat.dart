import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

import '../core/ivec3.dart';
import '../game/game.dart';
import '../player/player.dart';
import '../world/voxel_world.dart';
import 'voxel_body.dart';
import 'voxel_mesh_builder.dart';

/// A rowing boat: floats on liquid, driven by whoever sits in it (F to board /
/// leave).
class Boat extends VoxelBody {
  Player? driver;
  double throttle = 0.0;
  double steer = 0.0;
  double yaw = 0.0;
  late Game main;
  final Node _hull = Node();
  double _roll = 0.0;
  double _time = 0.0;

  void setupBoat(VoxelWorld w, Game m, Vector3 at, double heading) {
    setup(w, 0.55, 0.5);
    main = m;
    position = at.clone();
    yaw = heading;
    final v = <IVec3, Vector3>{};
    final wood = Vector3(0.55, 0.38, 0.20);
    final dark = Vector3(0.40, 0.27, 0.14);
    VoxelMeshBuilder.box(v, const IVec3(-4, 0, -7), const IVec3(4, 0, 7), dark);
    VoxelMeshBuilder.box(v, const IVec3(-5, 1, -8), const IVec3(-4, 3, 8), wood);
    VoxelMeshBuilder.box(v, const IVec3(4, 1, -8), const IVec3(5, 3, 8), wood);
    VoxelMeshBuilder.box(v, const IVec3(-4, 1, -9), const IVec3(4, 3, -8), wood);
    VoxelMeshBuilder.box(v, const IVec3(-4, 1, 8), const IVec3(4, 3, 9), wood);
    VoxelMeshBuilder.box(v, const IVec3(-4, 1, -1), const IVec3(4, 1, 1), dark);
    _hull.add(VoxelMeshBuilder.meshNode(v, 0.1, Vector3(0.5, 0, 0.5)));
    node.add(_hull);
    syncNode();
  }

  void update(double dt) {
    _time += dt;
    final feet = IVec3(position.x.floor(), (position.y + 0.15).floor(), position.z.floor());
    if (world.isLiquid(feet)) {
      velocity.y = lerpd(velocity.y, 1.6, dt * 5.0);
    } else if (inWater) {
      velocity.y = lerpd(velocity.y, 0.0, dt * 6.0);
    } else {
      applyGravity(dt);
    }
    if (driver != null) {
      yaw += steer * -1.7 * dt;
      final fwd = Vector3(-math.sin(yaw), 0, -math.cos(yaw));
      final target = fwd * throttle * (inWater ? 6.5 : 1.5);
      velocity.x = lerpd(velocity.x, target.x, dt * 2.5);
      velocity.z = lerpd(velocity.z, target.z, dt * 2.5);
    } else {
      velocity.x = lerpd(velocity.x, 0.0, dt * 1.5);
      velocity.z = lerpd(velocity.z, 0.0, dt * 1.5);
    }
    move(dt);
    syncNode();
    _roll = lerpd(_roll, -steer * 0.12 * throttle, dt * 4.0);
    _hull.rotation = eulerYXZ(0, yaw, _roll);
    _hull.position = Vector3(0, inWater ? math.sin(_time * 2.0 + position.x) * 0.03 : 0.0, 0);
  }

  Vector3 seat() => position + Vector3(0, 0.35, 0);
}
