import 'package:dawnforge/core/utils/game_logger.dart';
import 'dart:math';

import '../managers/inventory_manager.dart';
import '../entities/enums/hand_item_id.dart';

/// UseCase for removing items from inventory (B1: Concrete UseCase)
class RemoveItemUseCase {
  final InventoryManager _inventoryManager;

  RemoveItemUseCase(this._inventoryManager);

  /// Remove an item from inventory by ID and quantity
  /// Returns true if successful, false otherwise
  bool call(HandItemId itemId, int quantity) {
    GameLogger.info('[RemoveItemUseCase] Removing $quantity x ${itemId.name}');

    if (quantity <= 0) {
      GameLogger.warning('[RemoveItemUseCase] Invalid quantity: $quantity');
      return false;
    }

    final totalQuantity = _inventoryManager.getItemQuantity(itemId.name);
    if (totalQuantity < quantity) {
      GameLogger.warning(
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

      GameLogger.info(
        '[RemoveItemUseCase] Removed $amountToRemove from slot $i',
      );
    }

    GameLogger.info('[RemoveItemUseCase] Item removed successfully');
    return true;
  }

  /// Remove all items with the given ID from inventory
  bool removeAll(HandItemId itemId) {
    final currentQuantity = _inventoryManager.getItemQuantity(itemId.name);
    if (currentQuantity == 0) return false;
    return call(itemId, currentQuantity);
  }
}
