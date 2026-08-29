import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
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

  IActor player({String? holding}) {
    final actor = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    if (holding != null) {
      actor.inventory.setSlot(0, locator<ItemRegistry>().getItem(holding), 1);
    }
    return actor;
  }

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
    final spawned = watchPickups();

    // Four health, two damage a swing — the number comes off the authored
    // item, not off the caller.
    expect(chopper.usePrimaryActionOn(tree), isTrue);
    expect(tree.health.current, 2);
    expect(spawned, isEmpty);

    expect(chopper.usePrimaryActionOn(tree), isTrue);
    expect(tree.health.isAlive, isFalse);
    expect(spawned.single.itemData.id, 't1_item_logs_probe');
    expect(spawned.single.amount, 3);
  });

  test('a swing with the wrong tool lands nothing at all', () {
    final farmer = player(holding: 't1_item_tool_hoe');
    final tree = propAt('t1_prop_probe_tree', const GridPos(5, 5));

    expect(farmer.usePrimaryActionOn(tree), isFalse);
    expect(tree.health.current, 4);
  });

  test('bare hands harvest what asks for bare hands', () {
    // The slice-3 join, end to end: nothing equipped, so the hand holds the
    // INNATE item, and the weeds accept exactly that.
    final barehanded = player();
    final weeds = propAt('t1_prop_probe_weeds', const GridPos(5, 5));
    final spawned = watchPickups();

    expect(barehanded.usePrimaryActionOn(weeds), isTrue);
    expect(spawned.single.itemData.id, 't1_item_logs_probe');
  });

  test('the dead do not swing', () {
    final chopper = player(holding: 't1_item_tool_axe');
    final tree = propAt('t1_prop_probe_tree', const GridPos(5, 5));

    chopper.health.takeDamage(chopper.health.maximum);
    expect(chopper.health.isAlive, isFalse);

    expect(chopper.usePrimaryActionOn(tree), isFalse);
    expect(tree.health.current, 4);
  });
}
