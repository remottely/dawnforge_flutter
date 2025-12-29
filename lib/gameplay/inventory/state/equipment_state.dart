import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/inventory/entities/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/item.dart';
import 'package:flutter/foundation.dart';

/// State manager for equipment to communicate between Bonfire and Flutter
class EquipmentState {
  EquipmentState._();

  static final instance = EquipmentState._();

  // Controls equipment overlay visibility
  final isVisible = ValueNotifier<bool>(true);

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
    try {
      final newMap = Map<EquipmentSlotType, Item?>.from(equipment.value);
      newMap[slotType] = item;
      equipment.value = newMap;
      developer.log(
        '[EquipmentState] Updated slot $slotType: ${item?.name ?? "empty"}',
      );
    } catch (e, stack) {
      developer.log(
        '[EquipmentState] Error updating slot $slotType: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  void updateAll(Map<EquipmentSlotType, Item?> newEquipment) {
    try {
      equipment.value = Map.from(newEquipment);
      developer.log('[EquipmentState] Updated all equipment');
    } catch (e, stack) {
      developer.log(
        '[EquipmentState] Error updating all equipment: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Item? getItem(EquipmentSlotType slotType) {
    return equipment.value[slotType];
  }

  void show() => isVisible.value = true;
  void hide() => isVisible.value = false;
  void toggle() => isVisible.value = !isVisible.value;

  void dispose() {
    equipment.dispose();
    isVisible.dispose();
  }
}
