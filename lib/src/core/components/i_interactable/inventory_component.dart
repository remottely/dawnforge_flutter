import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/domain/inventory/inventory_rules.dart';
import 'package:dawnforge/src/core/domain/inventory/inventory_sort_rules.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/inventory/inventory_data.dart';
import 'package:dawnforge/src/core/resources/inventory/item_stack.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
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

  // ============================================
  // SELECTION (FP4.2b) — the slot in hand
  // ============================================

  /// Raised when the selection MOVED, and when the selected slot's CONTENTS
  /// changed under it. Both are the same news to a listener: what the actor is
  /// holding is now something else. Emitting only on movement is how the spec
  /// once left a player holding an item that had already left the slot.
  final selectionChanged = EventSignal<int>();

  int get selectedSlot => container.selectedSlot;

  /// The stack in hand — empty when the selected slot is.
  ItemStack get selectedStack => slots[selectedSlot];

  /// Points the container at [index]. Out of range is refused rather than
  /// clamped: every caller derives the index from a page it just measured, so
  /// an out-of-range one is a page-math bug and clamping would hide it.
  void selectSlot(int index) {
    assert(
      index >= 0 && index < maxSlots,
      '[InventoryComponent] select $index outside 0..${maxSlots - 1}',
    );
    if (index == container.selectedSlot) return;
    container.selectedSlot = index;
    selectionChanged.emit(index);
  }

  /// The one place a slot's change is announced. Every mutator goes through
  /// it so that "the selected slot's contents moved" cannot be reported by
  /// some paths and not others.
  void _announceSlot(int index) {
    slotChanged.emit(index);
    if (index == container.selectedSlot) selectionChanged.emit(index);
  }

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
        _announceSlot(i);
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
        _announceSlot(i);
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
      _announceSlot(i);
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
    _announceSlot(a);
    _announceSlot(b);
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

  // ============================================
  // SLOT-ADDRESSED VERBS (FP4.2b)
  // ============================================
  // `addItem` picks the slot itself. Everything the player does with a bag
  // open picks it instead — this stack, onto that one — and before these
  // existed the only way to say so was to reach into `slots` from outside.
  // The Godot spec learned that the hard way: its drag path was mutating two
  // containers by hand. Placement is the caller's decision; the bookkeeping
  // and every announcement of it belong here.

  /// A slot's item, resolved through the registry (rule 2 — the slot stores
  /// the id, never the resource, so the container never holds a second copy
  /// of authored data that could drift from the registry's).
  ItemData _itemOf(ItemStack stack) {
    assert(!stack.isEmpty, '[InventoryComponent] _itemOf on an empty slot');
    return locator<ItemRegistry>().getItem(stack.itemId);
  }

  bool _isSlot(int index) => index >= 0 && index < maxSlots;

  ItemStack itemAtSlot(int index) {
    assert(_isSlot(index), '[InventoryComponent] slot $index outside 0..$maxSlots');
    return slots[index];
  }

  /// Writes one slot outright and announces it.
  ///
  /// Returns nothing, unlike the spec's `set_slot`: there the bool reports a
  /// refusal only a creative `infinite` catalogue can produce, and creative
  /// mode is not ported. It comes back with `infinite`, not before — a bool
  /// whose false arm is unreachable is a branch that lies to its callers.
  void setSlot(int index, ItemData item, int amount) {
    assert(_isSlot(index), '[InventoryComponent] setSlot $index outside 0..$maxSlots');
    assert(amount > 0, '[InventoryComponent] setSlot amount $amount — use clearSlot');
    slots[index]
      ..itemId = item.id
      ..amount = amount;
    _announceSlot(index);
    inventoryChanged.emit();
  }

  /// Empties one slot and announces it.
  void clearSlot(int index) {
    assert(_isSlot(index), '[InventoryComponent] clearSlot $index outside 0..$maxSlots');
    slots[index].clear();
    _announceSlot(index);
    inventoryChanged.emit();
  }

  /// Takes up to [amount] out of one slot and hands back what actually left
  /// it — the id, because the caller's next move is to give it somewhere
  /// (a pickup spawned at the player's feet, a stack landing in a chest) and
  /// an id is what a factory takes.
  ///
  /// Null when the slot holds nothing: a container the player is dragging
  /// across has empty slots by definition, so "nothing to take here" is a
  /// legitimate answer and not a failure (rule 20).
  ({String itemId, int amount})? removeItemAtIndex(int index, int amount) {
    assert(_isSlot(index), '[InventoryComponent] removeAt $index outside 0..$maxSlots');
    assert(amount > 0, '[InventoryComponent] removeAt amount $amount');
    final stack = slots[index];
    if (stack.isEmpty) return null;

    final itemId = stack.itemId;
    final item = _itemOf(stack);
    final taken = InventoryRules.calculateTake(amount, stack.amount);
    stack.amount -= taken;
    if (stack.amount <= 0) stack.clear();
    _announceSlot(index);
    inventoryChanged.emit();
    itemRemoved.emit((item, taken));
    return (itemId: itemId, amount: taken);
  }

  /// Moves up to [amount] from [from] to [to] inside THIS container. An empty
  /// destination takes what was asked for; a matching one absorbs what fits
  /// and leaves the remainder behind; anything else refuses, because splitting
  /// a stack onto a different item has nowhere to put the item already there.
  ///
  /// This is where a half-split lands, and `mergeStacks` is this with
  /// "everything" for an amount — one body, so a drag that carries half and a
  /// drag that carries all cannot disagree about what happens at the far end.
  bool moveWithin(int from, int to, int amount) {
    assert(_isSlot(from) && _isSlot(to),
        '[InventoryComponent] move $from->$to outside 0..$maxSlots');
    assert(amount > 0, '[InventoryComponent] move amount $amount');
    if (from == to) return false;

    final src = slots[from];
    if (src.isEmpty) return false;
    final moving = InventoryRules.calculateTake(amount, src.amount);

    final dst = slots[to];
    if (dst.isEmpty) {
      final item = _itemOf(src);
      src.amount -= moving;
      if (src.amount <= 0) src.clear();
      dst
        ..itemId = item.id
        ..amount = moving;
      _announceSlot(from);
      _announceSlot(to);
      inventoryChanged.emit();
      return true;
    }

    if (!InventoryRules.areIdsEqual(dst.itemId, src.itemId)) return false;

    final maxStack = _itemOf(dst).maxStack;
    if (InventoryRules.spaceForMatchingStack(maxStack, dst.amount) <= 0) {
      return false;
    }
    final transfer =
        InventoryRules.calculateStackTransfer(moving, dst.amount, maxStack);
    dst.amount += transfer;
    src.amount -= transfer;
    if (src.amount <= 0) src.clear();

    _announceSlot(from);
    _announceSlot(to);
    inventoryChanged.emit();
    return true;
  }

  /// Folds all of [from] into [to] inside THIS container — [moveWithin] with
  /// the whole stack.
  bool mergeStacks(int from, int to) {
    assert(_isSlot(from), '[InventoryComponent] merge from $from outside 0..$maxSlots');
    final src = slots[from];
    if (src.isEmpty) return false;
    return moveWithin(from, to, src.amount);
  }

  // ============================================
  // SORT (FP4.2b's deferred half)
  // ============================================

  /// Reorders the whole container: category, then subcategory, then tier
  /// (best first), then the item id. Partial stacks of the same item are
  /// merged on the way through, because compacting is half of what a player
  /// presses the button for; empty slots end up at the back.
  ///
  /// Lives on the component rather than on any one interface so that every
  /// inventory sorts the same way — an actor's, a chest's, anything that owns
  /// one of these.
  void sortItems() {
    final ordered = _collectMergedStacks()..sort(compareStacks);

    for (var i = 0; i < maxSlots; i++) {
      final stack = slots[i];
      final previousId = stack.itemId;
      final previousAmount = stack.amount;

      if (i < ordered.length) {
        stack
          ..itemId = ordered[i].itemId
          ..amount = ordered[i].amount;
      } else {
        stack.clear();
      }

      // A sort leaves most slots holding exactly what they held; announcing
      // those anyway would fan a single button press out over every slot in
      // every open panel.
      if (stack.itemId != previousId || stack.amount != previousAmount) {
        _announceSlot(i);
      }
    }

    inventoryChanged.emit();
  }

  /// Every non-empty stack, with same-item stacks folded together and re-split
  /// at `max_stack`.
  ///
  /// PORT DELTA — the spec's unique-instance arm is NOT here. There,
  /// `add_item` gives every `max_stack == 1` item a resource of its own so it
  /// can carry its own durability and identity, and folding two of them would
  /// erase one axe's wear into the other's. An [ItemStack] here is an id and a
  /// count, so folding two uniques and re-splitting them gives back exactly
  /// the two stacks of one it started with — the arm would guard nothing. It
  /// returns with its subject, when instance state does (rule 5: a branch that
  /// cannot matter yet is a lie about what the game does).
  List<ItemStack> _collectMergedStacks() {
    final merged = <ItemStack>[];
    final stackableById = <String, ItemStack>{};

    for (final stack in slots) {
      if (stack.isEmpty) continue;
      final existing = stackableById[stack.itemId];
      if (existing == null) {
        final fresh = ItemStack.of(stack.itemId, stack.amount);
        stackableById[stack.itemId] = fresh;
        merged.add(fresh);
      } else {
        existing.amount += stack.amount;
      }
    }

    return _splitOverflowingStacks(merged);
  }

  /// Cuts any stack that grew past its `max_stack` while merging back into
  /// legal stacks.
  List<ItemStack> _splitOverflowingStacks(List<ItemStack> merged) {
    final result = <ItemStack>[];
    for (final stack in merged) {
      final maxStack = _itemOf(stack).maxStack;
      while (stack.amount > maxStack) {
        result.add(ItemStack.of(stack.itemId, maxStack));
        stack.amount -= maxStack;
      }
      result.add(stack);
    }
    return result;
  }

  /// The order items are shown in. [InventorySortRules] owns the first three
  /// axes; what follows them is decided here, where the caller with the locale
  /// is.
  ///
  /// Public because it is *the* order, not just the order [sortItems] leaves
  /// behind — any interface listing a subset of an inventory reads it from
  /// here so it cannot drift from what the grid shows.
  ///
  /// PORT DELTA — the shape: a Dart [Comparator] returns an ordering, not the
  /// spec's `a sorts before b` bool, because that is what `List.sort` takes.
  ///
  /// PORT DELTA — the fourth axis, the item's DISPLAYED NAME, has no subject
  /// in this port and is skipped. The pack authors a `display_name_key` and
  /// the pipeline emits it into every item's JSON and every locale table, but
  /// no data class reads it yet: nothing has needed an item's name on screen
  /// (a slot draws an icon and a count). So the order falls through to the
  /// spec's own NEXT axis, the id, which is already here and is stable in
  /// every locale. The name axis arrives with the first surface that shows one
  /// — a tooltip, FP5 — and lands between tier and id without moving anything
  /// else.
  static int compareStacks(ItemStack a, ItemStack b) {
    final registry = locator<ItemRegistry>();
    final itemA = registry.getItem(a.itemId);
    final itemB = registry.getItem(b.itemId);

    final category = InventorySortRules.categoryRank(itemA)
        .compareTo(InventorySortRules.categoryRank(itemB));
    if (category != 0) return category;

    final subcategory = InventorySortRules.subcategoryRank(itemA)
        .compareTo(InventorySortRules.subcategoryRank(itemB));
    if (subcategory != 0) return subcategory;

    final tier = InventorySortRules.tierRank(itemA)
        .compareTo(InventorySortRules.tierRank(itemB));
    if (tier != 0) return tier;

    // One item can hold several stacks — a split overflow, or two uniques.
    // Both are broken here so the order is the same on every press.
    final id = itemA.id.compareTo(itemB.id);
    if (id != 0) return id;
    return b.amount.compareTo(a.amount);
  }

  /// Moves up to [amount] from this container's [fromSlot] into [target]'s
  /// [toSlot], resolving the three outcomes a drag across two open panels can
  /// have: an empty destination takes the stack, a matching one absorbs what
  /// fits, and any other pairing trades the two slots whole. Returns whether
  /// anything moved.
  ///
  /// Cross-container only. A move inside one container is `mergeStacks` or
  /// `swapSlots`, which carry rules of their own. This is the seam the spec's
  /// multiplayer layer replicates: one method, both containers, every mutation
  /// announced by the container it happened in.
  bool transferTo(
    InventoryComponent target,
    int fromSlot,
    int toSlot,
    int amount,
  ) {
    assert(!identical(target, this),
        '[InventoryComponent] transferTo is cross-container; use mergeStacks/swapSlots within one');
    assert(amount > 0, '[InventoryComponent] transferTo amount $amount');
    assert(_isSlot(fromSlot), '[InventoryComponent] transfer from $fromSlot outside 0..$maxSlots');
    assert(target._isSlot(toSlot),
        '[InventoryComponent] transfer to $toSlot outside 0..${target.maxSlots}');

    final source = slots[fromSlot];
    if (source.isEmpty) return false;
    final destination = target.slots[toSlot];
    final sourceItem = _itemOf(source);

    if (destination.isEmpty) {
      final moved = InventoryRules.calculateTake(amount, source.amount);
      removeItemAtIndex(fromSlot, moved);
      target.setSlot(toSlot, sourceItem, moved);
      return true;
    }

    if (InventoryRules.areIdsEqual(destination.itemId, source.itemId)) {
      final space = InventoryRules.spaceForMatchingStack(
        sourceItem.maxStack,
        destination.amount,
      );
      if (space <= 0) return false;
      final transfer = InventoryRules.calculateTake(
        InventoryRules.calculateTake(amount, source.amount),
        space,
      );
      target.setSlot(toSlot, sourceItem, destination.amount + transfer);
      removeItemAtIndex(fromSlot, transfer);
      return true;
    }

    // Different items: the two slots trade places whole and [amount] is
    // ignored — half a swap would need a third slot to put the remainder in.
    final destinationItem = target._itemOf(destination);
    final destinationAmount = destination.amount;
    final sourceAmount = source.amount;
    setSlot(fromSlot, destinationItem, destinationAmount);
    target.setSlot(toSlot, sourceItem, sourceAmount);
    itemRemoved.emit((sourceItem, sourceAmount));
    target.itemRemoved.emit((destinationItem, destinationAmount));
    return true;
  }
}
