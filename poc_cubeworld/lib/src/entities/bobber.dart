import 'dart:math' as math;

import 'package:flutter_scene/scene.dart' hide Spawner;
import 'package:vector_math/vector_math.dart';

import '../core/ivec3.dart';
import '../game/sfx.dart';
import '../player/player.dart';
import '../world/voxel_world.dart';

/// A fishing bobber: flies from the rod hand to the water cell it was cast at,
/// floats there, and after a random wait dips for a short bite window. The line
/// is a thin box stretched from the player's hand to the bobber every frame,
/// because a line geometry here is built once and cannot be rewritten cheaply.
class Bobber {
  Bobber(this.world, this.player, Vector3 from, IVec3 cell) {
    _start = from.clone();
    position = from.clone();
    target = cell.toVector3() + Vector3(0.5, 0.85, 0.5);
    _wait = 3.0 + player.main.random.nextDouble() * 5.0;

    final float = Node(
      mesh: Mesh(SphereGeometry(radius: 0.11),
          UnlitMaterial()..baseColorFactor = Vector4(0.90, 0.20, 0.15, 1)),
    );
    final cap = Node(
      mesh: Mesh(SphereGeometry(radius: 0.06),
          UnlitMaterial()..baseColorFactor = Vector4(0.95, 0.95, 0.92, 1)),
    )..position = Vector3(0, 0.12, 0);
    node.add(float);
    node.add(cap);
    _line = Node(
      mesh: Mesh(CuboidGeometry(Vector3(0.012, 0.012, 1.0)),
          UnlitMaterial()..baseColorFactor = Vector4(0.12, 0.12, 0.12, 1)),
    )..castsShadows = false;
  }

  static const double biteWindow = 1.5;

  final VoxelWorld world;
  final Player player;
  final Node node = Node(name: 'Bobber');
  late final Node _line;
  Vector3 position = Vector3.zero();
  late final Vector3 target;
  bool landed = false;
  double biteLeft = 0.0;
  bool removed = false;
  late final Vector3 _start;
  double _flight = 0.0;
  double _wait = 5.0;
  double _phase = 0.0;

  /// The line lives beside the bobber, not under it, so it is not dragged by
  /// the bobber's own bobbing.
  Node get lineNode => _line;

  bool get isBiting => biteLeft > 0.0;

  /// The fish tugs: the bobber dips, a splash, and the player has [biteWindow]
  /// seconds to react.
  void bite() {
    biteLeft = biteWindow;
    _wait = 3.0 + player.main.random.nextDouble() * 5.0;
    Sfx.play('splash', -6.0);
    player.notify('Something bites!');
  }

  /// Probe hook: land at once and start a bite this frame.
  void forceBite() {
    landed = true;
    _flight = 1.0;
    position = target.clone();
    bite();
  }

  void update(double dt) {
    if (!landed) {
      _flight = math.min(_flight + dt * 2.2, 1.0);
      final p = _start + (target - _start) * _flight;
      p.y += math.sin(_flight * math.pi) * 1.4;
      position = p;
      if (_flight >= 1.0) {
        landed = true;
        Sfx.play('splash', -14.0);
      }
    } else {
      _phase += dt;
      var dip = 0.0;
      if (biteLeft > 0.0) {
        biteLeft -= dt;
        dip = -0.22;
      } else {
        _wait -= dt;
        if (_wait <= 0.0) bite();
      }
      final wanted = target.y + math.sin(_phase * 3.0) * 0.04 + dip;
      position.y = position.y + (wanted - position.y) * (dt * 12.0).clamp(0.0, 1.0);
    }
    node.position = position;
    _stretchLine();
  }

  void _stretchLine() {
    final hand = player.model.handWorldPosition();
    final delta = position + Vector3(0, 0.12, 0) - hand;
    final length = delta.length;
    if (length < 1e-4) {
      _line.visible = false;
      return;
    }
    _line.visible = true;
    _line.position = hand + delta * 0.5;
    _line.scale = Vector3(1, 1, length);
    // The unit box points along -Z; aim it down the line.
    final dir = delta / length;
    final axis = Vector3(0, 0, -1).cross(dir);
    final dot = Vector3(0, 0, -1).dot(dir);
    if (axis.length2 < 1e-8) {
      _line.rotation = dot > 0 ? Quaternion.identity() : Quaternion.axisAngle(Vector3(0, 1, 0), math.pi);
    } else {
      _line.rotation = Quaternion.axisAngle(axis.normalized(), math.acos(dot.clamp(-1.0, 1.0)));
    }
  }
}
