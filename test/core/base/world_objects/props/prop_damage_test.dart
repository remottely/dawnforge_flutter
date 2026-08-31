import 'dart:math';

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

/// FP4.3a slice 5: a prop can be hurt, and dying is what leaves its loot on
/// the ground. This is the far end of the harvest — everything FP4.1 built
/// (loot tables, `DropRules`, physical pickups) finally has something that
/// reaches it.
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
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_hoe',
        'tool_type': 'HOE',
        'tier': 1,
      })
      // Bare hands. A player-grouped actor resolves this id the moment its
      // components are assembled (0.28.0 puts it in an empty slot), and since
      // FP4.3b slice 4 the hand is BUILT there rather than only named — so a
      // probe player in a registry without it now crashes at creation, which
      // is rule 5 catching a fixture that was quietly incomplete.
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
      // What it IS is the ground under you — it may not be taken from under
      // an actor standing on it.
      ..registerJson(<String, Object?>{
        'id': 't1_prop_probe_shaft',
        'allowed_tools': <String>['AXE'],
        'tier': 1,
        'base_max_health': 4,
        'allows_actor_overlap': false,
      });

    // Walkable ground for every landing to resolve onto.
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

  Prop propAt(String id, GridPos at) {
    final prop = PropFactory.create(
      id,
      grid().gridToWorld(at),
      random: Random(20260826),
    );
    grid().occupyPropTiles(at, prop);
    return prop;
  }

  test('an axe fells a tree, and the tree leaves its logs behind', () {
    const at = GridPos(5, 5);
    final tree = propAt('t1_prop_probe_tree', at);
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero)
      ..inventory
          .setSlot(0, locator<ItemRegistry>().getItem('t1_item_tool_axe'), 1);

    final spawned = <ItemWorld>[];
    locator<Events>().pickupSpawned.connect((p) => spawned.add(p as ItemWorld));
    final despawned = <Object>[];
    locator<Events>().worldObjectDespawned.connect(despawned.add);

    // Four points of health, two points a swing: the first blow lands and
    // changes nothing else.
    expect(tree.takeDamage(2, player), isTrue);
    expect(spawned, isEmpty, reason: 'a wounded tree is not a felled one');
    expect(grid().getPropAt(at), same(tree));

    expect(tree.takeDamage(2, player), isTrue);

    expect(spawned, hasLength(1));
    expect(spawned.single.itemData.id, 't1_item_logs_probe');
    expect(spawned.single.amount, 3);
    expect(despawned, <Object>[tree], reason: 'it left the world exactly once');
    expect(grid().getPropAt(at), isNull,
        reason: 'a corpse holds no tile — the loot lands where it stood');
  });

  test('the wrong tool does not scratch it', () {
    final tree = propAt('t1_prop_probe_tree', const GridPos(5, 5));
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero)
      ..inventory
          .setSlot(0, locator<ItemRegistry>().getItem('t1_item_tool_hoe'), 1);

    expect(tree.takeDamage(99, player), isFalse);
    expect(tree.health.current, 4,
        reason: 'the blow is refused where it lands, not only where it is '
            'aimed — every path into the world meets takeDamage');
  });

  test('nothing is destroyed out from under an actor, at the blow too', () {
    const at = GridPos(5, 5);
    final shaft = propAt('t1_prop_probe_shaft', at);
    final player = ActorFactory.create(
      't1_actor_probe_player',
      grid().gridToWorld(at),
    )..inventory
        .setSlot(0, locator<ItemRegistry>().getItem('t1_item_tool_axe'), 1);

    expect(shaft.takeDamage(99, player), isFalse);
    expect(shaft.health.current, 4);

    // Step off it and the same blow lands.
    player.position = grid().gridToWorld(const GridPos(0, 0));
    expect(shaft.takeDamage(99, player), isTrue);
    expect(shaft.health.current, 0);
  });
}
