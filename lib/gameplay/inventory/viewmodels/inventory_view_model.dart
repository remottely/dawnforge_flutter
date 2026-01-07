import 'package:flutter/foundation.dart';

import '../entities/inventory_slot.dart';
import '../entities/hand_item.dart';
import '../managers/equipment_manager.dart';
import '../managers/inventory_manager.dart';
import '../usecases/add_item_use_case.dart';
import '../usecases/equip_item_use_case.dart';
import '../usecases/remove_item_use_case.dart';
import '../entities/enums/hand_item_id.dart';

/// ViewModel UI data for inventory slot
class InventorySlotUI {
  final int index;
  final HandItem? item;
  final int quantity;
  final bool isSelected;
  final bool isEmpty;

  InventorySlotUI({
    required this.index,
    this.item,
    required this.quantity,
    required this.isSelected,
    required this.isEmpty,
  });

  factory InventorySlotUI.fromEntity(InventorySlot slot, bool isSelected) {
    return InventorySlotUI(
      index: slot.index,
      item: slot.item,
      quantity: slot.quantity,
      isSelected: isSelected,
      isEmpty: slot.isEmpty,
    );
  }
}

/// ViewModel for inventory overlay (F2: ViewModel intermediary)
class InventoryViewModel {
  final InventoryManager _inventoryManager;
  final EquipmentManager _equipmentManager;
  final AddItemUseCase _addItemUseCase;
  final RemoveItemUseCase _removeItemUseCase;
  final EquipItemUseCase _equipItemUseCase;

  InventoryViewModel({
    required InventoryManager inventoryManager,
    required EquipmentManager equipmentManager,
    required AddItemUseCase addItemUseCase,
    required RemoveItemUseCase removeItemUseCase,
    required EquipItemUseCase equipItemUseCase,
  }) : _inventoryManager = inventoryManager,
       _equipmentManager = equipmentManager,
       _addItemUseCase = addItemUseCase,
       _removeItemUseCase = removeItemUseCase,
       _equipItemUseCase = equipItemUseCase;

  /// Add item to inventory
  bool addItem(HandItemId itemId, int quantity) {
    return _addItemUseCase(itemId, quantity);
  }

  /// Remove item from inventory
  bool removeItem(HandItemId itemId, int quantity) {
    return _removeItemUseCase(itemId, quantity);
  }

  /// Transform entity data to UI-friendly format
  ValueNotifier<List<InventorySlotUI>> get slotsUI {
    final notifier = ValueNotifier<List<InventorySlotUI>>([]);

    void updateUI() {
      final selectedIndex = _equipmentManager.currentMainHandSlotIndex;
      final slots = _inventoryManager.slots;

      notifier.value = slots
          .map(
            (slot) =>
                InventorySlotUI.fromEntity(slot, slot.index == selectedIndex),
          )
          .toList();
    }

    // Listen to inventory changes
    _inventoryManager.slotsNotifier.addListener(updateUI);

    // Listen to selection changes
    _equipmentManager.selectedSlotIndexNotifier.addListener(updateUI);

    // Initial update
    updateUI();

    return notifier;
  }

  /// Handle slot tap
  void onSlotTapped(int index) {
    _equipItemUseCase.selectSlotIndex(index);
  }

  /// Get current selected slot index
  int get selectedSlotIndex => _equipmentManager.currentMainHandSlotIndex;

  /// Get max slots
  int get maxSlots => _inventoryManager.maxSlots;

  /// Get used slots
  int get usedSlots => _inventoryManager.usedSlots;

  /// Get free slots
  int get freeSlots => _inventoryManager.freeSlots;

  /// Check if inventory is full
  bool get isFull => _inventoryManager.isFull;
}
