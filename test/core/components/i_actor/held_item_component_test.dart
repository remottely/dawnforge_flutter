import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.3a slice 3: the selected hotbar slot IS the item in hand, and an empty
/// slot is not an empty hand for a player. Every case here is a question the
/// damage verb (slice 5) will ask this component before it swings.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ItemRegistry>()
      ..registerJson(<String, Object?>{'id': 't1_item_pebble', 'max_stack': 10})
      ..registerJson(<String, Object?>{'id': 't1_item_twig', 'max_stack': 10})
      // The two innate weapons the pack really carries, by their real ids: the
      // player's bare hands and the boar's tusks.
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_hand',
        'tool_type': 'INNATE',
      })
      ..registerJson(<String, Object?>{
        'id': 't1_item_tool_melee_boar',
        'tool_type': 'INNATE',
      });

    locator<ActorRegistry>()
      // A player: authored into the `player` group, with the 30-slot bag.
      ..registerJson(<String, Object?>{
        'id': 't1_actor_probe_player',
        'groups': <String>['player'],
        'inventory_size': 30,
      })
      // A creature: no bag at all (the boar authors `inventory_size: 0`), one
      // authored weapon it was born with.
      ..registerJson(<String, Object?>{
        'id': 't1_actor_probe_boar',
        'inventory_size': 0,
        'held_item_id': 't1_item_tool_melee_boar',
      })
      // Neither: the shape both forest guardians author today — a bag they
      // start empty, and no weapon of their own.
      ..registerJson(<String, Object?>{
        'id': 't1_actor_probe_guardian',
        'inventory_size': 15,
      });
  });
  tearDown(resetCoreSystems);

  IActor spawn(String id) => ActorFactory.create(id, WorldPos.zero);

  ItemData item(String id) => locator<ItemRegistry>().getItem(id);

  /// Records every announcement, so a test can prove not only WHAT the hand
  /// became but how many times it said so.
  List<String?> watch(IActor actor) {
    final seen = <String?>[];
    actor.heldItem.currentItemChanged.connect((held) => seen.add(held?.id));
    return seen;
  }

  group('the selected slot is the hand', () {
    test('selecting a slot with an item puts that item in hand, once', () {
      final actor = spawn('t1_actor_probe_player');
      actor.inventory.setSlot(4, item('t1_item_pebble'), 3);
      final seen = watch(actor);

      actor.inventory.selectSlot(4);

      expect(actor.heldItem.currentItem?.id, 't1_item_pebble');
      expect(seen, <String?>['t1_item_pebble']);
    });

    test('the selected slot changing UNDER the selection changes the hand', () {
      // The second half of what `selectionChanged` means (0.24.0), and the
      // half a hand cannot live without: the selection never moved here, the
      // item under it did.
      final actor = spawn('t1_actor_probe_player');
      actor.inventory.selectSlot(2);
      final seen = watch(actor);

      actor.inventory.setSlot(2, item('t1_item_twig'), 1);
      expect(actor.heldItem.currentItem?.id, 't1_item_twig');

      actor.inventory.clearSlot(2);
      expect(actor.heldItem.currentItem?.id, 't1_item_tool_melee_hand');

      expect(seen, <String?>['t1_item_twig', 't1_item_tool_melee_hand']);
    });

    test('moving between two slots holding the same item says nothing', () {
      // The spec's redundancy check: a hand that did not change is not a
      // held-item change, and every listener downstream pays for the ones
      // that lie.
      final actor = spawn('t1_actor_probe_player');
      actor.inventory
        ..setSlot(0, item('t1_item_pebble'), 1)
        ..setSlot(1, item('t1_item_pebble'), 9)
        ..selectSlot(0);
      final seen = watch(actor);

      actor.inventory.selectSlot(1);

      expect(actor.heldItem.currentItem?.id, 't1_item_pebble');
      expect(seen, isEmpty, reason: 'same item, so the hand did not change');
    });
  });

  group('the innate hand', () {
    test('a player with an empty slot holds BARE HANDS, never nothing', () {
      final actor = spawn('t1_actor_probe_player');

      final held = actor.heldItem.currentItem;
      expect(held?.id, 't1_item_tool_melee_hand');
      expect(held?.toolType, ToolType.innate,
          reason: 'bare hands are a real tool — the one harvest starts with');
    });

    test('a creature holds what it was authored with, and owns no bag', () {
      final actor = spawn('t1_actor_probe_boar');

      expect(actor.inventory.maxSlots, 0);
      expect(actor.heldItem.currentItem?.id, 't1_item_tool_melee_boar');
    });

    test('an actor with neither a bag nor an authored weapon holds nothing',
        () {
      final actor = spawn('t1_actor_probe_guardian');

      expect(actor.heldItem.currentItem, isNull);
    });
  });
}
