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
    for (final slotType in EquipmentSlotType.values) {
      _equipmentSlots[slotType] = EquipmentSlot(slotType: slotType);
    }
    developer.log(
      '[EquipmentManager] Initialized with ${_equipmentSlots.length} slots',
    );
  }

  static final instance = EquipmentManager._();

  final Map<EquipmentSlotType, EquipmentSlot> _equipmentSlots = {};

  /// J3: ValueNotifier for cross-module communication
  final ValueNotifier<int> selectedSlotIndexNotifier = ValueNotifier(0);

  int _currentMainHandSlotIndex = 0;

  Map<EquipmentSlotType, EquipmentSlot> get equipmentSlots =>
      Map.unmodifiable(_equipmentSlots);

  int get currentMainHandSlotIndex => _currentMainHandSlotIndex;

  bool equip(EquipmentSlotType slotType, Item item, {int? inventorySlotIndex}) {
    developer.log('[EquipmentManager] Equipping ${item.name} to $slotType');

    if (slotType != EquipmentSlotType.mainHand) {
      developer.log(
        '[EquipmentManager] Slot $slotType is not available for equipping at the moment',
      );
      return false;
    }

    if (!_canEquipItemInSlot(item, slotType)) {
      developer.log('[EquipmentManager] Item cannot be equipped in this slot');
      return false;
    }

    if (InventoryManager.instance.getItemQuantity(item.id) == 0) {
      developer.log('[EquipmentManager] Item not in inventory');
      return false;
    }

    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.equip(item);

    // Notify Flutter overlay
    EquipmentState.instance.updateSlot(slotType, item);

    developer.log(
      '[EquipmentManager] Item equipped successfully (kept in inventory)',
    );

    if (inventorySlotIndex != null) {
      _currentMainHandSlotIndex = inventorySlotIndex;
      selectedSlotIndexNotifier.value = inventorySlotIndex;
    }

    return true;
  }

  Item? unequip(EquipmentSlotType slotType) {
    developer.log('[EquipmentManager] Unequipping from $slotType');

    final item = getEquippedItem(slotType);
    if (item == null) {
      developer.log('[EquipmentManager] Slot is empty');
      return null;
    }

    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.unequip();

    // Notify Flutter overlay
    EquipmentState.instance.updateSlot(slotType, null);

    developer.log(
      '[EquipmentManager] Item unequipped successfully (remains in inventory)',
    );
    return item;
  }

  bool selectSlotIndex(int index) {
    final slot = InventoryManager.instance.getSlotByIndex(index);
    if (slot == null) {
      developer.log('[EquipmentManager] Slot $index not found');
      return false;
    }

    final item = slot.item;
    if (item == null) {
      developer.log('[EquipmentManager] Slot $index is empty');
      final success = unequip(EquipmentSlotType.mainHand) != null;
      _currentMainHandSlotIndex = index;
      selectedSlotIndexNotifier.value = index;
      return success;
    }

    if (item is MainHandItem) {
      final success = equip(
        EquipmentSlotType.mainHand,
        item,
        inventorySlotIndex: index,
      );
      return success;
    }

    developer.log(
      '[EquipmentManager] Item at slot $index is not a MainHandItem',
    );
    return false;
  }

  Item? getEquippedItem(EquipmentSlotType slotType) {
    return _equipmentSlots[slotType]?.equippedItem;
  }

  bool isSlotOccupied(EquipmentSlotType slotType) {
    return _equipmentSlots[slotType]?.isOccupied ?? false;
  }

  /// Returns the slot type where the item is equipped, or null if not equipped
  EquipmentSlotType? getEquippedSlotForItem(String itemId) {
    for (final entry in _equipmentSlots.entries) {
      if (entry.value.equippedItem?.id == itemId) {
        return entry.key;
      }
    }
    return null;
  }

  List<Item> getAllEquippedItems() {
    return _equipmentSlots.values
        .where((slot) => slot.isOccupied)
        .map((slot) => slot.equippedItem!)
        .toList();
  }

  int getTotalDamage() {
    final mainHand = getEquippedItem(EquipmentSlotType.mainHand);
    return mainHand is MainHandItem ? mainHand.damage : 0;
  }

  double getTotalDps() {
    final mainHand = getEquippedItem(EquipmentSlotType.mainHand);
    return mainHand is MainHandItem ? mainHand.dps : 0;
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
    final slotsData = <String, dynamic>{};
    for (final entry in _equipmentSlots.entries) {
      if (entry.value.isOccupied) {
        slotsData[entry.key.toJson()] = entry.value.toJson();
      }
    }
    return {'equipmentSlots': slotsData};
  }

  void fromJson(
    Map<String, dynamic> json,
    Item? Function(String itemId) itemFactory,
  ) {
    for (final slotType in EquipmentSlotType.values) {
      _equipmentSlots[slotType] = EquipmentSlot(slotType: slotType);
    }

    final slotsData = json['equipmentSlots'] as Map<String, dynamic>?;
    if (slotsData == null) return;

    for (final entry in slotsData.entries) {
      try {
        final slotType = EquipmentSlotType.fromJson(entry.key);
        final slot = EquipmentSlot.fromJson(
          entry.value as Map<String, dynamic>,
          itemFactory,
        );
        _equipmentSlots[slotType] = slot;

        // Notify Flutter overlay
        EquipmentState.instance.updateSlot(slotType, slot.equippedItem);
      } catch (e) {
        developer.log('[EquipmentManager] Error loading slot ${entry.key}: $e');
      }
    }

    developer.log(
      '[EquipmentManager] Loaded ${slotsData.length} equipped items from JSON',
    );
  }

  bool _canEquipItemInSlot(Item item, EquipmentSlotType slotType) {
    if (slotType == EquipmentSlotType.mainHand) {
      return item is MainHandItem;
    }
    return false;
  }

  void reset() {
    for (final slotType in EquipmentSlotType.values) {
      _equipmentSlots[slotType] = EquipmentSlot(slotType: slotType);
    }
    _currentMainHandSlotIndex = 0;
    selectedSlotIndexNotifier.value = 0;

    // Notify Flutter overlays
    for (final slotType in EquipmentSlotType.values) {
      EquipmentState.instance.updateSlot(slotType, null);
    }

    developer.log('[EquipmentManager] Equipment reset');
  }
}
