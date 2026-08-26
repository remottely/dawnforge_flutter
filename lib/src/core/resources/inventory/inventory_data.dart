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
        slots = List<ItemStack>.generate(
          slotCount,
          (_) => ItemStack.empty(),
          growable: false,
        );

  InventoryData._(this.slots);

  factory InventoryData.deserialize(Map<String, Object?> json) {
    final rawSlots = json['slots'];
    if (rawSlots is! List) {
      throw StateError('[InventoryData] malformed slots: $json');
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
    );
  }

  /// Fixed-length; capacity changes are a future verb (`grow_by`, on tier
  /// unlock) and arrive with their system.
  final List<ItemStack> slots;

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
  /// the round-trip (a hotbar is positional).
  Map<String, Object?> serialize() => <String, Object?>{
        'slots': slots.map((stack) => stack.serialize()).toList(),
      };

  InventoryData clone() => InventoryData._(
        List<ItemStack>.generate(
          slots.length,
          (i) => slots[i].clone(),
          growable: false,
        ),
      );
}
