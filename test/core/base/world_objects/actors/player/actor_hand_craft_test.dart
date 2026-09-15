import 'package:dawnforge/src/core/base/world_objects/actors/player/actor_player.dart';
import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.5(f), third slice: the hand-craft (`D-2`). A player is a bench of type
/// NONE at speed 1.0, which is what `crafted_at: NONE` has always meant in the
/// pack — so the same component, the same sequence and the same signals serve
/// two hands and a smelter alike.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{'id': 't1_item_log', 'max_stack': 100})
      ..registerJson(<String, Object?>{'id': 't1_item_ore', 'max_stack': 100})
      // What a pair of hands makes: the pack authors the smelter this way.
      ..registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_buildable_smelter',
        'max_stack': 1,
        'crafted_at': 'NONE',
        'craft_time': 2.0,
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_log', 'amount': 2},
        ],
      })
      // What they do not: a bench recipe belongs to the bench.
      ..registerJson(<String, Object?>{
        'type': 'item_craftable_data',
        'id': 't1_item_bar_copper',
        'crafted_at': 'SMELTER',
        'ingredients': <Map<String, Object?>>[
          <String, Object?>{'id': 't1_item_ore', 'amount': 1},
        ],
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
      });
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe_player',
      'groups': <String>['player'],
      'inventory_size': 4,
    });
  });
  tearDown(resetCoreSystems);

  ActorPlayer player() =>
      ActorFactory.create('t1_actor_probe_player', WorldPos.zero)
          as ActorPlayer;

  ItemCraftableData recipe(String id) =>
      locator<ItemRegistry>().getItem(id) as ItemCraftableData;

  List<ItemWorld> spillsInto() {
    final spawned = <ItemWorld>[];
    locator<Events>().pickupSpawned.connect((p) => spawned.add(p as ItemWorld));
    return spawned;
  }

  test('a player IS a bench, of the kind that needs no bench', () {
    final actor = player();

    expect(actor.actorData.productionType, WorkstationType.none);
    expect(actor.actorData.productionSpeedMultiplier, 1.0,
        reason: 'hands are the speed every multiplier is measured against');
    expect(actor.handCraft.workstationData, same(actor.actorData),
        reason: 'the batch lives on the soul, like all state (rule 8)');
  });

  test('the hands offer the NONE recipes and refuse the bench ones', () {
    final actor = player();

    expect(
      actor.handCraft.availableRecipes().map((r) => r.id),
      <String>['t1_item_buildable_smelter'],
    );
    expect(actor.handCraft.workstationData.canUseRecipe(recipe('t1_item_bar_copper')),
        isFalse);
  });

  test('what the hands make lands in the bag, not on the ground', () {
    final actor = player();
    final items = locator<ItemRegistry>();
    actor.inventory.setSlot(0, items.getItem('t1_item_log'), 2);
    final spilled = spillsInto();

    expect(
      actor.handCraft.startProduction(
        recipe('t1_item_buildable_smelter'),
        1,
        actor.inventory,
      ),
      isTrue,
    );
    expect(actor.inventory.countOf('t1_item_log'), 0, reason: 'paid up front');

    // Two seconds at speed 1.0 — no bench to make it faster.
    actor.handCraft.update(2);

    expect(actor.inventory.countOf('t1_item_buildable_smelter'), 1);
    expect(spilled, isEmpty,
        reason: 'there is no station to drop it in front of (D-2)');
    expect(actor.handCraft.isProducing, isFalse);
  });

  test('what will not fit falls at the feet rather than being eaten', () {
    final actor = player();
    final items = locator<ItemRegistry>();
    // Every slot taken by something else, and the logs in the last one.
    actor.inventory
      ..setSlot(0, items.getItem('t1_item_ore'), 1)
      ..setSlot(1, items.getItem('t1_item_ore'), 1)
      ..setSlot(2, items.getItem('t1_item_ore'), 1)
      ..setSlot(3, items.getItem('t1_item_log'), 2);
    final spilled = spillsInto();

    actor.handCraft
      ..startProduction(recipe('t1_item_buildable_smelter'), 1, actor.inventory)
      ..update(2);

    // The logs left slot 3 to pay, so the smelter has a pocket after all.
    expect(actor.inventory.countOf('t1_item_buildable_smelter'), 1);
    expect(spilled, isEmpty);
  });

  test('the hands cannot be paid for what the player does not have', () {
    final actor = player();

    expect(
      actor.handCraft.startProduction(
        recipe('t1_item_buildable_smelter'),
        1,
        actor.inventory,
      ),
      isFalse,
      reason: 'a refusal a caller reads, never a crash (rule 20)',
    );
    expect(actor.handCraft.isProducing, isFalse);
  });

  test('a cancelled batch gives the logs back', () {
    final actor = player();
    actor.inventory
        .setSlot(0, locator<ItemRegistry>().getItem('t1_item_log'), 2);
    final spilled = spillsInto();

    actor.handCraft
      ..startProduction(recipe('t1_item_buildable_smelter'), 1, actor.inventory)
      ..cancelProduction();

    // A refund has no bench to land in front of either, so it comes back the
    // one way the hands know: the same wire the finished item uses.
    expect(actor.inventory.countOf('t1_item_log'), 2);
    expect(spilled, isEmpty);
  });
}
