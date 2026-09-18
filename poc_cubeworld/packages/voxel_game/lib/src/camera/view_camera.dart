import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';
import 'package:voxel_core/voxel_core.dart';
import 'package:voxel_scene/voxel_scene.dart';

import '../core/voxel_game.dart';
import '../player/player_spec.dart';

/// The player's camera: the eye in first person, a shoulder orbit in third
/// person that is pulled in by walls, and Minecraft's small view bob on foot.
class ViewCamera {
  /// How far behind the orbit sits, unobstructed.
  double orbitDistance = 4.8;

  /// How far right of the head.
  double orbitShoulder = 0.55;

  /// How far above.
  double orbitRise = 0.15;

  /// The half-size of the box the eye occupies.
  static const double eyeRadius = 0.25;

  /// How far the eye drops at the bottom of a full-speed step.
  double bobAmplitude = 0.05;

  /// Whether the view bobs.
  bool bob = true;

  double _distance = 4.8;
  double _bobPhase = 0.0, _bobWeight = 0.0;
  double _lastTime = -1.0;
  final math.Random _jolt = math.Random(7);

  /// The eye's offset from the pivot at orbit distance [dist]: shoulder and
  /// rise grow with the distance, so the segment pivot→eye is straight and can
  /// be swept.
  Vector3 orbitOffset(Vector3 right, Vector3 up, Vector3 back, double dist) {
    final t = dist / orbitDistance;
    return right * (orbitShoulder * t) + up * (orbitRise * t) + back * dist;
  }

  /// The furthest a box of [eyeRadius] slides along [eyeAt] from 0 to
  /// [wanted] with every cell it touches accepted by [cellIsClear], marched
  /// outward: an air pocket behind a wall is not room.
  static double clearDistance(double wanted, Vector3 Function(double distance) eyeAt, bool Function(int x, int y, int z) cellIsClear) {
    const step = eyeRadius * 0.5;
    var clear = 0.0;
    while (clear < wanted) {
      final next = math.min(clear + step, wanted);
      if (!boxIsClear(eyeAt(next), eyeRadius, cellIsClear)) return clear;
      clear = next;
    }
    return wanted;
  }

  /// Whether every cell a box of half-size [radius] at [at] touches is clear.
  static bool boxIsClear(Vector3 at, double radius, bool Function(int x, int y, int z) cellIsClear) {
    for (var y = (at.y - radius).floor(); y <= (at.y + radius).floor(); y++) {
      for (var z = (at.z - radius).floor(); z <= (at.z + radius).floor(); z++) {
        for (var x = (at.x - radius).floor(); x <= (at.x + radius).floor(); x++) {
          if (!cellIsClear(x, y, z)) return false;
        }
      }
    }
    return true;
  }

  /// This frame's camera for [game]'s player.
  Camera camera(VoxelGame game) {
    final p = game.player;
    final dt = _lastTime < 0 ? 0.0 : math.max(0.0, game.time - _lastTime);
    _lastTime = game.time;
    final yaw = p.yaw, pitch = p.pitch;
    final fwd = p.forward;
    final right = Vector3(math.cos(yaw), 0, -math.sin(yaw));
    final up = Vector3(math.sin(pitch) * math.sin(yaw), math.cos(pitch), math.sin(pitch) * math.cos(yaw));
    // The bob: advanced by distance, eased in and out.
    final speed = math.sqrt(p.velocity.x * p.velocity.x + p.velocity.z * p.velocity.z);
    final walking = bob && p.onFloor && speed > 0.6;
    _bobWeight = lerpd(_bobWeight, walking ? (speed / p.spec.walkSpeed).clamp(0.0, 1.7) : 0.0, math.min(1.0, dt * 9.0));
    if (walking) _bobPhase = (_bobPhase + speed * dt * 1.9) % (math.pi * 2);
    final amp = _bobWeight * bobAmplitude;
    var sway = right * (math.sin(_bobPhase) * amp * 0.16) - up * (math.cos(_bobPhase).abs() * amp);
    // A hit jolts the eye (never the aim) and dies out.
    if (p.hurtFlash > 0.0) {
      final k = 0.08 * p.hurtFlash;
      sway += right * ((_jolt.nextDouble() * 2 - 1) * k) + up * ((_jolt.nextDouble() * 2 - 1) * k);
    }
    final Vector3 eye;
    if (p.cameraMode == CameraMode.firstPerson) {
      eye = p.eyePosition + sway;
    } else {
      final pivot = p.position + Vector3(0, 1.5, 0);
      final back = -fwd;
      final world = game.world;
      bool clearCell(int x, int y, int z) {
        if (y < 0) return false;
        final b = world.getBlockXYZ(x, y, z);
        return !(world.table.isOpaque(b) || world.table.isSolid(b));
      }

      final clear = clearDistance(orbitDistance, (d) => pivot + orbitOffset(right, up, back, d) + sway, clearCell);
      // In at once, out gently: an eye eased into place is an eye inside the
      // wall for the length of the ease.
      _distance = clear < _distance ? clear : lerpd(_distance, clear, math.min(1.0, dt * 6.0));
      eye = pivot + orbitOffset(right, up, back, _distance) + sway;
    }
    return MirroredCamera(
      position: eye,
      target: eye + fwd,
      up: up,
      fovRadiansY: p.spec.fov * math.pi / 180.0,
      fovNear: 0.05,
      fovFar: 800.0,
    );
  }
}
