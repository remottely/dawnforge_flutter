import 'package:vector_math/vector_math.dart';

/// An integer block position (Godot's Vector3i).
class IVec3 {
  const IVec3(this.x, this.y, this.z);

  factory IVec3.floor(Vector3 v) => IVec3(v.x.floor(), v.y.floor(), v.z.floor());

  final int x, y, z;

  static const zero = IVec3(0, 0, 0);
  static const up = IVec3(0, 1, 0);
  static const down = IVec3(0, -1, 0);
  static const left = IVec3(-1, 0, 0);
  static const right = IVec3(1, 0, 0);
  static const forward = IVec3(0, 0, -1);
  static const back = IVec3(0, 0, 1);
  static const sides = [left, right, forward, back];

  IVec3 operator +(IVec3 o) => IVec3(x + o.x, y + o.y, z + o.z);
  IVec3 operator -(IVec3 o) => IVec3(x - o.x, y - o.y, z - o.z);

  /// Stage 29: Godot's `Vector3i * int` and `Vector3i.length()`.
  IVec3 operator *(int k) => IVec3(x * k, y * k, z * k);
  double get length => toVector3().length;

  Vector3 toVector3() => Vector3(x.toDouble(), y.toDouble(), z.toDouble());
  Vector3 get centre => Vector3(x + 0.5, y + 0.5, z + 0.5);

  double distanceTo(Vector3 v) => (v - toVector3()).length;

  String get key => '$x,$y,$z';

  static IVec3? parse(String s) {
    final p = s.split(',');
    if (p.length != 3) return null;
    return IVec3(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  @override
  bool operator ==(Object other) => other is IVec3 && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => '($x, $y, $z)';
}
