import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item.dart';
import 'package:flutter/foundation.dart';

/// State manager for equipment to communicate between Bonfire and Flutter
class EquipmentState {
  EquipmentState._();

  static final instance = EquipmentState._();

  // Controls equipment overlay visibility
  final isVisible = ValueNotifier<bool>(true);

  // Single equipped item (no slot distinction)
  final equippedItem = ValueNotifier<HandItem?>(null);

  void updateEquippedItem(HandItem? item) {
    try {
      equippedItem.value = item;
      developer.log(
        '[EquipmentState] Updated equipped item: ${item?.name ?? "empty"}',
      );
    } catch (e, stack) {
      developer.log(
        '[EquipmentState] Error updating equipped item: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  HandItem? getItem() {
    return equippedItem.value;
  }

  void show() => isVisible.value = true;
  void hide() => isVisible.value = false;
  void toggle() => isVisible.value = !isVisible.value;

  void dispose() {
    equippedItem.dispose();
    isVisible.dispose();
  }
}
