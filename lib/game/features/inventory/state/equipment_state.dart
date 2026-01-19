import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:dawnforge/game/features/inventory/entities/hand_item.dart';
import 'package:flutter/foundation.dart';

/// State manager for equipment to communicate between Bonfire and Flutter
class EquipmentState {
  EquipmentState._();

  static final EquipmentState instance = EquipmentState._();

  // Single equipped item (no slot distinction)
  final equippedItem = ValueNotifier<HandItem?>(null);

  void updateEquippedItem(HandItem? item) {
    try {
      equippedItem.value = item;
      GameLogger.info(
        '[EquipmentState] Updated equipped item: ${item?.name ?? "empty"}',
      );
    } catch (e, stack) {
      GameLogger.error(
        '[EquipmentState] Error updating equipped item: $e\n$stack',
      );
    }
  }

  HandItem? getItem() {
    return equippedItem.value;
  }

  void dispose() {
    equippedItem.dispose();
  }
}
