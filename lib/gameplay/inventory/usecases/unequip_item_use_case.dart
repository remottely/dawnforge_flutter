import '../entities/equipment_slot.dart';
import '../entities/item.dart';
import '../managers/equipment_manager.dart';

/// UseCase for unequipping items (B1: Concrete UseCase)
class UnequipItemUseCase {
  final EquipmentManager _equipmentManager;

  UnequipItemUseCase(this._equipmentManager);

  /// Unequip an item from a slot
  /// Returns the unequipped item or null if slot was empty
  Item? call(EquipmentSlotType slotType) {
    return _equipmentManager.unequip(slotType);
  }

  /// Unequip all items
  void unequipAll() {
    for (final slotType in EquipmentSlotType.values) {
      _equipmentManager.unequip(slotType);
    }
  }
}
