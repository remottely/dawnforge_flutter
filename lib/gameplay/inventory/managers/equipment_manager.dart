import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../entities/equipment_slot.dart';
import '../entities/item.dart';
import '../items/main_hand_item.dart';
import 'inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/state/equipment_state.dart';

/// Manager for equipment state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
final class EquipmentManager {
  EquipmentManager._() {
    developer.log('[EquipmentManager] Initialized with single equipped slot');

    // Sync when inventory slots change (e.g., consumption/move clearing the selected slot)
    InventoryManager.instance.slotsNotifier.addListener(
      _handleInventorySlotsChanged,
    );
  }

  static final instance = EquipmentManager._();

  EquipmentSlot _equippedSlot = const EquipmentSlot();

  /// J3: ValueNotifier for cross-module communication
  final ValueNotifier<int> selectedSlotIndexNotifier = ValueNotifier(0);

  int _currentMainHandSlotIndex = 0;

  int get currentMainHandSlotIndex => _currentMainHandSlotIndex;

  bool equip(Item item, {int? inventorySlotIndex}) {
    developer.log('[EquipmentManager] Equipping ${item.name}');

    if (InventoryManager.instance.getItemQuantity(item.id) == 0) {
      developer.log('[EquipmentManager] Item not in inventory');
      return false;
    }

    _equippedSlot = _equippedSlot.equip(item);

    // Notify Flutter overlay
    EquipmentState.instance.updateEquippedItem(item);

    developer.log(
      '[EquipmentManager] Item equipped successfully (kept in inventory)',
    );

    if (inventorySlotIndex != null) {
      _currentMainHandSlotIndex = inventorySlotIndex;
      selectedSlotIndexNotifier.value = inventorySlotIndex;
    }

    return true;
  }

  Item? unequip() {
    developer.log('[EquipmentManager] Clearing equipped item');

    final item = _equippedSlot.equippedItem;
    _equippedSlot = _equippedSlot.unequip();

    // Notify Flutter overlay
    EquipmentState.instance.updateEquippedItem(null);

    return item;
  }

  bool selectSlotIndex(int index) {
    final slot = InventoryManager.instance.getSlotByIndex(index);
    if (slot == null) {
      developer.log('[EquipmentManager] Slot $index not found');
      return false;
    }

    // Always move selection first so toolbar can stay in sync even on empty slots
    _currentMainHandSlotIndex = index;
    selectedSlotIndexNotifier.value = index;

    final item = slot.item;
    if (item == null) {
      developer.log('[EquipmentManager] Slot $index is empty');
      // Still allow selecting empty slots; clear equipped display
      clearSelectedEquipment();
      return true;
    }

    final success = equip(item, inventorySlotIndex: index);

    if (!success) {
      developer.log('[EquipmentManager] Failed to equip item at slot $index');
      // Keep selection but ensure we don't show stale equipment
      clearSelectedEquipment();
      return false;
    }
    return true;
  }

  void clearSelectedEquipment() {
    _equippedSlot = _equippedSlot.unequip();
    EquipmentState.instance.updateEquippedItem(null);
  }

  Item? getEquippedItem() => _equippedSlot.equippedItem;

  bool hasEquippedItem() => _equippedSlot.isOccupied;

  List<Item> getAllEquippedItems() {
    return _equippedSlot.isOccupied ? [_equippedSlot.equippedItem!] : [];
  }

  int getTotalDamage() {
    final mainHand = getEquippedItem();
    if (mainHand == null) return 0;
    if (mainHand is MainHandItem) return mainHand.damage;
    return 0;
  }

  double getTotalDps() {
    final mainHand = getEquippedItem();
    if (mainHand == null) return 0;
    if (mainHand is MainHandItem) return mainHand.dps;
    return 0;
  }

  int getTotalDefense() {
    return 0;
  }

  Map<String, dynamic> getTotalStats() {
    return {
      'damage': getTotalDamage(),
      'dps': getTotalDps(),
      'defense': getTotalDefense(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'equipped': _equippedSlot.toJson(),
      'selectedSlotIndex': _currentMainHandSlotIndex,
    };
  }

  void fromJson(
    Map<String, dynamic> json,
    Item? Function(String itemId) itemFactory,
  ) {
    _equippedSlot = const EquipmentSlot();

    final equippedData = json['equipped'] as Map<String, dynamic>?;
    if (equippedData != null) {
      try {
        _equippedSlot = EquipmentSlot.fromJson(equippedData, itemFactory);
        EquipmentState.instance.updateEquippedItem(_equippedSlot.equippedItem);
      } catch (e) {
        developer.log('[EquipmentManager] Error loading equipped item: $e');
      }
    }

    _currentMainHandSlotIndex = json['selectedSlotIndex'] as int? ?? 0;
    selectedSlotIndexNotifier.value = _currentMainHandSlotIndex;

    developer.log('[EquipmentManager] Loaded equipped item from JSON');
  }

  void reset() {
    _equippedSlot = const EquipmentSlot();
    _currentMainHandSlotIndex = 0;
    selectedSlotIndexNotifier.value = 0;

    // Notify Flutter overlays
    EquipmentState.instance.updateEquippedItem(null);

    developer.log('[EquipmentManager] Equipment reset');
  }

  void _handleInventorySlotsChanged() {
    final selectedIndex = _currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedIndex);
    if (slot == null) return;

    // If the selected slot became empty, clear the equipped display
    if (slot.isEmpty && getEquippedItem() != null) {
      clearSelectedEquipment();
    }
  }
}
