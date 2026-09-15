import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_permission_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/components/i_actor/direction_component.dart';
import 'package:dawnforge/src/core/components/i_actor/held_item_component.dart';
import 'package:dawnforge/src/core/components/i_actor/movement_component.dart';
import 'package:dawnforge/src/core/components/i_interactable/interactable_component.dart';
import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/components/i_world_object/health_component.dart';
import 'package:dawnforge/src/core/domain/movement/world_collision_rules.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/actor_tracker.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/generated/component_keys.dart';

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
  late final InventoryComponent inventory;
  late final HeldItemComponent heldItem;

  @override
  void setupComponents() {
    direction = addComponent(DirectionComponent());
    movement = addComponent(MovementComponent(direction));
    health = addComponent(HealthComponent());
    // Every actor is a collector — its slots live in the data soul
    // (IActorData.inventory), sized by the authored inventory_size.
    inventory = addComponent(InventoryComponent());
    // Every actor has a hand, as in the spec (`IActor._setup_components`): a
    // creature's is its authored weapon, a player's is whatever the hotbar
    // points at. It goes in AFTER the bag it reads from (rule: dependency
    // order is the host's responsibility).
    heldItem = addComponent(HeldItemComponent(inventory, this));
    // The world now knows this actor is in it (FP4.3a). The spec puts every
    // actor in a `character` group so the occupancy rules can sweep them all;
    // Dart has no tree to hold a group, so the membership is a system, and
    // joining happens HERE — where a component set is assembled — because the
    // factory is the only path that reaches it (rule 1).
    locator<ActorTracker>().add(this);
  }

  /// Uses what is in this actor's hand, at [aim] — the port of
  /// `IActor.use_held_item_primary_action`.
  ///
  /// The actor owns two of the three questions a press asks: is this actor in
  /// a state to act, and is there a hand to act with. The third — what the
  /// deed IS — belongs to the hand, because a swing and a build are not two
  /// settings of one function (see [ItemHand]).
  ///
  /// An actor with an empty hand answers [ActionOutcome.none]. That is a real
  /// state for a creature authored without a weapon; a PLAYER never reaches it
  /// (an empty slot is bare hands, 0.28.0).
  ///
  /// PORT DELTAS: the spec also paces the swing here (`_reset_action_cooldown`
  /// off the authored `base_action_speed`) and pays for it (energy, mana,
  /// combo points). Pacing lives with the press that spends it (`ActorPlayer`,
  /// 0.34.0); the costs belong with `HeldItemComponent`'s unported half.
  ActionOutcome usePrimaryAction(AimSnapshot aim) {
    if (!health.isAlive) return ActionOutcome.none;
    final hand = heldItem.hand;
    if (hand == null) return ActionOutcome.none;
    return hand.primaryAction(aim);
  }

  /// Reaches for what [aim] is over — the port of `IActor`'s side of the
  /// interact verb, and the third press this class knows how to spend.
  ///
  /// It answers `false` four ways and none of them is an error: this actor is
  /// dead, the aim is over open ground, what it is over does not answer to a
  /// reach, or it does and this actor is too far from it. A caller reads the
  /// refusal (rule 20) — the touch path turns it into a swing.
  ///
  /// The reach is the OBJECT's here, not the hand's, which is the one place
  /// this verb differs from the swing: a bench you can use from two tiles
  /// away says so on its own document, and the empty hand reaching for it has
  /// no opinion. It is measured by the same edge-to-edge gate the swing and
  /// the build use, so a station you may use is a station you could have
  /// broken from where you stand.
  bool tryInteract(AimSnapshot aim) {
    if (!health.isAlive) return false;
    final grid = locator<GridManager>();
    final target = grid.getPropAt(grid.worldToGrid(aim.point));
    if (target == null) return false;
    final reachable = target.getComponent<InteractableComponent>(
      ComponentKeys.interactable,
    );
    if (reachable == null) return false;
    if (!WorldObjectPermissionHelper.isWithinRange(
      this,
      ObjectTarget(target),
      reachable.rangePixels,
    )) {
      return false;
    }
    reachable.interact(this);
    return true;
  }

  /// Leaves the world. Actors do not despawn yet — chunk unloading only
  /// recycles props — so this exists for the paths that will (death, an
  /// unloading chunk) and for tests that build a crowd and take it apart.
  void leaveWorld() => locator<ActorTracker>().remove(this);

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
