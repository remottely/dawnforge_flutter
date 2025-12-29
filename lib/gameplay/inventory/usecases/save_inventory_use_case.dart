import '../managers/equipment_manager.dart';
import '../managers/inventory_manager.dart';

/// UseCase for saving inventory state (E2: UseCase for Save/Load)
class SaveInventoryUseCase {
  final InventoryManager _inventoryManager;
  final EquipmentManager _equipmentManager;

  SaveInventoryUseCase(this._inventoryManager, this._equipmentManager);

  /// Save inventory and equipment state to JSON
  /// Returns a Map that can be persisted
  Map<String, dynamic> call() {
    return {
      'version': 1,
      'inventory': {
        'maxSlots': _inventoryManager.maxSlots,
        'slots': _inventoryManager.slots
            .where((slot) => !slot.isEmpty)
            .map((slot) => slot.toJson())
            .toList(),
      },
      'equipment': {
        'selectedSlotIndex': _equipmentManager.currentMainHandSlotIndex,
        'slots': _equipmentManager.equipmentSlots.values
            .where((slot) => !slot.isEmpty)
            .map((slot) => slot.toJson())
            .toList(),
      },
    };
  }
}
