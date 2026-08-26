import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/components/i_world_object/drop_component.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.1c: the component rolls its host's authored table with an injected
/// RNG and scatters real pickups through WorldDropHelper.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_stone_probe',
      'max_stack': 10,
    });
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_rock_probe',
      'drops': <Map<String, Object?>>[
        <String, Object?>{
          'item_id': 't1_item_stone_probe',
          'chance': 1.0,
          'min_amount': 2,
          'max_amount': 2,
        },
      ],
    });
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_bare_probe',
    });
    // Walkable ground around the drop source so every landing resolves.
    final grid = locator<GridManager>();
    for (var x = -3; x <= 3; x++) {
      for (var y = -3; y <= 3; y++) {
        grid.registerGroundData(
          GridPos(x, y),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      }
    }
  });
  tearDown(resetCoreSystems);

  test('rolls the authored table and spawns pickups on walkable ground', () {
    final prop = PropFactory.create('t1_prop_rock_probe', WorldPos.zero);
    final drop = prop.addComponent(DropComponent(Random(20260826)));

    final spawned = <ItemWorld>[];
    locator<Events>().pickupSpawned.connect((p) => spawned.add(p as ItemWorld));
    final dropped = <List<(ItemData, int)>>[];
    drop.itemsDropped.connect(dropped.add);

    final center = locator<GridManager>().gridToWorld(const GridPos(0, 0));
    drop.dropItems(center);

    expect(spawned, hasLength(1));
    expect(spawned.single.itemData.id, 't1_item_stone_probe');
    expect(spawned.single.amount, 2);
    expect(dropped.single.single.$2, 2);
    // The landing is a walkable tile at the source's own height.
    final landingTile =
        locator<GridManager>().worldToGrid(spawned.single.position);
    expect(locator<GridManager>().isTileWalkable(landingTile), isTrue);
  });

  test('the same seed rolls the same drops — the sim owns randomness', () {
    final center = locator<GridManager>().gridToWorld(const GridPos(0, 0));

    List<WorldPos> run() {
      final positions = <WorldPos>[];
      final unsub = locator<Events>()
          .pickupSpawned
          .connect((p) => positions.add((p as ItemWorld).position));
      PropFactory.create('t1_prop_rock_probe', WorldPos.zero)
          .addComponent(DropComponent(Random(7)))
          .dropItems(center);
      unsub();
      return positions;
    }

    expect(run(), run());
  });

  test('an empty authored table drops nothing and emits nothing', () {
    final prop = PropFactory.create('t1_prop_bare_probe', WorldPos.zero);
    final drop = prop.addComponent(DropComponent(Random(1)));

    var spawns = 0;
    locator<Events>().pickupSpawned.connect((_) => spawns++);
    var emissions = 0;
    drop.itemsDropped.connect((_) => emissions++);

    drop.dropItems(WorldPos.zero);

    expect(spawns, 0);
    expect(emissions, 0, reason: 'empty is authored silence, not an event');
  });
}
