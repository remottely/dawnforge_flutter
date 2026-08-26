import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/domain/inventory/inventory_rules.dart';
import 'package:dawnforge/src/core/resources/inventory/inventory_data.dart';
import 'package:dawnforge/src/core/resources/inventory/item_stack.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// Slot-based storage behavior — port of `inventory_component.gd` (logic
/// slice: the creative `infinite` switch, unique-instance duplication and
/// durability restore arrive with their systems). All slot state lives in the
/// data soul (`IActorData.inventory`, rule 8); this component is the behavior
/// over it, driven by `InventoryRules`.
///
/// A `maxStack == 1` item never merges — `spaceForMatchingStack(1, 1)` is 0 —
/// so uniques take one slot each with no special casing here.
final class InventoryComponent extends IComponent {
  final inventoryChanged = EventSignal0();
  final slotChanged = EventSignal<int>();
  final itemAdded = EventSignal<(ItemData, int)>();
  final itemRemoved = EventSignal<(ItemData, int)>();

  /// Space promised to in-transit items (a pickup mid-magnet-flight), keyed
  /// by item id. Transit bookkeeping, never serialized — a legitimate
  /// component local under rule 8.
  final Map<String, int> _reservedSpace = <String, int>{};

  /// The container state. Actors are the only inventory owners today; the
  /// cast is the declared contract, asserted (rule 18).
  InventoryData get container {
    final soul = data;
    assert(
      soul is IActorData,
      '[InventoryComponent] host ${soul.id} is not an actor — storage props '
      'lift InventoryData up the hierarchy when they arrive',
    );
    return (soul as IActorData).inventory;
  }

  List<ItemStack> get slots => container.slots;

  int get maxSlots => container.slotCount;

  /// Adds [amount] of [item], stacking into matching slots first, then into
  /// empty ones (skipped under [onlyExistingStacks]). Returns what did NOT
  /// fit — 0 is complete success, and the caller owes the remainder to
  /// whatever produced it.
  int addItem(ItemData item, int amount, {bool onlyExistingStacks = false}) {
    assert(amount > 0, '[InventoryComponent] addItem amount $amount');
    var remaining = amount;

    for (var i = 0; i < maxSlots && remaining > 0; i++) {
      final stack = slots[i];
      if (stack.isEmpty || !InventoryRules.areIdsEqual(stack.itemId, item.id)) {
        continue;
      }
      final transfer = InventoryRules.calculateStackTransfer(
        remaining,
        stack.amount,
        item.maxStack,
      );
      if (transfer > 0) {
        stack.amount += transfer;
        remaining -= transfer;
        slotChanged.emit(i);
      }
    }

    if (!onlyExistingStacks) {
      for (var i = 0; i < maxSlots && remaining > 0; i++) {
        final stack = slots[i];
        if (!stack.isEmpty) continue;
        final transfer =
            InventoryRules.calculateEmptySlotTransfer(remaining, item.maxStack);
        stack
          ..itemId = item.id
          ..amount = transfer;
        remaining -= transfer;
        slotChanged.emit(i);
      }
    }

    if (remaining < amount) {
      _commitReservation(item.id, amount - remaining);
      inventoryChanged.emit();
      itemAdded.emit((item, amount - remaining));
    }
    return remaining;
  }

  /// Removes [amount] of [item]. All-or-nothing: refuses (false) when the
  /// container holds less — a refusal the caller reads, not a fallback.
  bool removeItem(ItemData item, int amount) {
    assert(amount > 0, '[InventoryComponent] removeItem amount $amount');
    if (container.countOf(item.id) < amount) return false;

    var remaining = amount;
    for (var i = 0; i < maxSlots && remaining > 0; i++) {
      final stack = slots[i];
      if (stack.isEmpty || !InventoryRules.areIdsEqual(stack.itemId, item.id)) {
        continue;
      }
      final take = InventoryRules.calculateTake(remaining, stack.amount);
      stack.amount -= take;
      remaining -= take;
      if (stack.amount <= 0) stack.clear();
      slotChanged.emit(i);
    }

    inventoryChanged.emit();
    itemRemoved.emit((item, amount));
    return true;
  }

  int countOf(String itemId) => container.countOf(itemId);

  bool hasItem(String itemId, int amount) => countOf(itemId) >= amount;

  /// How many units of [item] this container could still take.
  int availableSpaceFor(ItemData item, {bool onlyExistingStacks = false}) {
    var space = 0;
    for (final stack in slots) {
      if (stack.isEmpty) {
        space += InventoryRules.spaceForEmptySlot(
          item.maxStack,
          onlyExistingStacks: onlyExistingStacks,
        );
      } else if (InventoryRules.areIdsEqual(stack.itemId, item.id)) {
        space += InventoryRules.spaceForMatchingStack(
          item.maxStack,
          stack.amount,
        );
      }
    }
    return space;
  }

  /// Atomically reserves space for an in-transit item (a pickup that started
  /// its magnet flight). False when the space, minus what is already
  /// promised, cannot cover [amount].
  bool reserveSpace(ItemData item, int amount) {
    final pending = _reservedSpace[item.id] ?? 0;
    if (!InventoryRules.canReserve(availableSpaceFor(item), pending, amount)) {
      return false;
    }
    _reservedSpace[item.id] = pending + amount;
    return true;
  }

  /// Releases a reservation whose collection was cancelled or failed.
  void releaseReservation(ItemData item, int amount) {
    final pending = _reservedSpace[item.id];
    if (pending == null) return;
    final next = InventoryRules.decrementReservation(pending, amount);
    if (next <= 0) {
      _reservedSpace.remove(item.id);
    } else {
      _reservedSpace[item.id] = next;
    }
  }

  void _commitReservation(String itemId, int amount) {
    final pending = _reservedSpace[itemId];
    if (pending == null) return;
    final next = InventoryRules.decrementReservation(pending, amount);
    if (next <= 0) {
      _reservedSpace.remove(itemId);
    } else {
      _reservedSpace[itemId] = next;
    }
  }

  /// Swaps two slots' contents (a drag in the UI). Swapping a slot with
  /// itself is a no-op the caller never needs to guard.
  void swapSlots(int a, int b) {
    assert(
      a >= 0 && a < maxSlots && b >= 0 && b < maxSlots,
      '[InventoryComponent] swap $a<->$b outside 0..${maxSlots - 1}',
    );
    if (a == b) return;
    final stackA = slots[a];
    slots[a] = slots[b];
    slots[b] = stackA;
    slotChanged
      ..emit(a)
      ..emit(b);
    inventoryChanged.emit();
  }

  /// The first empty slot, or -1 when the container is full — fullness is a
  /// legitimate answer, asked before adds that must not spill.
  int findEmptySlot() {
    for (var i = 0; i < maxSlots; i++) {
      if (slots[i].isEmpty) return i;
    }
    return -1;
  }
}
