import 'dart:developer' as developer;
import 'dart:math';

import '../entities/inventory_slot.dart';
import '../entities/item.dart';
import '../managers/inventory_manager.dart';
import '../services/item_factory_service.dart';

/// UseCase for adding items to inventory (B1: Concrete UseCase)
class AddItemUseCase {
  final InventoryManager _inventoryManager;
  final ItemFactoryService _itemFactory;

  AddItemUseCase(this._inventoryManager, this._itemFactory);

  /// Add an item to inventory by ID and quantity
  /// Returns true if successful, false otherwise
  bool call(String itemId, int quantity) {
    if (quantity <= 0) return false;

    final item = _itemFactory.createItem(itemId);
    if (item == null) return false;

    return addItemEntity(item, quantity);
  }

  /// Add an item entity directly to inventory
  bool addItemEntity(Item item, [int quantity = 1]) {
    developer.log('[AddItemUseCase] Adding $quantity x ${item.name}');

    if (quantity <= 0) {
      developer.log('[AddItemUseCase] Invalid quantity: $quantity');
      return false;
    }

    int remainingQuantity = quantity;

    // Try to stack in existing slots
    if (item.isStackable) {
      for (
        var i = 0;
        i < _inventoryManager.maxSlots && remainingQuantity > 0;
        i++
      ) {
        final slot = _inventoryManager.getSlotByIndex(i);
        if (slot == null || slot.isEmpty) continue;
        if (slot.item!.id != item.id) continue;
        if (slot.isFull) continue;

        final spaceInSlot = item.maxStackSize - slot.quantity;
        if (spaceInSlot <= 0) continue;

        final amountToAdd = min(remainingQuantity, spaceInSlot);
        _inventoryManager.updateSlot(i, slot.addQuantity(amountToAdd));
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

      final amountForSlot = item.isStackable
          ? min(remainingQuantity, item.maxStackSize)
          : 1;

      _inventoryManager.updateSlot(
        emptySlotIndex,
        InventorySlot(
          index: emptySlotIndex,
          item: item,
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
  bool addMultiple(List<(String itemId, int quantity)> items) {
    var anyAdded = false;

    for (final (itemId, quantity) in items) {
      final success = call(itemId, quantity);

      if (success) {
        anyAdded = true;
        developer.log('[AddItemUseCase] Added $quantity x $itemId');
      } else {
        developer.log('[AddItemUseCase] Failed to add $quantity x $itemId');
      }
    }

    return anyAdded;
  }
}
