import 'package:dawnforge/src/core/domain/combat/held_item_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// What an action was aimed at, measured ONCE, where it was made — the port of
/// `aim_snapshot.gd`, whose header is the reason this class exists at all.
///
/// An action's aim has to survive two crossings: the press→impact delay a
/// swing holds it over so the effect lands on the frame the motion reads as
/// contact, and (in the spec) the client→host hop a guest's intent takes.
///
/// It used to cross both as a bare world POINT and be turned back into a
/// DIRECTION at the far end, by subtracting the shooter's position AT THE FAR
/// END. That only works for a shooter who did not move — and the whole reason
/// a ranged weapon exists is to be fired while moving. A walking player's
/// arrow left at the wrong angle, and once the walk had carried them past the
/// point they aimed at, at the opposite one: the vector's sign flipped and the
/// arrow flew backwards. It was wrong standing still too, because the two
/// subtractions used two different anchors.
///
/// So the aim is measured once, at the instant the button goes down, and
/// carries every form a consumer could ask for. Nobody downstream subtracts a
/// position again — that rule is the whole point of this class.
///
///   [direction] — anything that travels, and a swing's motion axis
///   [point]     — which tile: farming, building, what the cursor is over
///   [origin]    — reach, so "how far did I reach" is measured from where the
///                 reach began
final class AimSnapshot {
  /// Direct construction is for rebuilding a snapshot measured somewhere else
  /// that then travelled — the host reassembling a guest's intent, when there
  /// is a host. Everything else names one of the two named constructors, so
  /// the derivation happens in exactly one place.
  AimSnapshot(this.origin, this.point, WorldPos aimDirection)
      : assert(
          aimDirection != WorldPos.zero,
          '[AimSnapshot] an aim points somewhere — use fromPoint() to derive '
          'a heading safely',
        ),
        // `safeAimDirection` hands its fallback back unnormalized, so
        // normalizing is this constructor's job rather than each caller's.
        direction = aimDirection.normalized();

  /// An actor pointing AT a place: the cursor, a target's body, a tile.
  /// [fallbackDirection] is what the aim means when the point sits on top of
  /// the origin — an actor aiming at its own feet has chosen no direction, so
  /// its current facing stands.
  factory AimSnapshot.fromPoint(
    WorldPos aimOrigin,
    WorldPos aimPoint,
    WorldPos fallbackDirection,
  ) =>
      AimSnapshot(
        aimOrigin,
        aimPoint,
        HeldItemRules.safeAimDirection(aimPoint - aimOrigin, fallbackDirection),
      );

  /// An actor pointing A WAY rather than at a thing — a creature swinging
  /// along its facing, a potion drunk in place. [reach] is how far ahead the
  /// point lands, and zero is the honest answer for an action with no target.
  factory AimSnapshot.fromDirection(
    WorldPos aimOrigin,
    WorldPos aimDirection,
    double reach,
  ) {
    final heading =
        HeldItemRules.safeAimDirection(aimDirection, WorldPos.right)
            .normalized();
    return AimSnapshot(
      aimOrigin,
      HeldItemRules.estimateTargetPosition(aimOrigin, heading, reach),
      heading,
    );
  }

  /// Where the aim was measured FROM: the actor's body centre at the instant
  /// of the press, never some other anchor — the cursor is placed against the
  /// body centre, and an aim measured from anywhere else disagrees with the
  /// crosshair the player was looking at.
  final WorldPos origin;

  /// The world point aimed at, at that same instant. Frozen on purpose: a
  /// cursor that drifts during the swing must not drag the hit along with it.
  final WorldPos point;

  /// Normalized heading from [origin] to [point], computed once here and
  /// never re-derived. This is the field that fixes the walking shooter: it is
  /// a direction, so no later position can corrupt it.
  final WorldPos direction;

  @override
  String toString() => 'AimSnapshot(origin: $origin, point: $point, '
      'direction: $direction)';
}
