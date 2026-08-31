import 'package:dawnforge/src/core/resources/inventory/item_stack.dart';

/// A slot-based container's STATE — what the Godot `InventoryComponent`
/// keeps in `slots`, lifted into the data layer (rule 8). The component
/// (`InventoryComponent`) is the behavior over this; hosts and UI read
/// through it, never cache.
///
/// Owned by `IActorData` for now — the pack authors `inventory_size` on every
/// world object, but only actors carry container state until storage props
/// arrive and lift this field up the hierarchy.
final class InventoryData {
  InventoryData({required int slotCount})
      : assert(slotCount >= 0, '[InventoryData] negative slot count $slotCount'),
        selectedSlot = 0,
        slots = List<ItemStack>.generate(
          slotCount,
          (_) => ItemStack.empty(),
          growable: false,
        );

  InventoryData._(this.slots, this.selectedSlot);

  factory InventoryData.deserialize(Map<String, Object?> json) {
    final rawSlots = json['slots'];
    if (rawSlots is! List) {
      throw StateError('[InventoryData] malformed slots: $json');
    }
    // Required, not defaulted: a container written without a cursor is a
    // container written by an older shape of this class, and reading it as
    // "slot zero, probably" is a default patched over missing data (rules 5
    // and 6). Nothing has shipped, so the save is the bill (rule 32).
    final selected = json['selected_slot'];
    if (selected is! int || selected < 0 || selected >= rawSlots.length) {
      throw StateError('[InventoryData] selected_slot out of range: $json');
    }
    return InventoryData._(
      List<ItemStack>.generate(
        rawSlots.length,
        (i) {
          final slot = rawSlots[i];
          if (slot is! Map<String, Object?>) {
            throw StateError('[InventoryData] malformed slot $i: $slot');
          }
          return ItemStack.deserialize(slot);
        },
        growable: false,
      ),
      selected,
    );
  }

  /// Fixed-length; capacity changes are a future verb (`grow_by`, on tier
  /// unlock) and arrive with their system.
  final List<ItemStack> slots;

  /// Which slot the container's owner is currently pointing at — for an actor,
  /// the one the hotbar highlights and the hand draws from.
  ///
  /// State, not view (rule 8): the spec keeps this counter inside `HotbarUI`,
  /// but what a player is holding survives closing the bag and has to survive a
  /// save, so it lives in the soul beside the slots it indexes — the same move
  /// FP4.2a made for the slots themselves. Written only through
  /// `InventoryComponent.selectSlot`, which is where the range is enforced.
  int selectedSlot;

  int get slotCount => slots.length;

  bool get hasAnyItem => slots.any((stack) => !stack.isEmpty);

  int countOf(String itemId) {
    assert(itemId.isNotEmpty, '[InventoryData] countOf empty id');
    var total = 0;
    for (final stack in slots) {
      if (!stack.isEmpty && stack.itemId == itemId) total += stack.amount;
    }
    return total;
  }

  /// Mutable state only: the slot list, empties included so indices survive
  /// the round-trip (a hotbar is positional), and the cursor into it.
  Map<String, Object?> serialize() => <String, Object?>{
        'slots': slots.map((stack) => stack.serialize()).toList(),
        'selected_slot': selectedSlot,
      };

  InventoryData clone() => InventoryData._(
        List<ItemStack>.generate(
          slots.length,
          (i) => slots[i].clone(),
          growable: false,
        ),
        selectedSlot,
      );
}
