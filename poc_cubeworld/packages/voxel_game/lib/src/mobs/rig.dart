import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';
import 'package:voxel_core/voxel_core.dart';
import 'package:voxel_scene/voxel_scene.dart';

/// The body plans of the stock rigs.
enum RigKind {
  /// Two legs, two arms, a head: a zombie, a villager, the player.
  humanoid,

  /// Four legs, a barrel, a head and a tail: a cow, a horse, a wolf.
  quadruped,

  /// One squashy block: a slime.
  blob,

  /// A body and eight legs.
  spider,

  /// A body, a head, two wings and two legs: a chicken, a parrot.
  bird,
}

Vector3 _rgb(int c) => Vector3(((c >> 16) & 0xFF) / 255.0, ((c >> 8) & 0xFF) / 255.0, (c & 0xFF) / 255.0);

/// A creature's look, declared: one of the stock body plans in its colours.
/// It is fitted to the creature's collider when built.
class Rig {
  /// A humanoid in [skin], [shirt] and [pants]; [armsForward] holds the arms
  /// out in front (the walk everyone reads as a zombie); [redEyes] for the
  /// hostile.
  const Rig.humanoid({this._skin = 0xE8B890, this._shirt = 0x3A6EA5, this._pants = 0x3C4F80, this.armsForward = false, this.redEyes = false})
      : kind = RigKind.humanoid,
        colors = const [];

  /// A four-legged animal: a [body] colour and a [head] (and legs) colour.
  const Rig.quadruped({int body = 0x8A6A4A, int? head})
      : kind = RigKind.quadruped,
        colors = const [],
        armsForward = false,
        redEyes = false,
        _skin = body,
        _shirt = head ?? body,
        _pants = 0;

  /// A slime.
  const Rig.blob({int color = 0x6CC24A})
      : kind = RigKind.blob,
        colors = const [],
        armsForward = false,
        redEyes = false,
        _skin = color,
        _shirt = color,
        _pants = 0;

  /// A spider: a [body] and its [eyes].
  const Rig.spider({int body = 0x3A3030, int eyes = 0xD02020})
      : kind = RigKind.spider,
        colors = const [],
        armsForward = false,
        redEyes = false,
        _skin = body,
        _shirt = eyes,
        _pants = 0;

  /// A bird: a [body] and its [feathers] (wing tips, tail, comb).
  const Rig.bird({int body = 0xF0F0F0, int feathers = 0xD03030})
      : kind = RigKind.bird,
        colors = const [],
        armsForward = false,
        redEyes = false,
        _skin = body,
        _shirt = feathers,
        _pants = 0;

  /// The body plan.
  final RigKind kind;

  /// Reserved for rigs with more colours.
  final List<int> colors;

  /// Humanoid arms held out in front.
  final bool armsForward;

  /// Red eyes.
  final bool redEyes;

  final int _skin, _shirt, _pants;

  /// Builds this rig for a collider [halfWidth] wide and [height] tall.
  RigInstance build(double halfWidth, double height) => RigInstance._(this, halfWidth, height);
}

/// A built [Rig]: scene nodes posed every frame by [animate], placed by
/// [place].
class RigInstance {
  RigInstance._(this.rig, this.halfWidth, this.height) {
    _build();
  }

  /// What was built.
  final Rig rig;

  /// The collider it was fitted to.
  final double halfWidth, height;

  /// The node to add to the scene; [place] moves it.
  final Node root = Node();

  /// The posable parts by name (`body`, `head`, `leg0`.., `arm0`, `arm1`,
  /// `wing0`, `wing1`, `tail`).
  final Map<String, RigPart> parts = {};

  final List<double> _legFan = [];
  double _fit = 1.0;
  double _yaw = 0.0;
  double _phase = 0.0, _moveWeight = 0.0, _age = 0.0;
  double _wingPhase = 0.0, _wingWeight = 0.0;
  double _swing = 0.0, _squash = 1.0, _landSquash = 0.0;
  bool _wasOnFloor = true;

  /// The yaw the model faces, eased toward what [animate] is told.
  double get yaw => _yaw;

  /// The saddle line of a quadruped (metres above the feet), 0 otherwise.
  double backHeight = 0.0;

  RigPart _part(Map<IVec3, Vector3> voxels, Vector3 at, double s, {bool narrow = false}) {
    final pivot = Node();
    final lo = Vector3.all(double.infinity), hi = Vector3.all(double.negativeInfinity);
    for (final k in voxels.keys) {
      final v = Vector3(k.x.toDouble(), k.y.toDouble(), k.z.toDouble());
      Vector3.min(lo, v, lo);
      Vector3.max(hi, v + Vector3.all(1.0), hi);
    }
    final origin = Vector3.zero();
    final base = at.clone();
    final shrink = Vector3.all(1.0);
    if (narrow) {
      origin
        ..x = (lo.x + hi.x) * 0.5
        ..z = (lo.z + hi.z) * 0.5;
      base
        ..x += origin.x * s
        ..z += origin.z * s;
      shrink
        ..x = 1.0 - 0.02 / ((hi.x - lo.x) * s)
        ..z = 1.0 - 0.02 / ((hi.z - lo.z) * s);
    }
    pivot.add(VoxelModelMesh.node(voxels, s, origin)..scale = shrink);
    root.add(pivot);
    _top = math.max(_top, at.y + (hi.y - origin.y) * s);
    return RigPart(pivot, base);
  }

  double _top = 0.0;

  void _build() {
    final skin = _rgb(rig._skin), shirt = _rgb(rig._shirt), pants = _rgb(rig._pants);
    final dark = Vector3(0.05, 0.05, 0.05);
    final s = rig.kind == RigKind.humanoid ? 0.055 * (height / 1.75) : 0.06;
    switch (rig.kind) {
      case RigKind.quadruped:
        final bodyLen = (height * 14).toInt(), bodyH = (height * 7).toInt(), bodyW = (halfWidth * 22).toInt();
        final legH = (height * 6).toInt();
        var v = <IVec3, Vector3>{};
        VoxelModel.box(v, IVec3(-bodyW ~/ 2, 0, -bodyLen ~/ 2), IVec3(bodyW ~/ 2, bodyH, bodyLen ~/ 2), skin);
        parts['body'] = _part(v, Vector3(0, legH * s, 0), s);
        backHeight = (legH + bodyH) * s;
        v = {};
        final hs = (bodyW * 0.7).toInt();
        VoxelModel.box(v, IVec3(-hs ~/ 2, -hs ~/ 2, -hs), IVec3(hs ~/ 2, hs ~/ 2, 0), shirt);
        v[IVec3(-hs ~/ 2 + 1, 0, -hs)] = dark;
        v[IVec3(hs ~/ 2 - 1, 0, -hs)] = dark;
        parts['head'] = _part(v, Vector3(0, (legH + bodyH * 0.8) * s, -bodyLen / 2 * s), s);
        for (var i = 0; i < 4; i++) {
          v = {};
          VoxelModel.box(v, IVec3(-1, -legH, -1), const IVec3(1, 0, 1), shirt);
          final lx = (bodyW / 2 - 1.5) * s * (i % 2 == 0 ? 1 : -1);
          final lz = (bodyLen / 2 - 2) * s * (i < 2 ? 1 : -1);
          parts['leg$i'] = _part(v, Vector3(lx, legH * s, lz), s, narrow: true);
        }
        v = {};
        final tailLen = math.max(bodyLen ~/ 3, 3);
        VoxelModel.box(v, IVec3(-1, -tailLen, 0), const IVec3(0, 0, 1), shirt);
        parts['tail'] = _part(v, Vector3(0, (legH + bodyH * 0.85) * s, (bodyLen ~/ 2 + 1) * s + 0.01), s);
      case RigKind.humanoid:
        final k = height / 1.75;
        var v = <IVec3, Vector3>{};
        VoxelModel.box(v, const IVec3(-2, -12, -2), const IVec3(1, -1, 1), pants);
        parts['leg0'] = _part(v, Vector3(-0.11 * k, 0.66 * k, 0), s);
        parts['leg1'] = _part(v, Vector3(0.11 * k, 0.66 * k, 0), s);
        v = {};
        VoxelModel.box(v, const IVec3(-4, 0, -2), const IVec3(3, 11, 1), shirt);
        parts['body'] = _part(v, Vector3(0, 0.66 * k, 0), s);
        v = {};
        VoxelModel.box(v, const IVec3(-2, -12, -2), const IVec3(1, -1, 1), skin);
        parts['arm0'] = _part(v, Vector3(-0.345 * k, 1.30 * k, 0), s);
        parts['arm1'] = _part(v, Vector3(0.345 * k, 1.30 * k, 0), s);
        v = {};
        VoxelModel.box(v, const IVec3(-4, 0, -4), const IVec3(3, 7, 3), skin, 0.04);
        final eye = rig.redEyes ? Vector3(0.9, 0.1, 0.1) : dark;
        v[const IVec3(-3, 4, -4)] = eye;
        v[const IVec3(2, 4, -4)] = eye;
        parts['head'] = _part(v, Vector3(0, 1.32 * k, 0), s);
      case RigKind.blob:
        final v = <IVec3, Vector3>{};
        final r = (halfWidth * 16).toInt(), h = (height * 14).toInt();
        VoxelModel.box(v, IVec3(-r, 0, -r), IVec3(r, h, r), skin, 0.08);
        for (var x = -r; x <= r; x++) {
          for (var z = -r; z <= r; z++) {
            if (x.abs() == r || z.abs() == r) v.remove(IVec3(x, h, z));
            if (x.abs() == r && z.abs() == r) v.remove(IVec3(x, 0, z));
          }
        }
        v[IVec3(-r ~/ 2, h * 2 ~/ 3, -r)] = dark;
        v[IVec3(r ~/ 2, h * 2 ~/ 3, -r)] = dark;
        parts['body'] = _part(v, Vector3.zero(), s);
      case RigKind.spider:
        var v = <IVec3, Vector3>{};
        VoxelModel.box(v, const IVec3(-4, 0, -3), const IVec3(4, 4, 5), skin, 0.06);
        VoxelModel.box(v, const IVec3(-3, 0, -7), const IVec3(3, 3, -3), skin * 0.9, 0.06);
        for (final e in const [IVec3(-2, 3, -7), IVec3(2, 3, -7), IVec3(-1, 2, -7), IVec3(1, 2, -7)]) {
          v[e] = shirt;
        }
        parts['body'] = _part(v, Vector3(0, 0.35, 0), s);
        for (var i = 0; i < 8; i++) {
          v = {};
          final side = i % 2 == 0 ? 1 : -1;
          VoxelModel.box(v, IVec3.zero, const IVec3(5, 0, 0), skin);
          VoxelModel.box(v, const IVec3(5, -5, 0), const IVec3(5, 0, 0), skin);
          final leg = _part(v, Vector3(side * 0.25, 0.42, (i ~/ 2 - 1.5) * 0.18), s);
          leg.sx = side.toDouble();
          final fan = (i ~/ 2 - 1.5) * 0.3 * side;
          leg.ry = fan;
          _legFan.add(fan);
          parts['leg$i'] = leg;
        }
      case RigKind.bird:
        var v = <IVec3, Vector3>{};
        final beak = Vector3(0.95, 0.7, 0.2);
        VoxelModel.box(v, const IVec3(-2, 0, -3), const IVec3(2, 4, 3), skin);
        parts['body'] = _part(v, Vector3(0, 0.25, 0), s);
        v = {};
        VoxelModel.box(v, const IVec3(-1, 0, -2), const IVec3(1, 3, 1), skin);
        VoxelModel.box(v, const IVec3(0, 1, -3), const IVec3(0, 1, -3), beak);
        VoxelModel.box(v, const IVec3(0, 3, -1), const IVec3(0, 4, -1), shirt);
        parts['head'] = _part(v, Vector3(0, 0.5, -0.18), s);
        final wing = <IVec3, Vector3>{};
        VoxelModel.box(wing, const IVec3(0, 0, -2), const IVec3(3, 0, 2), skin);
        VoxelModel.box(wing, const IVec3(4, 0, -1), const IVec3(5, 0, 2), shirt);
        VoxelModel.box(wing, const IVec3(6, 0, 0), const IVec3(7, 0, 2), shirt);
        parts['wing1'] = _part(wing, Vector3(0.18, 0.44, 0.0), s);
        parts['wing0'] = _part(VoxelModel.mirrorX(wing), Vector3(-0.12, 0.44, 0.0), s);
        v = {};
        VoxelModel.box(v, const IVec3(-1, 0, 0), const IVec3(1, 0, 3), shirt);
        parts['tail'] = _part(v, Vector3(0, 0.38, 0.22), s);
        for (var i = 0; i < 2; i++) {
          v = {};
          VoxelModel.box(v, const IVec3(0, -4, 0), IVec3.zero, beak);
          parts['leg$i'] = _part(v, Vector3((i - 0.5) * 0.12, 0.25, 0), s);
        }
    }
    final rest = _armRest;
    parts['arm0']?.rx = rest;
    parts['arm1']?.rx = rest;
    for (final p in parts.values) {
      p.apply();
    }
    // A body authored at a fixed size is shrunk into its collider, never left
    // poking out of the box the crosshair and the walls see.
    _fit = _top > height ? height / _top : 1.0;
  }

  double get _armRest => rig.armsForward ? 1.4 : 0.0;

  double get _gaitRate => switch (rig.kind) {
        RigKind.bird => 4.2,
        RigKind.spider => 3.0,
        RigKind.quadruped => 2.6,
        _ => 2.2,
      };

  /// Starts an attack swing (a humanoid's arm, a bird's peck).
  void swing() => _swing = 1.0;

  /// Poses the rig for one frame of [dt]: moving at [speed] metres a second,
  /// facing [targetYaw], standing [onFloor] or [flying]; [lookYaw] turns the
  /// head toward something (relative to the body), null for straight ahead.
  void animate(double dt, {required double speed, required double targetYaw, bool onFloor = true, bool flying = false, double? lookYaw, double verticalSpeed = 0.0}) {
    _age += dt;
    _yaw = lerpAngle(_yaw, targetYaw, math.min(1.0, dt * 12.0));
    _moveWeight = lerpd(_moveWeight, speed > 0.3 ? 1.0 : 0.0, math.min(1.0, dt * 8.0));
    _phase += dt * speed * _gaitRate;
    final a = math.sin(_phase) * 0.7 * _moveWeight;
    final head = parts['head'];
    if (head != null) head.ry = lerpAngle(head.ry, (lookYaw ?? 0.0).clamp(-1.2, 1.2), math.min(1.0, dt * 5.0));
    // Wings beat in the air, fold on the ground.
    final left = parts['wing0'], right = parts['wing1'];
    if (left != null && right != null) {
      _wingWeight = lerpd(_wingWeight, flying || !onFloor ? 1.0 : 0.0, math.min(1.0, dt * 8.0));
      if (_wingWeight > 0.001) _wingPhase = (_wingPhase + dt * 22.0) % (math.pi * 2);
      final angle = lerpd(-0.15, math.sin(_wingPhase) * 0.9, _wingWeight);
      final twist = math.cos(_wingPhase) * 0.3 * _wingWeight;
      final span = lerpd(0.55, 1.0, _wingWeight);
      left
        ..rz = -angle
        ..rx = twist
        ..sx = span;
      right
        ..rz = angle
        ..rx = twist
        ..sx = span;
    }
    for (var i = 0; i < 8; i++) {
      final p = parts['leg$i'];
      if (p == null) continue;
      if (rig.kind == RigKind.spider) {
        final side = i % 2 == 0 ? 1.0 : -1.0;
        final group = ((i % 2) ^ ((i ~/ 2) % 2)) == 0 ? 1.0 : -1.0;
        p.rz = math.sin(_phase) * 0.3 * group * _moveWeight + math.sin(_age * 1.7 + i) * 0.05;
        p.ry = _legFan[i] + math.cos(_phase) * 0.3 * group * side * _moveWeight;
      } else {
        final swing = ((i % 2 == 0) == (i < 2)) ? a : -a;
        p.rx = rig.kind == RigKind.bird ? lerpd(swing, 0.9, _wingWeight) : swing;
      }
    }
    final tail = parts['tail'];
    if (tail != null) {
      tail.ry = math.sin(_age * 1.6) * 0.18 + a * 0.35;
      tail.rx = -0.5 * _wingWeight + math.cos(_phase) * 0.12 * _moveWeight;
    }
    _swing = math.max(_swing - dt / 0.35, 0.0);
    switch (rig.kind) {
      case RigKind.quadruped:
        final lift = math.sin(_phase * 2.0) * 0.02 * _moveWeight;
        parts['body']
          ?..offY = lift
          ..rx = -a * 0.06;
        head
          ?..offY = lift * 0.8
          ..rx = math.sin(_phase * 2.0 + 0.7) * 0.10 * _moveWeight - _swing * 0.4;
      case RigKind.humanoid:
        final reach = _armRest == 0.0 ? 0.8 : 0.3;
        final chop = math.sin((1.0 - _swing) * math.pi) * 1.3 * (_swing > 0.0 ? 1.0 : 0.0);
        parts['arm0']?.rx = _armRest - a * reach + chop;
        parts['arm1']?.rx = _armRest + a * reach;
        final bob = math.sin(_phase).abs() * 0.02 * _moveWeight;
        parts['body']
          ?..ry = -a * 0.12
          ..offY = bob;
        head?.offY = bob;
      case RigKind.blob:
        if (onFloor && !_wasOnFloor) _landSquash = 0.35;
        _landSquash = math.max(_landSquash - dt / 0.2, 0.0);
        final rise = onFloor ? 0.0 : (verticalSpeed * 0.02).clamp(-0.12, 0.18);
        _squash = 1.0 + math.sin(_age * 6.0) * 0.05 + rise - _landSquash;
      case RigKind.bird:
        head
          ?..offZ = -math.sin(_phase * 2.0) * 0.035 * _moveWeight
          ..rx = math.cos(_phase * 2.0) * 0.12 * _moveWeight + _swing * 0.6;
        parts['body']?.rx = -0.15 * _wingWeight + math.sin(_phase * 2.0) * 0.05 * _moveWeight;
      case RigKind.spider:
        break;
    }
    _wasOnFloor = onFloor;
    for (final p in parts.values) {
      p.apply();
    }
  }

  /// Puts the model at the feet [position], [scale] times its fitted size,
  /// toppled by [topple] radians (a death) and shaken sideways by [shake].
  void place(Vector3 position, {double scale = 1.0, double topple = 0.0, double shake = 0.0}) {
    root.rotation = topple == 0.0 ? Quaternion.axisAngle(Vector3(0, 1, 0), _yaw) : eulerYXZ(topple, _yaw, 0);
    final ms = scale * _fit;
    final sq = rig.kind == RigKind.blob ? _squash : 1.0;
    root.scale = Vector3(ms / math.sqrt(sq), ms * sq, ms / math.sqrt(sq));
    root.position = position + Vector3(shake, 0, 0);
  }
}
