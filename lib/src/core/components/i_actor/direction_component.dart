import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/domain/movement/direction_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// 2-directional facing (LEFT/RIGHT only) — port of `direction_component.gd`.
/// API delta from the Godot version: `lookAtPosition` takes the owner's
/// position as a parameter instead of reading the host node, keeping the
/// component free of host-position knowledge below the render layer.
final class DirectionComponent extends IComponent {
  bool faceMovement = true;

  ActorDirection _currentDirection = ActorDirection.right;

  /// The raw 2D look vector (full 360°, unlike the 2-way [direction]).
  WorldPos lookDirection = WorldPos.right;

  final directionChanged = EventSignal<ActorDirection>();

  ActorDirection get direction => _currentDirection;
  bool get isFacingRight => _currentDirection == ActorDirection.right;
  bool get isFacingLeft => _currentDirection == ActorDirection.left;

  /// Updates facing from [velocity] — horizontal only, and only when
  /// [faceMovement] allows it.
  void updateFromVelocity(WorldPos velocity) {
    if (!faceMovement) return;
    if (DirectionRules.shouldUpdateLookDirection(velocity)) {
      lookDirection = velocity.normalized();
    }
    if (DirectionRules.hasSignificantHorizontalMovement(velocity)) {
      setDirection(DirectionRules.directionFromVelocityX(velocity.x));
    }
  }

  /// Forces facing toward [targetPos], from [ownerPos].
  void lookAtPosition(WorldPos targetPos, WorldPos ownerPos) {
    lookDirection = (targetPos - ownerPos).normalized();
    setDirection(DirectionRules.directionFromTargetPosition(targetPos, ownerPos));
  }

  void setDirection(ActorDirection newDirection) {
    if (newDirection == _currentDirection) return;
    _currentDirection = newDirection;
    directionChanged.emit(_currentDirection);
  }
}
