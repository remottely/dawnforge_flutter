import 'dart:math' as math;

import 'package:meta/meta.dart';

/// Engine-agnostic spatial value types. `lib/src/core/` below the rendering layer
/// never imports Flame; these two types are the currency of grid and world math.
/// The Flame boundary (FP3) converts to/from `Vector2` at the edge.

/// An integer grid coordinate (a tile address).
@immutable
final class GridPos {
  const GridPos(this.x, this.y);

  final int x;
  final int y;

  GridPos operator +(GridPos other) => GridPos(x + other.x, y + other.y);
  GridPos operator -(GridPos other) => GridPos(x - other.x, y - other.y);

  /// Chebyshev distance — tiles reachable in N king-moves.
  int chebyshevDistanceTo(GridPos other) =>
      math.max((x - other.x).abs(), (y - other.y).abs());

  @override
  bool operator ==(Object other) =>
      other is GridPos && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'GridPos($x, $y)';
}

/// A continuous world-space position or 2D vector, in world units — the
/// engine's `Vector2`. The Flame boundary (FP3) converts at the edge.
@immutable
final class WorldPos {
  const WorldPos(this.x, this.y);

  static const zero = WorldPos(0, 0);

  /// The default look vector (+X).
  static const right = WorldPos(1, 0);

  final double x;
  final double y;

  WorldPos operator +(WorldPos other) => WorldPos(x + other.x, y + other.y);
  WorldPos operator -(WorldPos other) => WorldPos(x - other.x, y - other.y);
  WorldPos operator *(double scalar) => WorldPos(x * scalar, y * scalar);

  double dot(WorldPos other) => x * other.x + y * other.y;

  double get lengthSquared => x * x + y * y;
  double get length => math.sqrt(lengthSquared);

  /// The unit vector, or [zero] for the zero vector (same contract as Godot's
  /// `normalized()`).
  WorldPos normalized() {
    final len = length;
    return len == 0 ? zero : WorldPos(x / len, y / len);
  }

  /// This vector stepped toward [target] by at most [maxDelta] — Godot's
  /// `move_toward`, the primitive under acceleration and friction.
  WorldPos moveToward(WorldPos target, double maxDelta) {
    final delta = target - this;
    final distance = delta.length;
    if (distance <= maxDelta || distance == 0) return target;
    return this + delta * (maxDelta / distance);
  }

  double distanceTo(WorldPos other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) =>
      other is WorldPos && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'WorldPos($x, $y)';
}
