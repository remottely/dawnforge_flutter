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

/// An axis-aligned rectangle in WORLD units — the Dart twin of the `Rect2`
/// the spec's occupancy rules are written in.
///
/// It exists because those rules are about AREAS, not tiles: an actor's
/// collider straddles the neighbouring tile long before its position crosses
/// into it, and a 3×2 prop appearing around somebody traps them just as well
/// as one appearing on them. A tile-vs-tile comparison answers neither, and
/// answering them tile-wise is precisely the shortcut the spec's header
/// records as having sealed a player inside a mountain.
final class WorldRect {
  const WorldRect(this.left, this.top, this.width, this.height)
      : assert(width > 0, '[WorldRect] width must be positive'),
        assert(height > 0, '[WorldRect] height must be positive');

  /// The square of side `2 * halfExtent` centred on [centre] — an actor's
  /// body, built from the same half-extent the collision step resolves with,
  /// so what stops you and what counts you as standing somewhere are one
  /// footprint rather than two that drift.
  factory WorldRect.centred(WorldPos centre, double halfExtent) => WorldRect(
        centre.x - halfExtent,
        centre.y - halfExtent,
        halfExtent * 2,
        halfExtent * 2,
      );

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  /// Whether the two rectangles share any area. Touching edges do NOT
  /// intersect: a prop whose footprint ends exactly where an actor's body
  /// begins is beside it, not under it, and refusing that placement would
  /// make the tile next to the player unbuildable.
  bool intersects(WorldRect other) =>
      left < other.right &&
      other.left < right &&
      top < other.bottom &&
      other.top < bottom;

  bool containsPoint(WorldPos point) =>
      point.x >= left && point.x < right && point.y >= top && point.y < bottom;

  @override
  String toString() => 'WorldRect($left, $top, $width×$height)';
}
