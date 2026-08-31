import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand_tool.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3a slice 5: THE SWING. The whole FP4 harvest in one call — the gate
/// decides, the item says how hard, the prop takes it, and its death is what
/// puts the loot on the ground.
///
/// FP4.3b slice 4 moved the deed into `ItemHandTool`, so these go in through
/// the aim the hand resolves rather than by handing it a prop. The subject is
/// unchanged; what is new is that the answer distinguishes a press that cost
/// nothing from one that cost the cadence and achieved nothing.
void main() {
  setUp(() {
    registerCoreSystems();

    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{
        'id': 't1_item_logs_probe',
        'max_stack': 10,
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_axe',
        'tool_type': 'AXE',
        'tier': 1,
        'attack_damage': 2,
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_hoe',
        'tool_type': 'HOE',
        'tier': 1,
        'attack_damage': 2,
      })
      // Bare hands: authored weak, exactly as the pack authors them (0.25).
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
        'tier': 1,
        'attack_damage': 1,
      });

    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 30,
      'base_max_health': 10,
    });

    locator<PropRegistry>()
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_tree',
        'allowed_tools': <String>['AXE'],
        'tier': 1,
        'base_max_health': 4,
        'allows_actor_overlap': true,
        'drops': <Map<String, Object?>>[
          <String, Object?>{
            'item_id': 't1_item_logs_probe',
            'chance': 1.0,
            'min_amount': 3,
            'max_amount': 3,
          },
        ],
      })
      // Weeds: bare hands are enough, and one pull is all it takes.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_weeds',
        'allowed_tools': <String>['INNATE'],
        'tier': 1,
        'base_max_health': 1,
        'allows_actor_overlap': true,
        'drops': <Map<String, Object?>>[
          <String, Object?>{
            'item_id': 't1_item_logs_probe',
            'chance': 1.0,
            'min_amount': 1,
            'max_amount': 1,
          },
        ],
      });

    final grid = locator<GridManager>();
    for (var x = -4; x <= 8; x++) {
      for (var y = -4; y <= 8; y++) {
        grid.registerGroundData(
          GridPos(x, y),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      }
    }
  });
  tearDown(resetCoreSystems);

  GridManager grid() => locator<GridManager>();

  /// A player standing on the tile NEXT to (5,5), where every target below
  /// goes — the reach is the axe's authored default and this is well inside
  /// it. FP4.3a handed the prop straight in; the hand resolves it from the aim
  /// now, so the distance between the two is real and has to be honest.
  IActor player({String? holding}) {
    final actor = ActorFactory.create(
      't1_actor_probe_player',
      grid().gridToWorld(const GridPos(4, 5)),
    );
    if (holding != null) {
      actor.inventory.setSlot(0, locator<ItemRegistry>().getItem(holding), 1);
    }
    return actor;
  }

  /// The aim [actor] would have taken with the cursor over [at]. Built here
  /// rather than through `InputHelper` because this file is about the DEED —
  /// where the aim comes from is `actor_player_test`'s subject.
  AimSnapshot aimFrom(IActor actor, GridPos at) => AimSnapshot.fromPoint(
        actor.position,
        grid().gridToWorld(at),
        actor.direction.lookDirection,
      );

  Prop propAt(String id, GridPos at) {
    final prop = PropFactory.create(
      id,
      grid().gridToWorld(at),
      random: Random(20260826),
    );
    grid().occupyPropTiles(at, prop);
    return prop;
  }

  List<ItemWorld> watchPickups() {
    final spawned = <ItemWorld>[];
    locator<Events>().pickupSpawned.connect((p) => spawned.add(p as ItemWorld));
    return spawned;
  }

  test('two swings of an axe fell a tree and put its logs on the ground', () {
    final chopper = player(holding: 't1_item_tool_axe');
    final tree = propAt('t1_prop_probe_tree', const GridPos(5, 5));
    final aim = aimFrom(chopper, const GridPos(5, 5));
    final spawned = watchPickups();

    // Four health, two damage a swing — the number comes off the authored
    // item, not off the caller.
    expect(chopper.usePrimaryAction(aim), ActionOutcome.landed);
    expect(tree.health.current, 2);
    expect(spawned, isEmpty);

    expect(chopper.usePrimaryAction(aim), ActionOutcome.landed);
    expect(tree.health.isAlive, isFalse);
    expect(spawned.single.itemData.id, 't1_item_logs_probe');
    expect(spawned.single.amount, 3);
  });

  test('a swing with the wrong tool lands nothing — and is still a swing', () {
    final farmer = player(holding: 't1_item_tool_hoe');
    final tree = propAt('t1_prop_probe_tree', const GridPos(5, 5));

    // SPENT, not none: the hoe reached the tree and was refused there. The
    // press became an action that achieved nothing, which is the case the
    // cadence is supposed to charge for.
    expect(
      farmer.usePrimaryAction(aimFrom(farmer, const GridPos(5, 5))),
      ActionOutcome.spent,
    );
    expect(tree.health.current, 4);
  });

  test('bare hands harvest what asks for bare hands', () {
    // The slice-3 join, end to end: nothing equipped, so the hand holds the
    // INNATE item, and the weeds accept exactly that.
    final barehanded = player();
    propAt('t1_prop_probe_weeds', const GridPos(5, 5));
    final spawned = watchPickups();

    expect(
      barehanded.usePrimaryAction(aimFrom(barehanded, const GridPos(5, 5))),
      ActionOutcome.landed,
    );
    expect(spawned.single.itemData.id, 't1_item_logs_probe');
  });

  test('the dead do not swing', () {
    final chopper = player(holding: 't1_item_tool_axe');
    final tree = propAt('t1_prop_probe_tree', const GridPos(5, 5));

    chopper.health.takeDamage(chopper.health.maximum);
    expect(chopper.health.isAlive, isFalse);

    expect(
      chopper.usePrimaryAction(aimFrom(chopper, const GridPos(5, 5))),
      ActionOutcome.none,
    );
    expect(tree.health.current, 4);
  });

  test('an aim at bare ground is no action at all', () {
    final chopper = player(holding: 't1_item_tool_axe');
    propAt('t1_prop_probe_tree', const GridPos(5, 5));

    expect(
      chopper.usePrimaryAction(aimFrom(chopper, const GridPos(5, 4))),
      ActionOutcome.none,
      reason: 'nothing was aimed at, so nothing was done and nothing is owed',
    );
  });

  test('a tree out of reach is not something the hand did', () {
    // The reach is the ITEM's, asked inside the hand — the actor holding it
    // has no opinion. Six tiles away with a two-tile axe.
    final chopper = player(holding: 't1_item_tool_axe');
    final far = propAt('t1_prop_probe_tree', const GridPos(-3, 5));

    expect(
      chopper.usePrimaryAction(aimFrom(chopper, const GridPos(-3, 5))),
      ActionOutcome.none,
    );
    expect(far.health.current, 4);
  });

  test('a log in hand is a hand that does nothing, not a swing that fails', () {
    // The base hand's whole subject: most items in this game are materials,
    // and pressing with one is no action. It never reaches the gate, so it
    // never costs the cadence either.
    final carrier = player(holding: 't1_item_logs_probe');
    final tree = propAt('t1_prop_probe_tree', const GridPos(5, 5));

    expect(carrier.heldItem.hand, isNot(isA<ItemHandTool>()));
    expect(
      carrier.usePrimaryAction(aimFrom(carrier, const GridPos(5, 5))),
      ActionOutcome.none,
    );
    expect(tree.health.current, 4);
  });
}
