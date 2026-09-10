import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/actor_occupancy_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_permission_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/components/i_world_object/drop_component.dart';
import 'package:dawnforge/src/core/components/i_world_object/health_component.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/drop/world_drop_helper.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:meta/meta.dart';

/// Host of every prop. Created only by `PropFactory.create()` (rule 1).
class Prop extends WorldObject {
  Prop(this.random);

  /// Typed view over the injected soul.
  PropData get propData => data as PropData;

  /// The roll stream this prop's loot and scatter come out of, handed in by
  /// the factory (rule 1). A never-serialized internal (rule 8). One per prop
  /// rather than one stream shared by all of them, because the ORDER props
  /// happen to die in must not decide what each of them yields. Protected
  /// so a subclass with more to put on the ground (`PropWorkstation`) rolls
  /// where from the same stream.
  @protected
  final Random random;

  late final HealthComponent health;
  late final DropComponent drop;

  @override
  void setupComponents() {
    health = addComponent(HealthComponent());
    drop = addComponent(DropComponent(random));
    health.died.connect(onDied);
  }

  /// Takes [amount] of damage from [source]. Returns whether the hit LANDED —
  /// a refusal the caller reads, never a silent nothing (rule 20).
  ///
  /// The two gates below are asked again here even though
  /// `WorldObjectPermissionHelper.canDamageTarget` asked them a moment ago,
  /// and the spec's own comment says why: a swing, a projectile, a
  /// companion's harvest and (later) a guest's replicated intent all arrive
  /// at this method, so a gate that lived only in the permission helper would
  /// be one new caller away from a hole. The helper answers the CURSOR; this
  /// answers the BLOW.
  bool takeDamage(double amount, IActor source) {
    assert(amount >= 0, '[Prop] takeDamage amount $amount must be >= 0');
    if (!WorldObjectPermissionHelper.validateToolRequirement(data, source)) {
      return false;
    }
    if (ActorOccupancyHelper.isDestructionBlocked(this)) return false;
    return health.takeDamage(amount, source: source);
  }

  /// What a prop's death does, in the order it has to happen in.
  ///
  /// The tiles are released FIRST, before a single drop rolls: a pickup looks
  /// for a tile it can rest on, and a colliding corpse still holding its own
  /// tile pushes its own loot off it. The corpse stops occupying the world at
  /// the moment it dies, not at the moment the renderer notices.
  ///
  /// PORT DELTAS: the spec's death simulation also grants XP (`TierSystem`,
  /// FP7), scales the loot by the killer's `drop_multiplier` (an
  /// `IItemActionData` field, unported — so the multiplier stays 1.0 here),
  /// and pools plain props instead of freeing them (`PropPool`, FP7). What
  /// remains is what harvest actually needs.
  ///
  /// Protected, not private, so a host with more to do at death does it
  /// BEFORE this — `PropWorkstation` spills its half-made batch back first,
  /// because a corpse can hold no allocation and its leftovers are the
  /// player's. The order is the subclass's responsibility, and the spec's
  /// `_on_died` override is the same shape.
  @protected
  @mustCallSuper
  void onDied(Object? source) {
    _releaseGridTiles();
    locator<Events>().worldObjectDied.emit(this);
    drop.dropItems(WorldDropHelper.calculateDropPosition(this, random));
    // "It left the world" is a second fact from "it died", and it is the one
    // the render and sim layers act on — the same signal a recycled chunk
    // sends for a prop that simply went out of range.
    locator<Events>().worldObjectDespawned.emit(this);
  }

  /// Hands this prop's footprint back to the grid, when the grid is holding
  /// it. A prop the grid never claimed — one built by a test, or one still in
  /// flight — is a legitimate case, not a missing registration.
  void _releaseGridTiles() {
    final grid = locator<GridManager>();
    final anchor = grid.worldToGrid(position);
    if (!identical(grid.getPropAt(anchor), this)) return;
    grid.freePropTiles(anchor, this);
  }
}
