import 'dart:developer' as developer;
import 'dart:math';

import '../entities/inventory_slot.dart';
import '../entities/hand/hand_item.dart';
import '../items/main_hand_item.dart';
import '../managers/inventory_manager.dart';
import '../entities/hand/hand_item_id.dart';
import '../services/item_factory_service.dart';

/// UseCase for adding items to inventory (B1: Concrete UseCase)
class AddItemUseCase {
  final InventoryManager _inventoryManager;
  final ItemFactoryService _itemFactory;

  AddItemUseCase(this._inventoryManager, this._itemFactory);

  /// Add an item to inventory by ID and quantity
  /// Returns true if successful, false otherwise
  bool call(HandItemId itemId, int quantity) {
    if (quantity <= 0) return false;

    final item = _itemFactory.createItem(itemId);
    if (item == null) return false;

    return addItemEntity(item, quantity);
  }

  /// Add an item entity directly to inventory
  bool addItemEntity(HandItem item, [int quantity = 1]) {
    final normalizedItem = _normalizeStackBehavior(item);

    developer.log('[AddItemUseCase] Adding $quantity x ${normalizedItem.name}');

    if (quantity <= 0) {
      developer.log('[AddItemUseCase] Invalid quantity: $quantity');
      return false;
    }

    int remainingQuantity = quantity;

    // Try to stack in existing slots
    if (normalizedItem.isStackable) {
      for (
        var i = 0;
        i < _inventoryManager.maxSlots && remainingQuantity > 0;
        i++
      ) {
        final slot = _inventoryManager.getSlotByIndex(i);
        if (slot == null || slot.isEmpty) continue;
        if (slot.item!.id != normalizedItem.id) continue;
        // If the slot has an old non-stackable instance of the same item, refresh it
        final slotItem = slot.item!;
        final needsUpgrade =
            (!slotItem.isStackable || slotItem.maxStackSize < normalizedItem.maxStackSize) &&
            normalizedItem.isStackable;
        final upgradedSlot = needsUpgrade
            ? InventorySlot(
                index: slot.index,
                item: normalizedItem, // replace with stackable instance
                quantity: slot.quantity,
              )
            : slot;

        if (upgradedSlot.isFull) {
          _inventoryManager.updateSlot(i, upgradedSlot);
          continue;
        }

        final spaceInSlot = normalizedItem.maxStackSize - upgradedSlot.quantity;
        if (spaceInSlot <= 0) continue;

        final amountToAdd = min(remainingQuantity, spaceInSlot);
        _inventoryManager.updateSlot(
          i,
          upgradedSlot.addQuantity(amountToAdd),
        );
        remainingQuantity -= amountToAdd;

        developer.log(
          '[AddItemUseCase] Stacked $amountToAdd in slot $i, remaining: $remainingQuantity',
        );
      }
    }

    // Create new slots for remaining quantity
    while (remainingQuantity > 0) {
      // Find next empty slot by checking each slot directly
      int emptySlotIndex = -1;
      for (var i = 0; i < _inventoryManager.maxSlots; i++) {
        final slot = _inventoryManager.getSlotByIndex(i);
        if (slot != null && slot.isEmpty) {
          emptySlotIndex = i;
          break;
        }
      }

      if (emptySlotIndex == -1) {
        developer.log(
          '[AddItemUseCase] Inventory full! Cannot add remaining $remainingQuantity',
        );
        return quantity > remainingQuantity;
      }

      final amountForSlot = normalizedItem.isStackable
          ? min(remainingQuantity, normalizedItem.maxStackSize)
          : 1;

      _inventoryManager.updateSlot(
        emptySlotIndex,
        InventorySlot(
          index: emptySlotIndex,
          item: normalizedItem,
          quantity: amountForSlot,
        ),
      );

      remainingQuantity -= amountForSlot;
      developer.log(
        '[AddItemUseCase] Created new slot $emptySlotIndex with $amountForSlot items',
      );
    }

    developer.log('[AddItemUseCase] Item added successfully');
    return true;
  }

  /// Add multiple items (id, quantity) in one call. Useful for shop purchases.
  /// Returns true if at least one item was added.
  bool addMultiple(List<(HandItemId itemId, int quantity)> items) {
    var anyAdded = false;

    for (final (itemId, quantity) in items) {
      final success = call(itemId, quantity);

      if (success) {
        anyAdded = true;
        developer.log('[AddItemUseCase] Added $quantity x ${itemId.name}');
      } else {
        developer.log('[AddItemUseCase] Failed to add $quantity x ${itemId.name}');
      }
    }

    return anyAdded;
  }

  HandItem _normalizeStackBehavior(HandItem item) {
    if (item is MainHandItem && item.equippedHandType.isSeed) {
      final desiredStackSize = item.maxStackSize > 1 ? item.maxStackSize : 99;

      if (!item.isStackable || item.maxStackSize != desiredStackSize) {
        developer.log(
          '[AddItemUseCase] Normalizing seed item ${item.id} to stackable x$desiredStackSize',
        );
      }

      return item.copyWith(
        isStackable: true,
        maxStackSize: desiredStackSize,
      );
    }

    return item;
  }
}
