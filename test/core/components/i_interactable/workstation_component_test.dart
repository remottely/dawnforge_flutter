import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop_workstation.dart';
import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/components/i_interactable/workstation_component.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/generated/component_keys.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5 slice 4: what a station is DOING. A batch is paid for once, ticked
/// unit by unit, each unit spilled in front of the station, and a cancelled
/// batch gives back exactly what it had not yet eaten.
void main() {
  setUp(() {
    registerCoreSystems();

    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{
        'id': 't1_item_ore_copper',
        'max_stack': 100,
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_coal',
        'max_stack': 100,
      })
      ..registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_bar_copper',
        'max_stack': 100,
        'tier': 1,
        'crafted_at': 'SMELTER',
        'craft_time': 2.0,
        'craft_amount': 1,
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_ore_copper', 'amount': 5},
          <String, Object?>{'id': 't1_item_coal', 'amount': 1},
        ],
      })
      // A recipe for a different station, to be refused by this one.
      ..registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_plank',
        'tier': 1,
        'crafted_at': 'WORKSHOP',
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_coal', 'amount': 1},
        ],
      })
      // What takes a smelter apart, as the pack authors it.
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_sledgehammer',
        'tool_type': 'SLEDGEHAMMER',
        'tier': 1,
      })
      // Bare hands — a player-grouped actor resolves this at assembly.
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

    locator<PropRegistry>().registerJson(<String, Object?>{
      'type': 'prop_workstation_data',
      'id': 't1_prop_workstation_smelter',
      'workstation_type': 'SMELTER',
      'production_speed_multiplier': 2.0,
      'tier': 1,
      'grid_size': <int>[2, 1],
      'base_max_health': 10,
      'allowed_tools': <String>['SLEDGEHAMMER'],
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

  ItemCraftableData recipe(String id) =>
      locator<ItemRegistry>().getItem(id) as ItemCraftableData;

  PropWorkstation smelter() => PropFactory.create(
        't1_prop_workstation_smelter',
        locator<GridManager>().gridToWorld(const GridPos(3, 3)),
        random: Random(20260910),
      ) as PropWorkstation;

  /// A player holding [ore] ore and [coal] coal.
  InventoryComponent bagWith({required int ore, required int coal}) {
    final player = ActorFactory.create('t1_actor_probe_player', WorldPos.zero);
    final items = locator<ItemRegistry>();
    if (ore > 0) player.inventory.setSlot(0, items.getItem('t1_item_ore_copper'), ore);
    if (coal > 0) player.inventory.setSlot(1, items.getItem('t1_item_coal'), coal);
    return player.inventory;
  }

  List<ItemWorld> spillsInto() {
    final spawned = <ItemWorld>[];
    locator<Events>().pickupSpawned.connect((p) => spawned.add(p as ItemWorld));
    return spawned;
  }

  group('the factory routes the soul to the host', () {
    test('workstation data gets a workstation host, with the component', () {
      final station = smelter();
      expect(
        station.getComponent<WorkstationComponent>(ComponentKeys.workstation),
        same(station.workstation),
      );
      expect(station.workstation.isProducing, isFalse);
      expect(station.workstation.availableRecipes().map((r) => r.id),
          <String>['t1_item_bar_copper']);
    });

    test('a plain prop stays a plain prop', () {
      locator<PropRegistry>().registerJson(<String, Object?>{
        'id': 't1_prop_probe_rock',
      });
      final rock = PropFactory.create('t1_prop_probe_rock', WorldPos.zero);
      expect(rock, isNot(isA<PropWorkstation>()));
      expect(rock.hasComponent(ComponentKeys.workstation), isFalse);
    });
  });

  group('startProduction', () {
    test('pays once, up front, for the whole batch', () {
      final station = smelter();
      final bag = bagWith(ore: 12, coal: 3);
      final started = <(ItemCraftableData, int)>[];
      station.workstation.productionStarted.connect(started.add);

      expect(station.workstation.startProduction(recipe('t1_item_bar_copper'), 2, bag),
          isTrue);

      expect(bag.countOf('t1_item_ore_copper'), 2);
      expect(bag.countOf('t1_item_coal'), 1);
      expect(started.single.$2, 2);
      expect(station.workstation.isProducing, isTrue);
      expect(station.workstation.remainingQuantity, 2);
      expect(station.workstationData.initialQuantity, 2);
      expect(
        station.workstationData.allocatedMaterials.map((m) => '$m'),
        <String>['10× t1_item_ore_copper (allocated)', '2× t1_item_coal (allocated)'],
      );
    });

    test('refuses a recipe this station does not make, and takes nothing', () {
      final station = smelter();
      final bag = bagWith(ore: 0, coal: 5);

      expect(station.workstation.startProduction(recipe('t1_item_plank'), 1, bag),
          isFalse);

      expect(bag.countOf('t1_item_coal'), 5);
      expect(station.workstation.isProducing, isFalse);
    });

    test('refuses a batch the bag cannot pay for, and takes nothing', () {
      final station = smelter();
      // Ore for two, coal for one: two bars are refused whole, not one made.
      final bag = bagWith(ore: 10, coal: 1);

      expect(station.workstation.startProduction(recipe('t1_item_bar_copper'), 2, bag),
          isFalse);

      expect(bag.countOf('t1_item_ore_copper'), 10);
      expect(bag.countOf('t1_item_coal'), 1);
      expect(station.workstation.isProducing, isFalse);
    });

    test('a second order on a busy station spills the first one back first', () {
      final station = smelter();
      final bag = bagWith(ore: 10, coal: 2);
      final spilled = spillsInto();
      final cancelled = <List<Object>>[];
      station.workstation.productionCancelled.connect(cancelled.add);

      expect(station.workstation.startProduction(recipe('t1_item_bar_copper'), 1, bag),
          isTrue);
      expect(station.workstation.startProduction(recipe('t1_item_bar_copper'), 1, bag),
          isTrue);

      // The first batch's 5 ore + 1 coal came back onto the ground; the second
      // batch took the bag's other 5 + 1.
      expect(cancelled, hasLength(1));
      expect(
        spilled.map((p) => '${p.amount}× ${p.itemData.id}'),
        <String>['5× t1_item_ore_copper', '1× t1_item_coal'],
      );
      expect(bag.countOf('t1_item_ore_copper'), 0);
      expect(station.workstation.remainingQuantity, 1);
    });
  });

  group('the tick', () {
    test("progress counts against the station's own speed", () {
      final station = smelter();
      station.workstation
          .startProduction(recipe('t1_item_bar_copper'), 1, bagWith(ore: 5, coal: 1));
      final progress = <(int, int, double)>[];
      station.workstation.productionProgress.connect(progress.add);

      // craft_time 2.0 at speed ×2 = one second a bar. Half a second: half.
      station.update(0.5);

      expect(progress.single, (1, 1, 0.5));
      expect(station.workstation.isProducing, isTrue);
    });

    test('each finished unit lands in front of the station, and the batch '
        'closes on the last one', () {
      final station = smelter();
      station.workstation
          .startProduction(recipe('t1_item_bar_copper'), 2, bagWith(ore: 10, coal: 2));
      final spilled = spillsInto();
      final produced = <(ItemCraftableData, int)>[];
      station.workstation.itemProduced.connect(produced.add);
      var completed = 0;
      station.workstation.productionCompleted.connect(() => completed++);
      final progress = <(int, int, double)>[];
      station.workstation.productionProgress.connect(progress.add);

      station.update(1);
      expect(spilled.map((p) => p.itemData.id), <String>['t1_item_bar_copper']);
      expect(produced.single.$2, 1, reason: 'one left');
      expect(completed, 0);
      expect(station.workstation.remainingQuantity, 1);
      expect(station.workstation.currentProgress, 0, reason: 'the bench is cleared');
      expect(
        station.workstationData.allocatedMaterials.map((m) => m.amount),
        <int>[5, 1],
        reason: "one unit's share eaten",
      );

      station.update(1);
      expect(spilled, hasLength(2));
      expect(progress.map((p) => p.$1), <int>[1, 2],
          reason: 'the PORT DELTA: unit 1 of 2, then unit 2 of 2 — not 1 of 1 twice');
      expect(completed, 1);
      expect(station.workstation.isProducing, isFalse);
      expect(station.workstationData.allocatedMaterials, isEmpty);

      // Produce lands at the station's FACE — below its footprint, never on it.
      final grid = locator<GridManager>();
      final stationTile = grid.worldToGrid(station.position);
      for (final pickup in spilled) {
        final tile = grid.worldToGrid(pickup.position);
        expect(tile.y, greaterThan(stationTile.y));
      }
    });

    test('an idle station ticks for free', () {
      final station = smelter();
      final progress = <(int, int, double)>[];
      station.workstation.productionProgress.connect(progress.add);
      station.update(1);
      expect(progress, isEmpty);
    });
  });

  group('cancel and death', () {
    test('cancelling mid-batch gives back only what was not yet eaten', () {
      final station = smelter();
      station.workstation
          .startProduction(recipe('t1_item_bar_copper'), 3, bagWith(ore: 15, coal: 3));
      station.update(1); // one bar out
      final spilled = spillsInto();

      station.workstation.cancelProduction();

      expect(
        spilled.map((p) => '${p.amount}× ${p.itemData.id}'),
        <String>['10× t1_item_ore_copper', '2× t1_item_coal'],
      );
      expect(station.workstation.isProducing, isFalse);
    });

    test('cancelling an idle station is nothing, not an error', () {
      final station = smelter();
      final spilled = spillsInto();
      station.workstation.cancelProduction();
      expect(spilled, isEmpty);
    });

    test('a station that breaks mid-batch spills the batch before its corpse', () {
      final station = smelter();
      final at = locator<GridManager>().worldToGrid(station.position);
      locator<GridManager>().occupyPropTiles(at, station);
      station.workstation
          .startProduction(recipe('t1_item_bar_copper'), 1, bagWith(ore: 5, coal: 1));
      final spilled = spillsInto();
      final despawned = <Object>[];
      locator<Events>().worldObjectDespawned.connect(despawned.add);
      final smith = ActorFactory.create('t1_actor_probe_player', WorldPos.zero)
        ..inventory.setSlot(
          0,
          locator<ItemRegistry>().getItem('t1_item_tool_sledgehammer'),
          1,
        );

      expect(station.takeDamage(10, smith), isTrue);

      expect(
        spilled.map((p) => '${p.amount}× ${p.itemData.id}'),
        <String>['5× t1_item_ore_copper', '1× t1_item_coal'],
      );
      expect(despawned, <Object>[station]);
      expect(locator<GridManager>().getPropAt(at), isNull);
    });
  });

  test('the soul is the only place the state lives (rule 8)', () {
    final station = smelter();
    station.workstation
        .startProduction(recipe('t1_item_bar_copper'), 2, bagWith(ore: 10, coal: 2));
    station.update(0.25);

    final saved = station.workstationData.serialize();
    expect(saved['current_recipe_id'], 't1_item_bar_copper');
    expect(saved['initial_quantity'], 2);
    expect(saved['remaining_quantity'], 2);
    expect(saved['current_progress'], 0.25);
    expect(
      saved['allocated_materials'],
      <Map<String, Object?>>[
        <String, Object?>{'item_id': 't1_item_ore_copper', 'amount': 10},
        <String, Object?>{'item_id': 't1_item_coal', 'amount': 2},
      ],
    );

    // A clone carries the batch, and its lines are its own.
    final copy = station.workstationData.clone()..completeUnit();
    expect(copy.remainingQuantity, 1);
    expect(station.workstationData.remainingQuantity, 2);
    expect(station.workstationData.allocatedMaterials.first.amount, 10);
    expect(copy.allocatedMaterials.first.amount, 5);

    // And a template from the registry is idle: PropData, never producing.
    final template = locator<PropRegistry>().getProp('t1_prop_workstation_smelter');
    expect(template, isA<PropData>());
    expect((template as PropWorkstationData).isProducing, isFalse);
  });
}
