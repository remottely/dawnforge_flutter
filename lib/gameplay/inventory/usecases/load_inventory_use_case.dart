import 'dart:developer' as developer;

import '../entities/equipment_slot.dart';
import '../entities/inventory_slot.dart';
import '../managers/equipment_manager.dart';
import '../managers/inventory_manager.dart';
import '../services/item_factory_service.dart';

/// UseCase for loading inventory state (E2: UseCase for Save/Load)
class LoadInventoryUseCase {
  final InventoryManager _inventoryManager;
  final EquipmentManager _equipmentManager;
  final ItemFactoryService _itemFactory;

  LoadInventoryUseCase(
    this._inventoryManager,
    this._equipmentManager,
    this._itemFactory,
  );

  /// Load inventory and equipment state from JSON
  /// Returns true if successful, false otherwise
  bool call(Map<String, dynamic> data) {
    try {
      final version = data['version'] as int? ?? 1;
      developer.log('[LoadInventoryUseCase] Loading version $version');

      // Load inventory
      if (data.containsKey('inventory')) {
        _loadInventory(data['inventory'] as Map<String, dynamic>);
      }

      // Load equipment
      if (data.containsKey('equipment')) {
        _loadEquipment(data['equipment'] as Map<String, dynamic>);
      }

      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[LoadInventoryUseCase] Error loading inventory',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void _loadInventory(Map<String, dynamic> inventoryData) {
    final maxSlots = inventoryData['maxSlots'] as int?;
    if (maxSlots != null) {
      _inventoryManager.setMaxSlots(maxSlots);
    }

    final slotsData = inventoryData['slots'] as List<dynamic>? ?? [];
    for (final slotJson in slotsData) {
      final slot = InventorySlot.fromJson(
        slotJson as Map<String, dynamic>,
        (itemId) => _itemFactory.createItem(itemId),
      );
      if (slot.item != null && !slot.isEmpty) {
        _inventoryManager.addItem(slot.item!, slot.quantity);
      }
    }
  }

  void _loadEquipment(Map<String, dynamic> equipmentData) {
    final selectedSlotIndex = equipmentData['selectedSlotIndex'] as int? ?? 0;

    final slotsData = equipmentData['slots'] as List<dynamic>? ?? [];
    for (final slotJson in slotsData) {
      final slot = EquipmentSlot.fromJson(
        slotJson as Map<String, dynamic>,
        (itemId) => _itemFactory.createItem(itemId),
      );
      if (slot.equippedItem != null) {
        _equipmentManager.equip(
          slot.slotType,
          slot.equippedItem!,
        );
      }
    }

    // Restore selected slot
    _equipmentManager.selectSlotIndex(selectedSlotIndex);
  }
}
