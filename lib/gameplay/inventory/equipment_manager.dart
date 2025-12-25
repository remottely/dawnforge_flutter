import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/inventory/equipment_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item.dart';

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

  Map<EquipmentSlotType, EquipmentSlot> get equipmentSlots =>
      Map.unmodifiable(_equipmentSlots);

  bool equip(EquipmentSlotType slotType, Item item) {
    developer.log('[EquipmentManager] Equipping ${item.name} to $slotType');

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
    if (item is MainHandItem) {
      return slotType == EquipmentSlotType.mainHand ||
          slotType == EquipmentSlotType.offHand;
    }

    return false;
  }

  int getTotalDamage() {
    int total = 0;

    final mainHand = getEquippedItem(EquipmentSlotType.mainHand);
    if (mainHand is MainHandItem) {
      total += mainHand.damage;
    }

    final offhand = getEquippedItem(EquipmentSlotType.offHand);
    if (offhand is MainHandItem) {
      total += offhand.damage;
    }

    return total;
  }

  double getTotalDps() {
    double total = 0;

    final mainHand = getEquippedItem(EquipmentSlotType.mainHand);
    if (mainHand is MainHandItem) {
      total += mainHand.dps;
    }

    final offhand = getEquippedItem(EquipmentSlotType.offHand);
    if (offhand is MainHandItem) {
      total += offhand.dps;
    }

    return total;
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
