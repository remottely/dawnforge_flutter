import '../managers/inventory_manager.dart';

/// UseCase for removing items from inventory (B1: Concrete UseCase)
class RemoveItemUseCase {
  final InventoryManager _inventoryManager;

  RemoveItemUseCase(this._inventoryManager);

  /// Remove an item from inventory by ID and quantity
  /// Returns true if successful, false otherwise
  bool call(String itemId, int quantity) {
    if (quantity <= 0) return false;
    return _inventoryManager.removeItem(itemId, quantity);
  }

  /// Remove all items with the given ID from inventory
  bool removeAll(String itemId) {
    final currentQuantity = _inventoryManager.getItemQuantity(itemId);
    if (currentQuantity == 0) return false;
    return _inventoryManager.removeItem(itemId, currentQuantity);
  }
}
