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
}
