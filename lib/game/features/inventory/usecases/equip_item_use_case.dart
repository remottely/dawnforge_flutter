import '../entities/hand_item.dart';
import '../managers/equipment_manager.dart';
import '../managers/inventory_manager.dart';

/// UseCase for equipping items (B1: Concrete UseCase)
class EquipItemUseCase {
  final EquipmentManager _equipmentManager;
  final InventoryManager _inventoryManager;

  EquipItemUseCase(this._equipmentManager, this._inventoryManager);

  /// Equip an item by ID from inventory
  /// Returns true if successful, false otherwise
  bool call(String itemId) {
    final slot = _inventoryManager.findSlotByItemId(itemId);
    if (slot == null || slot.item == null) return false;

    return _equipmentManager.selectSlotIndex(slot.index);
  }

  /// Equip an item entity directly
  bool equipItemEntity(HandItem item, int? inventorySlotIndex) {
    if (inventorySlotIndex != null) {
      return _equipmentManager.selectSlotIndex(inventorySlotIndex);
    }

    final slot = _inventoryManager.findSlotByItemId(item.id.name);
    if (slot == null) return false;
    return _equipmentManager.selectSlotIndex(slot.index);
  }

  /// Select a slot index for main hand equipment
  bool selectSlotIndex(int index) {
    return _equipmentManager.selectSlotIndex(index);
  }
}
