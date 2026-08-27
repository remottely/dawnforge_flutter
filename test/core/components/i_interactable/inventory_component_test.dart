import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/factories/actor_factory.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/inventory/inventory_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.2a: slot state lives in the actor's data soul; the component is the
/// behavior over it (add/remove/reserve/swap), driven by InventoryRules.
void main() {
  setUp(() {
    registerCoreSystems();
    locator<ActorRegistry>().registerJson(<String, Object?>{
      'id': 't1_actor_probe',
      'inventory_size': 3,
    });
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_pebble',
      'max_stack': 10,
    });
    locator<ItemRegistry>().registerJson(<String, Object?>{
      'id': 't1_item_hand_axe',
      'max_stack': 1,
    });
  });
  tearDown(resetCoreSystems);

  ItemData item(String id) => locator<ItemRegistry>().getItem(id);

  (InventoryComponent, IActorData) buildInventory() {
    // The factory-assembled component (FP4.1c: every actor is a collector).
    final actor = ActorFactory.create('t1_actor_probe', WorldPos.zero);
    return (actor.inventory, actor.data as IActorData);
  }

  test('adds stack-first, then empty slots, and returns what did not fit', () {
    final (inventory, _) = buildInventory();
    final pebble = item('t1_item_pebble');

    expect(inventory.addItem(pebble, 4), 0);
    expect(inventory.slots[0].amount, 4);

    // Tops the existing stack up to 10 before opening a second slot.
    expect(inventory.addItem(pebble, 9), 0);
    expect(inventory.slots[0].amount, 10);
    expect(inventory.slots[1].amount, 3);

    // Capacity is 3 slots × 10: adding 20 more fits 17, hands 3 back.
    expect(inventory.addItem(pebble, 20), 3);
    expect(inventory.countOf('t1_item_pebble'), 30);
  });

  test('onlyExistingStacks never opens a new slot', () {
    final (inventory, _) = buildInventory();
    final pebble = item('t1_item_pebble');

    expect(inventory.addItem(pebble, 5, onlyExistingStacks: true), 5);
    expect(inventory.container.hasAnyItem, isFalse);

    inventory.addItem(pebble, 8);
    expect(inventory.addItem(pebble, 5, onlyExistingStacks: true), 3);
  });

  test('a max_stack-1 item takes one slot each and never merges', () {
    final (inventory, _) = buildInventory();
    final axe = item('t1_item_hand_axe');

    expect(inventory.addItem(axe, 1), 0);
    expect(inventory.addItem(axe, 1), 0);
    expect(inventory.slots[0].amount, 1);
    expect(inventory.slots[1].amount, 1);
    expect(inventory.countOf('t1_item_hand_axe'), 2);
  });

  test('removeItem is all-or-nothing and clears emptied slots', () {
    final (inventory, _) = buildInventory();
    final pebble = item('t1_item_pebble');
    inventory.addItem(pebble, 12); // [10, 2, _]

    expect(inventory.removeItem(pebble, 13), isFalse,
        reason: 'holding 12, a removal of 13 is refused whole');
    expect(inventory.countOf('t1_item_pebble'), 12);

    // Takes 10 from slot 0 (which empties and clears) and 1 from slot 1.
    expect(inventory.removeItem(pebble, 11), isTrue);
    expect(inventory.countOf('t1_item_pebble'), 1);
    expect(inventory.slots[0].isEmpty, isTrue);
    expect(inventory.slots[1].amount, 1);
  });

  test('reservations promise space to in-flight pickups', () {
    final (inventory, _) = buildInventory();
    final pebble = item('t1_item_pebble');
    inventory.addItem(pebble, 20); // space left: 10

    expect(inventory.reserveSpace(pebble, 6), isTrue);
    expect(inventory.reserveSpace(pebble, 5), isFalse,
        reason: '10 real minus 6 promised cannot cover 5');

    // The landed pickup consumes its promise: space 4, pending 0.
    inventory.addItem(pebble, 6);
    expect(inventory.reserveSpace(pebble, 4), isTrue);

    inventory.releaseReservation(pebble, 4);
    expect(inventory.reserveSpace(pebble, 4), isTrue);
  });

  test('swap moves contents between slots, signals fire', () {
    final (inventory, _) = buildInventory();
    final pebble = item('t1_item_pebble');
    final changed = <int>[];
    inventory.slotChanged.connect(changed.add);

    inventory.addItem(pebble, 3);
    changed.clear();
    inventory.swapSlots(0, 2);

    expect(inventory.slots[0].isEmpty, isTrue);
    expect(inventory.slots[2].amount, 3);
    expect(changed, [0, 2]);
    expect(inventory.findEmptySlot(), 0);
  });

  test('state lives in the data soul: serialize and clone carry it', () {
    final (inventory, soul) = buildInventory();

    // An untouched inventory adds nothing to the save envelope.
    expect(soul.serialize().containsKey('inventory'), isFalse);

    inventory.addItem(item('t1_item_pebble'), 7);
    final envelope = soul.serialize();
    final restored = InventoryData.deserialize(
      envelope['inventory']! as Map<String, Object?>,
    );
    expect(restored.countOf('t1_item_pebble'), 7);
    expect(restored.slotCount, 3);

    // The clone owns its state (rule 3): mutating the original never leaks.
    final cloned = soul.clone();
    inventory.addItem(item('t1_item_pebble'), 3);
    expect(soul.inventory.countOf('t1_item_pebble'), 10);
    expect(cloned.inventory.countOf('t1_item_pebble'), 7);
  });

  test('a non-actor host refuses the component (storage props come later)',
      () {
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_probe_box',
    });
    final prop = PropFactory.create('t1_prop_probe_box', WorldPos.zero);
    final component = prop.addComponent(InventoryComponent());
    expect(() => component.container, throwsA(isA<AssertionError>()));
  });

  // ============================================
  // FP4.2b — the slot-addressed verbs the drag path drives
  // ============================================

  test('setSlot writes one slot outright and announces exactly it', () {
    final (inventory, _) = buildInventory();
    final announced = <int>[];
    inventory.slotChanged.connect(announced.add);

    inventory.setSlot(2, item('t1_item_pebble'), 4);

    expect(inventory.slots[2].itemId, 't1_item_pebble');
    expect(inventory.slots[2].amount, 4);
    expect(announced, <int>[2],
        reason: 'a write to one slot must not fan out over the others');

    inventory.clearSlot(2);
    expect(inventory.slots[2].isEmpty, isTrue);
  });

  test('removeItemAtIndex hands back what left, and null for an empty slot',
      () {
    final (inventory, _) = buildInventory();
    inventory.setSlot(0, item('t1_item_pebble'), 5);

    final taken = inventory.removeItemAtIndex(0, 2);
    expect(taken?.itemId, 't1_item_pebble');
    expect(taken?.amount, 2);
    expect(inventory.slots[0].amount, 3);

    // Asking for more than the slot holds takes what is there, not a refusal:
    // this is the hand-out path, and the caller learns the real number back.
    final rest = inventory.removeItemAtIndex(0, 99);
    expect(rest?.amount, 3);
    expect(inventory.slots[0].isEmpty, isTrue);

    // An empty slot is a legitimate state of any container being dragged
    // across, so it answers null rather than failing (rule 20).
    expect(inventory.removeItemAtIndex(0, 1), isNull);
  });

  test('mergeStacks folds what fits and leaves the remainder behind', () {
    final (inventory, _) = buildInventory();
    inventory
      ..setSlot(0, item('t1_item_pebble'), 7)
      ..setSlot(1, item('t1_item_pebble'), 6);

    // max_stack is 10: six of the seven fit, one stays home.
    expect(inventory.mergeStacks(0, 1), isTrue);
    expect(inventory.slots[1].amount, 10);
    expect(inventory.slots[0].amount, 3);

    // A full destination refuses instead of silently dropping the source.
    inventory.setSlot(2, item('t1_item_pebble'), 10);
    expect(inventory.mergeStacks(0, 2), isFalse);
    expect(inventory.slots[0].amount, 3);

    // Different items never merge — that pairing is a swap, and swapSlots
    // owns it.
    inventory.setSlot(2, item('t1_item_hand_axe'), 1);
    expect(inventory.mergeStacks(0, 2), isFalse);

    // An empty destination takes the stack whole.
    inventory.clearSlot(2);
    expect(inventory.mergeStacks(0, 2), isTrue);
    expect(inventory.slots[2].amount, 3);
    expect(inventory.slots[0].isEmpty, isTrue);
  });

  test('merging into itself is refused, never a stack duplicated', () {
    final (inventory, _) = buildInventory();
    inventory.setSlot(0, item('t1_item_pebble'), 4);
    expect(inventory.mergeStacks(0, 0), isFalse);
    expect(inventory.slots[0].amount, 4);
  });

  test('transferTo resolves the three cross-container outcomes', () {
    final (source, _) = buildInventory();
    final (target, _) = buildInventory();
    final pebble = item('t1_item_pebble');

    // 1. Empty destination takes what was asked for, and only that.
    source.setSlot(0, pebble, 8);
    expect(source.transferTo(target, 0, 0, 3), isTrue);
    expect(target.slots[0].amount, 3);
    expect(source.slots[0].amount, 5);

    // 2. Matching destination absorbs what fits, capped by max_stack (10).
    expect(source.transferTo(target, 0, 0, 5), isTrue);
    expect(target.slots[0].amount, 8);
    expect(source.slots[0].isEmpty, isTrue);

    // A full destination of the same item moves nothing and says so.
    source.setSlot(0, pebble, 4);
    target.setSlot(0, pebble, 10);
    expect(source.transferTo(target, 0, 0, 4), isFalse);
    expect(source.slots[0].amount, 4);

    // 3. Different items trade places whole — [amount] is ignored, because
    // half a swap would need a third slot for the remainder.
    target.setSlot(1, item('t1_item_hand_axe'), 1);
    expect(source.transferTo(target, 0, 1, 1), isTrue);
    expect(target.slots[1].itemId, 't1_item_pebble');
    expect(target.slots[1].amount, 4);
    expect(source.slots[0].itemId, 't1_item_hand_axe');
    expect(source.slots[0].amount, 1);
  });

  test('transferTo from an empty slot moves nothing', () {
    final (source, _) = buildInventory();
    final (target, _) = buildInventory();
    target.setSlot(0, item('t1_item_pebble'), 2);

    expect(source.transferTo(target, 0, 0, 1), isFalse);
    expect(target.slots[0].amount, 2,
        reason: 'a transfer that moved nothing must not touch the target');
  });

  test('transferTo refuses a container to itself — that is mergeStacks', () {
    final (inventory, _) = buildInventory();
    inventory.setSlot(0, item('t1_item_pebble'), 2);
    expect(
      () => inventory.transferTo(inventory, 0, 1, 1),
      throwsA(isA<AssertionError>()),
    );
  });
}
