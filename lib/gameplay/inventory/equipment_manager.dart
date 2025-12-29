import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'package:darkness_dungeon/gameplay/inventory/equipment_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item.dart';

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
  final ValueNotifier<int> selectedSlotIndexNotifier = ValueNotifier(0);
  int _currentMainHandSlotIndex = 0;

  Map<EquipmentSlotType, EquipmentSlot> get equipmentSlots =>
      Map.unmodifiable(_equipmentSlots);

  int get currentMainHandSlotIndex => _currentMainHandSlotIndex;

  bool equip(EquipmentSlotType slotType, Item item,
      {int? inventorySlotIndex}) {
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

    // Check if item exists in inventory
    if (InventoryManager.instance.getItemQuantity(item.id) == 0) {
      developer.log('[EquipmentManager] Item not in inventory');
      return false;
    }

    // Simply equip without removing from inventory
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

    // Simply unequip without adding back to inventory (it's already there)
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
      _equipmentSlots[EquipmentSlotType.mainHand] =
          _equipmentSlots[EquipmentSlotType.mainHand]!.unequip();
      EquipmentState.instance.updateSlot(EquipmentSlotType.mainHand, null);
      _currentMainHandSlotIndex = index;
      selectedSlotIndexNotifier.value = index;
      return true;
    }

    final equipped = equip(
      EquipmentSlotType.mainHand,
      item,
      inventorySlotIndex: index,
    );

    if (equipped) {
      _currentMainHandSlotIndex = index;
    }

    return equipped;
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

  bool _canEquipItemInSlot(Item item, EquipmentSlotType slotType) {
    if (slotType != EquipmentSlotType.mainHand) return false;
    return item is MainHandItem;
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

  void fromJson(Map<String, dynamic> json) {
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
          ItemFactory.createItem,
        );
        _equipmentSlots[slotType] = slot;
      } catch (e) {
        developer.log('[EquipmentManager] Error loading slot ${entry.key}: $e');
      }
    }

    developer.log(
      '[EquipmentManager] Loaded ${slotsData.length} equipped items from JSON',
    );
  }

  void reset() {
    for (final slotType in EquipmentSlotType.values) {
      _equipmentSlots[slotType] = EquipmentSlot(slotType: slotType);
    }
    _currentMainHandSlotIndex = 0;
    selectedSlotIndexNotifier.value = 0;
    developer.log('[EquipmentManager] Reset');
  }

  bool unequipAll() {
    developer.log('[EquipmentManager] Unequipping all items');

    final itemsToUnequip = getAllEquippedItems();

    if (itemsToUnequip.length > InventoryManager.instance.freeSlots) {
      developer.log('[EquipmentManager] Not enough inventory space');
      return false;
    }

    for (final slotType in EquipmentSlotType.values) {
      if (isSlotOccupied(slotType)) {
        unequip(slotType);
      }
    }

    developer.log('[EquipmentManager] All items unequipped');
    return true;
  }
}
