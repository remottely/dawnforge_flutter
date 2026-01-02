import '../entities/item.dart';
import '../managers/equipment_manager.dart';

/// UseCase for unequipping items (B1: Concrete UseCase)
class UnequipItemUseCase {
  final EquipmentManager _equipmentManager;

  UnequipItemUseCase(this._equipmentManager);

  /// Unequip the currently equipped item
  /// Returns the unequipped item or null if none was equipped
  Item? call() {
    return _equipmentManager.unequip();
  }

  /// Unequip all items
  void unequipAll() {
    _equipmentManager.unequip();
  }
}
