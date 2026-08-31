import 'package:dawnforge/core/utils/game_logger.dart';
import 'dart:math';

import '../entities/inventory_slot.dart';
import '../entities/hand_item.dart';
import '../managers/inventory_manager.dart';
import '../entities/enums/hand_item_id.dart';
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
    GameLogger.info('[AddItemUseCase] Adding $quantity x ${item.name}');

    if (quantity <= 0) {
      GameLogger.warning('[AddItemUseCase] Invalid quantity: $quantity');
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
        // If the slot has an old non-stackable instance of the same item, refresh it
        final slotItem = slot.item!;
        final needsUpgrade =
            (!slotItem.isStackable ||
                slotItem.maxStackSize < item.maxStackSize) &&
            item.isStackable;
        final upgradedSlot = needsUpgrade
            ? InventorySlot(
                index: slot.index,
                item: item, // replace with stackable instance
                quantity: slot.quantity,
              )
            : slot;

        if (upgradedSlot.isFull) {
          _inventoryManager.updateSlot(i, upgradedSlot);
          continue;
        }

        final spaceInSlot = item.maxStackSize - upgradedSlot.quantity;
        if (spaceInSlot <= 0) continue;

        final amountToAdd = min(remainingQuantity, spaceInSlot);
        _inventoryManager.updateSlot(i, upgradedSlot.addQuantity(amountToAdd));
        remainingQuantity -= amountToAdd;

        GameLogger.info(
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
        GameLogger.warning(
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
      GameLogger.info(
        '[AddItemUseCase] Created new slot $emptySlotIndex with $amountForSlot items',
      );
    }

    GameLogger.info('[AddItemUseCase] Item added successfully');
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
        GameLogger.info('[AddItemUseCase] Added $quantity x ${itemId.name}');
      } else {
        GameLogger.warning(
          '[AddItemUseCase] Failed to add $quantity x ${itemId.name}',
        );
      }
    }

    return anyAdded;
  }
}
