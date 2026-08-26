import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/components/i_actor/direction_component.dart';
import 'package:dawnforge/src/core/components/i_actor/movement_component.dart';
import 'package:dawnforge/src/core/components/i_world_object/health_component.dart';
import 'package:dawnforge/src/core/domain/movement/world_collision_rules.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// Host of every actor (player, creature, NPC). Created only by
/// `ActorFactory.create()` (rule 1). Composes its behavior from components
/// (Godot repo §4.5), in dependency order — direction before movement,
/// injected via constructor (§4.6).
class IActor extends WorldObject {
  /// Typed view over the injected soul.
  IActorData get actorData => data as IActorData;

  late final DirectionComponent direction;
  late final MovementComponent movement;
  late final HealthComponent health;

  @override
  void setupComponents() {
    direction = addComponent(DirectionComponent());
    movement = addComponent(MovementComponent(direction));
    health = addComponent(HealthComponent());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Integrate velocity into position each fixed step, resolved against
    // grid occupancy (FP3.5) — the `move_and_slide` replacement: a blocked
    // axis stops, the other slides. `has_collision: false` actors (ghosts,
    // projectile-like) keep the raw integration, as authored.
    if (!data.hasCollision) {
      position += movement.velocity * dt;
      return;
    }
    final resolved = WorldCollisionRules.resolveStep(
      position: position,
      velocity: movement.velocity,
      dt: dt,
      bodyHalfExtent: EngineConstants.actorBodyHalfExtentTiles *
          GameConstants.tileDimension,
      tileDimension: GameConstants.tileDimension,
      blocksBody: locator<GridManager>().blocksBodyAt,
    );
    position = resolved.position;
    movement.velocity = resolved.velocity;
  }
}
