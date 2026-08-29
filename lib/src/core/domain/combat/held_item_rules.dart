import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// Pure domain rules for an item in a hand — the Dart port of
/// `HeldItemRules.cs` (slice: the aim maths, which is what the swing needs.
/// Its other half — effective cost type, combo windows, rest position and
/// rotation — arrives with the costs and the motion those belong to).
abstract final class HeldItemRules {
  /// The heading an aim means, with [fallbackDirection] for the degenerate
  /// case: a raw vector shorter than one unit is an actor aiming at its own
  /// feet, which has chosen no direction at all, so its current facing stands.
  ///
  /// The fallback comes back UNNORMALIZED, exactly as the spec leaves it —
  /// normalizing is the caller's, and `AimSnapshot`'s constructor is the one
  /// place that does it.
  static WorldPos safeAimDirection(
    WorldPos rawDirection,
    WorldPos fallbackDirection,
  ) =>
      rawDirection.lengthSquared >= 1 ? rawDirection.normalized() : fallbackDirection;

  /// Where a heading of [distance] from [origin] lands.
  static WorldPos estimateTargetPosition(
    WorldPos origin,
    WorldPos direction,
    double distance,
  ) =>
      origin + direction.normalized() * distance;
}
