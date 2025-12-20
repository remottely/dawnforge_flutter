import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item.dart';
import 'package:flutter/foundation.dart';

/// State manager for equipment to communicate between Bonfire and Flutter
class EquipmentState {
  EquipmentState._();
  
  static final instance = EquipmentState._();

  // Map of slot type to equipped item
  final equipment = ValueNotifier<Map<EquipmentSlotType, Item?>>({
    EquipmentSlotType.mainHand: null,
    EquipmentSlotType.offHand: null,
    EquipmentSlotType.helmet: null,
    EquipmentSlotType.chest: null,
    EquipmentSlotType.legs: null,
    EquipmentSlotType.boots: null,
    EquipmentSlotType.gloves: null,
    EquipmentSlotType.necklace: null,
  });

  void updateSlot(EquipmentSlotType slotType, Item? item) {
    final newMap = Map<EquipmentSlotType, Item?>.from(equipment.value);
    newMap[slotType] = item;
    equipment.value = newMap;
  }

  void updateAll(Map<EquipmentSlotType, Item?> newEquipment) {
    equipment.value = Map.from(newEquipment);
  }

  Item? getItem(EquipmentSlotType slotType) {
    return equipment.value[slotType];
  }

  void dispose() {
    equipment.dispose();
  }
}
