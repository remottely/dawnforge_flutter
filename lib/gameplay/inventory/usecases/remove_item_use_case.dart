import 'dart:developer' as developer;
import 'dart:math';

import '../managers/inventory_manager.dart';
import '../models/equipped_hand_type.dart';

/// UseCase for removing items from inventory (B1: Concrete UseCase)
class RemoveItemUseCase {
  final InventoryManager _inventoryManager;

  RemoveItemUseCase(this._inventoryManager);

  /// Remove an item from inventory by ID and quantity
  /// Returns true if successful, false otherwise
  bool call(EquippedHandType itemId, int quantity) {
    developer.log('[RemoveItemUseCase] Removing $quantity x ${itemId.name}');

    if (quantity <= 0) {
      developer.log('[RemoveItemUseCase] Invalid quantity: $quantity');
      return false;
    }

    final totalQuantity = _inventoryManager.getItemQuantity(itemId.name);
    if (totalQuantity < quantity) {
      developer.log(
        '[RemoveItemUseCase] Not enough items. Has: $totalQuantity, needs: $quantity',
      );
      return false;
    }

    int remainingToRemove = quantity;

    for (
      var i = _inventoryManager.maxSlots - 1;
      i >= 0 && remainingToRemove > 0;
      i--
    ) {
      final slot = _inventoryManager.getSlotByIndex(i);
      if (slot == null || slot.item?.id != itemId) continue;

      final amountToRemove = min(remainingToRemove, slot.quantity);
      _inventoryManager.updateSlot(i, slot.removeQuantity(amountToRemove));
      remainingToRemove -= amountToRemove;

      developer.log('[RemoveItemUseCase] Removed $amountToRemove from slot $i');
    }

    developer.log('[RemoveItemUseCase] Item removed successfully');
    return true;
  }

  /// Remove all items with the given ID from inventory
  bool removeAll(EquippedHandType itemId) {
    final currentQuantity = _inventoryManager.getItemQuantity(itemId.name);
    if (currentQuantity == 0) return false;
    return call(itemId, currentQuantity);
  }
}
