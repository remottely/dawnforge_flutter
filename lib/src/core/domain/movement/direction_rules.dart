import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// Pure domain rules for the 2-directional facing system — the Dart port of
/// `DirectionRules.cs`. Typed to [ActorDirection] directly: the C# version
/// took the two directions as ints only because enums do not cross the
/// GDScript↔C# boundary, a constraint Dart does not have.
abstract final class DirectionRules {
  static bool shouldUpdateLookDirection(WorldPos velocity) =>
      velocity.lengthSquared > 0.01;

  static bool hasSignificantHorizontalMovement(WorldPos velocity) =>
      velocity.x.abs() > 1.0;

  static ActorDirection directionFromVelocityX(double velocityX) =>
      velocityX > 0 ? ActorDirection.right : ActorDirection.left;

  static ActorDirection directionFromTargetPosition(
    WorldPos targetPos,
    WorldPos ownerPos,
  ) =>
      targetPos.x < ownerPos.x ? ActorDirection.left : ActorDirection.right;
}
