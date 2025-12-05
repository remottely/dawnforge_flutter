import 'dart:developer' as developer;

import 'inventory_manager.dart';
import 'item_factory.dart';
import 'items/weapon_item.dart';
import 'models/equipment_slot.dart';
import 'models/item.dart';

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

    final currentItem = getEquippedItem(slotType);
    if (currentItem != null) {
      if (!InventoryManager.instance.addItem(currentItem)) {
        developer.log('[EquipmentManager] Inventory full, cannot equip');
        return false;
      }
    }

    if (!InventoryManager.instance.removeItem(item.id, 1)) {
      if (currentItem != null) {
        InventoryManager.instance.removeItem(currentItem.id, 1);
        _equipmentSlots[slotType] = _equipmentSlots[slotType]!.equip(
          currentItem,
        );
      }
      developer.log('[EquipmentManager] Item not in inventory');
      return false;
    }

    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.equip(item);
    developer.log('[EquipmentManager] Item equipped successfully');
    return true;
  }

  Item? unequip(EquipmentSlotType slotType) {
    developer.log('[EquipmentManager] Unequipping from $slotType');

    final item = getEquippedItem(slotType);
    if (item == null) {
      developer.log('[EquipmentManager] Slot is empty');
      return null;
    }

    if (!InventoryManager.instance.addItem(item)) {
      developer.log('[EquipmentManager] Inventory full, cannot unequip');
      return null;
    }

    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.unequip();
    developer.log('[EquipmentManager] Item unequipped successfully');
    return item;
  }

  Item? getEquippedItem(EquipmentSlotType slotType) {
    return _equipmentSlots[slotType]?.equippedItem;
  }

  bool isSlotOccupied(EquipmentSlotType slotType) {
    return _equipmentSlots[slotType]?.isOccupied ?? false;
  }

  List<Item> getAllEquippedItems() {
    return _equipmentSlots.values
        .where((slot) => slot.isOccupied)
        .map((slot) => slot.equippedItem!)
        .toList();
  }

  bool _canEquipItemInSlot(Item item, EquipmentSlotType slotType) {
    if (item is WeaponItem) {
      return slotType == EquipmentSlotType.weapon ||
          slotType == EquipmentSlotType.offhand;
    }

    return false;
  }

  int getTotalDamage() {
    int total = 0;

    final weapon = getEquippedItem(EquipmentSlotType.weapon);
    if (weapon is WeaponItem) {
      total += weapon.damage;
    }

    final offhand = getEquippedItem(EquipmentSlotType.offhand);
    if (offhand is WeaponItem) {
      total += offhand.damage;
    }

    return total;
  }

  double getTotalDps() {
    double total = 0;

    final weapon = getEquippedItem(EquipmentSlotType.weapon);
    if (weapon is WeaponItem) {
      total += weapon.dps;
    }

    final offhand = getEquippedItem(EquipmentSlotType.offhand);
    if (offhand is WeaponItem) {
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
