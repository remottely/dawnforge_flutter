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

    return _inventoryManager.addItem(item, quantity);
  }

  /// Add an item entity directly to inventory
  bool addItemEntity(Item item, int quantity) {
    if (quantity <= 0) return false;
    return _inventoryManager.addItem(item, quantity);
  }
}
