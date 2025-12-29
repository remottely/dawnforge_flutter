import '../entities/equipment_slot.dart';
import '../entities/item.dart';
import '../managers/equipment_manager.dart';
import '../managers/inventory_manager.dart';

/// UseCase for equipping items (B1: Concrete UseCase)
class EquipItemUseCase {
  final EquipmentManager _equipmentManager;
  final InventoryManager _inventoryManager;

  EquipItemUseCase(this._equipmentManager, this._inventoryManager);

  /// Equip an item by ID from inventory
  /// Returns true if successful, false otherwise
  bool call(String itemId, EquipmentSlotType slotType) {
    final slot = _inventoryManager.findSlotByItemId(itemId);
    if (slot == null || slot.item == null) return false;

    return _equipmentManager.equip(slotType, slot.item!,
        inventorySlotIndex: slot.index);
  }

  /// Equip an item entity directly
  bool equipItemEntity(Item item, EquipmentSlotType slotType,
      {int? inventorySlotIndex}) {
    return _equipmentManager.equip(slotType, item,
        inventorySlotIndex: inventorySlotIndex);
  }

  /// Select a slot index for main hand equipment
  bool selectSlotIndex(int index) {
    return _equipmentManager.selectSlotIndex(index);
  }
}
