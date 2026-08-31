import 'package:dawnforge/src/core/components/i_actor/direction_component.dart';
import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/domain/movement/movement_rules.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// Physics-shaped movement — port of `movement_component.gd` (logic slice:
/// the interop parameter cache, tactical time scale and equipment signals
/// arrive with their systems — the cache in particular existed to avoid
/// GDScript↔C# marshalling, a cost Dart does not pay). The direction
/// dependency is injected via constructor (Godot repo §4.6).
///
/// The component owns `velocity` (world-units/sec, internal state, never
/// serialized — §4.7's cached-transient exception); the host integrates it
/// into its position each fixed step. Collision resolution arrives in FP3.
final class MovementComponent extends IComponent {
  MovementComponent(this._direction);

  final DirectionComponent _direction;

  bool isMovingBackwards = false;

  /// Current velocity in world-units/sec.
  WorldPos velocity = WorldPos.zero;

  IActorData get _actorData {
    final actorData = data as IActorData;
    return actorData;
  }

  /// Accelerates toward [inputVector] (a normalized direction, or zero to
  /// coast under friction). Speed/accel are authored in tiles/sec.
  void applyMovement(WorldPos inputVector, double dt) {
    final actorData = _actorData;
    const tileDim = GameConstants.tileDimension * 1.0;

    isMovingBackwards = false;

    if (inputVector != WorldPos.zero) {
      isMovingBackwards =
          MovementRules.isBackpedaling(inputVector, _direction.lookDirection);
      final speed = MovementRules.applyBackpedalPenalty(
        actorData.moveSpeed,
        isBackpedaling: isMovingBackwards,
      );
      final targetVelocity =
          MovementRules.calculateTargetVelocity(inputVector, speed, tileDim);
      velocity = velocity.moveToward(
        targetVelocity,
        actorData.acceleration * tileDim * dt,
      );
    } else {
      velocity = velocity.moveToward(
        WorldPos.zero,
        actorData.friction * tileDim * dt,
      );
    }

    _direction.updateFromVelocity(velocity);
  }

  /// Moves toward [targetPosition] from [ownerPosition] — the AI entry point.
  void moveTowardPosition(
    WorldPos targetPosition,
    WorldPos ownerPosition,
    double dt,
  ) =>
      applyMovement((targetPosition - ownerPosition).normalized(), dt);

  /// Decelerates to a stop.
  void applyFriction(double dt) {
    velocity = velocity.moveToward(
      WorldPos.zero,
      _actorData.friction * GameConstants.tileDimension * dt,
    );
  }

  /// An external impulse (knockback), added on top of current velocity.
  void applyKnockback(WorldPos force) {
    velocity += force;
  }

  bool get isMoving =>
      velocity.lengthSquared >
      MovementRules.movingThresholdSquared(
        GameConstants.tileDimension * 1.0,
      );
}
