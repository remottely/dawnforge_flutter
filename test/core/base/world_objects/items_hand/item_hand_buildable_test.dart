import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand_buildable.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3b slice 5: THE PRESS BUILDS. Four steps whose order is the point —
/// work out the tiles, ask the gate, spend the item, put it there.
void main() {
  setUp(() {
    registerCoreSystems();

    locator<GroundRegistry>()
      ..registerJson(<String, Object?>{
        'type': 'ground_buildable_data',
        'id': 't1_ground_buildable_terrain',
        'allows_actor_overlap': false,
      })
      ..registerJson(<String, Object?>{
        'type': 'ground_buildable_data',
        'id': 't1_ground_buildable_bridge_palm',
        'allows_actor_overlap': true,
        'floats_on_water': true,
      })
      ..registerJson(<String, Object?>{
        'type': 'ground_empty_data',
        'id': 't1_ground_empty_water',
        'is_water': true,
        'is_passable': false,
        'blocks_props': true,
      });

    locator<PropRegistry>()
      // The smelter's shape: two tiles wide, one tall.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_smelter',
        'allows_actor_overlap': true,
        'grid_size': <int>[2, 1],
      })
      // A tall one, so the anchor conversion has something to move.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_post',
        'allows_actor_overlap': true,
        'grid_size': <int>[1, 2],
      });

    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{
        'type': 'item_buildable_data',
        'id': 't1_item_buildable_workstation_smelter',
        'blueprint_id': 't1_prop_probe_smelter',
        'action_range': 1.0,
        'max_stack': 100,
      })
      ..registerJson(<String, Object?>{
        'type': 'item_buildable_data',
        'id': 't1_item_buildable_post',
        'blueprint_id': 't1_prop_probe_post',
        'action_range': 1.0,
        'max_stack': 100,
      })
      ..registerJson(<String, Object?>{
        'type': 'item_buildable_data',
        'id': 't1_item_buildable_ground_bridge_palm',
        'blueprint_id': 't1_ground_buildable_bridge_palm',
        'action_range': 1.0,
        'max_stack': 100,
      })
      // Bare hands: what the player holds until a blueprint is put in the slot.
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
        'tier': 1,
      });

    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 30,
    });
  });

  tearDown(resetCoreSystems);

  GridManager grid() => locator<GridManager>();

  void layTerrain(GridPos from, GridPos to) {
    final data =
        locator<GroundRegistry>().getGround('t1_ground_buildable_terrain');
    for (var x = from.x; x <= to.x; x++) {
      for (var y = from.y; y <= to.y; y++) {
        grid().registerGroundData(GridPos(x, y), data);
      }
    }
  }

  /// A player at [at] holding [amount] of [itemId].
  IActor builderAt(GridPos at, String itemId, {int amount = 2}) {
    final actor =
        ActorFactory.create('t1_actor_probe_player', grid().gridToWorld(at));
    actor.inventory
        .setSlot(0, locator<ItemRegistry>().getItem(itemId), amount);
    return actor;
  }

  AimSnapshot aimFrom(IActor actor, GridPos at) => AimSnapshot.fromPoint(
        actor.position,
        grid().gridToWorld(at),
        actor.direction.lookDirection,
      );

  test('a blueprint in hand is a hand that builds', () {
    layTerrain(const GridPos(0, 0), const GridPos(9, 9));
    final builder =
        builderAt(const GridPos(5, 5), 't1_item_buildable_workstation_smelter');

    expect(builder.heldItem.hand, isA<ItemHandBuildable>());
  });

  test('the press puts the thing in the world and spends exactly one', () {
    layTerrain(const GridPos(0, 0), const GridPos(9, 9));
    final builder =
        builderAt(const GridPos(5, 5), 't1_item_buildable_workstation_smelter');
    final spawned = <Prop>[];
    locator<Events>().worldObjectSpawned.connect((p) => spawned.add(p as Prop));

    expect(
      builder.usePrimaryAction(aimFrom(builder, const GridPos(6, 5))),
      ActionOutcome.landed,
    );

    expect(spawned.single.data.id, 't1_prop_probe_smelter');
    // Both tiles of the 2x1 footprint map back to the same host.
    expect(identical(grid().getPropAt(const GridPos(6, 5)), spawned.single),
        isTrue);
    expect(identical(grid().getPropAt(const GridPos(7, 5)), spawned.single),
        isTrue);
    expect(builder.inventory.countOf('t1_item_buildable_workstation_smelter'), 1,
        reason: 'one blueprint spent, one left');
  });

  test('a multi-tile prop is CENTRED over the tiles it covers', () {
    layTerrain(const GridPos(0, 0), const GridPos(9, 9));
    final builder =
        builderAt(const GridPos(5, 5), 't1_item_buildable_workstation_smelter');
    final spawned = <Prop>[];
    locator<Events>().worldObjectSpawned.connect((p) => spawned.add(p as Prop));

    builder.usePrimaryAction(aimFrom(builder, const GridPos(6, 5)));

    // Two tiles wide starting at the corner of (6,5): the centre sits on the
    // seam BETWEEN (6,5) and (7,5), not on either tile's own centre.
    const dimension = GameConstants.tileDimension;
    final corner = grid().gridToWorldCorner(const GridPos(6, 5));
    expect(spawned.single.position.x, corner.x + dimension);
    expect(spawned.single.position.y, corner.y + dimension / 2);
  });

  test('the footprint anchors ABOVE the cursor, because a prop stands on its '
      'bottom row', () {
    layTerrain(const GridPos(0, 0), const GridPos(9, 9));
    final builder = builderAt(const GridPos(5, 5), 't1_item_buildable_post');
    final spawned = <Prop>[];
    locator<Events>().worldObjectSpawned.connect((p) => spawned.add(p as Prop));

    expect(
      builder.usePrimaryAction(aimFrom(builder, const GridPos(6, 5))),
      ActionOutcome.landed,
    );

    // Pointed at (6,5); the post is two tall, so it took (6,4) as well — and
    // NOT (6,6), which is where an anchor read as the top-left of the cursor
    // tile would have put it.
    expect(identical(grid().getPropAt(const GridPos(6, 4)), spawned.single),
        isTrue);
    expect(identical(grid().getPropAt(const GridPos(6, 5)), spawned.single),
        isTrue);
    expect(grid().getPropAt(const GridPos(6, 6)), isNull);
  });

  test('out of reach builds nothing and costs nothing', () {
    layTerrain(const GridPos(0, 0), const GridPos(9, 9));
    final builder =
        builderAt(const GridPos(5, 5), 't1_item_buildable_workstation_smelter');

    expect(
      builder.usePrimaryAction(aimFrom(builder, const GridPos(9, 5))),
      ActionOutcome.none,
    );
    expect(grid().getPropAt(const GridPos(9, 5)), isNull);
    expect(builder.inventory.countOf('t1_item_buildable_workstation_smelter'), 2,
        reason: 'a reach you do not have never touched the bag');
  });

  test('a tile the gate refuses costs the cadence but NOT the blueprint', () {
    // The order the four steps are in: the gate answers before the bag is
    // opened. Spend first and a player loses a smelter to a tile they were
    // never allowed to build on.
    layTerrain(const GridPos(0, 0), const GridPos(9, 9));
    final builder =
        builderAt(const GridPos(5, 5), 't1_item_buildable_workstation_smelter');
    final occupant = PropFactory.create(
      't1_prop_probe_smelter',
      grid().gridToWorld(const GridPos(6, 5)),
    );
    grid().occupyPropTiles(const GridPos(6, 5), occupant);

    expect(
      builder.usePrimaryAction(aimFrom(builder, const GridPos(6, 5))),
      ActionOutcome.spent,
    );
    expect(identical(grid().getPropAt(const GridPos(6, 5)), occupant), isTrue,
        reason: 'the tile still belongs to whoever was there');
    expect(builder.inventory.countOf('t1_item_buildable_workstation_smelter'), 2,
        reason: 'a refused build is free');
  });

  test('a ground blueprint lays a bridge over the water', () {
    layTerrain(const GridPos(0, 0), const GridPos(5, 9));
    grid().registerGroundData(
      const GridPos(6, 5),
      locator<GroundRegistry>().getGround('t1_ground_empty_water'),
    );
    final builder = builderAt(
      const GridPos(5, 5),
      't1_item_buildable_ground_bridge_palm',
    );
    expect(grid().isTileWalkable(const GridPos(6, 5)), isFalse);

    expect(
      builder.usePrimaryAction(aimFrom(builder, const GridPos(6, 5))),
      ActionOutcome.landed,
    );

    expect(grid().isTileWalkable(const GridPos(6, 5)), isTrue);
    expect(
      grid().getGroundDataAt(const GridPos(6, 5))!.id,
      't1_ground_buildable_bridge_palm',
    );
    expect(
      builder.inventory.countOf('t1_item_buildable_ground_bridge_palm'),
      1,
    );
  });

  test('a blueprint you no longer have builds nothing', () {
    // The bag is the last thing that can say no, and it saying no is a real
    // end to a press — not an assert.
    layTerrain(const GridPos(0, 0), const GridPos(9, 9));
    final builder = builderAt(
      const GridPos(5, 5),
      't1_item_buildable_workstation_smelter',
      amount: 1,
    );
    builder.inventory.clearSlot(0);

    expect(
      builder.usePrimaryAction(aimFrom(builder, const GridPos(6, 5))),
      ActionOutcome.none,
      reason: 'an empty slot is BARE HANDS for a player, which builds nothing',
    );
    expect(grid().getPropAt(const GridPos(6, 5)), isNull);
  });
}
