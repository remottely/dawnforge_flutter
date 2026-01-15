import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/gameplay/farm/farm_service_locator.dart';

import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:flutter/foundation.dart';

import '../entities/hand_item.dart';
import '../items/weapon_item.dart';
import 'inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/state/equipment_state.dart';

/// Manager for equipment state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
final class EquipmentManager {
  EquipmentManager._() {
    GameLogger.info(
      '[EquipmentManager] Initialized (selection mirrors inventory)',
    );

    // Keep UI in sync when slots change (consumption/move/clear)
    getIt<InventoryManager>().slotsNotifier.addListener(
      _handleInventorySlotsChanged,
    );
  }

  static final instance = EquipmentManager._();

  /// J3: ValueNotifier for cross-module communication
  final ValueNotifier<int> selectedSlotIndexNotifier = ValueNotifier(0);

  int _currentMainHandSlotIndex = 0;

  int get currentMainHandSlotIndex => _currentMainHandSlotIndex;

  // /// In this design, "equipping" means selecting the inventory slot that holds the item.
  // bool equip(Item item, {int? inventorySlotIndex}) {
  //   GameLogger.info('[EquipmentManager] Selecting slot for ${item.name}');

  //   // If caller provided the slot index, just select it.
  //   if (inventorySlotIndex != null) {
  //     return selectSlotIndex(inventorySlotIndex);
  //   }

  //   // Otherwise, find the first slot containing this item id.
  //   final slot = getIt<InventoryManager>().findSlotByItemId(item.id);
  //   if (slot == null) {
  //     GameLogger.warning('[EquipmentManager] Item not in inventory');
  //     return false;
  //   }
  //   return selectSlotIndex(slot.index);
  // }

  bool selectSlotIndex(int index) {
    final slot = getIt<InventoryManager>().getSlotByIndex(index);
    if (slot == null) {
      GameLogger.warning('[EquipmentManager] Slot $index not found');
      return false;
    }

    _currentMainHandSlotIndex = index;
    selectedSlotIndexNotifier.value = index;

    // Update overlays with current item (can be null if slot empty)
    EquipmentState.instance.updateEquippedItem(slot.item);
    GameLogger.info(
      '[EquipmentManager] Selected slot $index (${slot.item?.name ?? 'empty'})',
    );
    return true;
  }

  void clearSelectedEquipment() {
    EquipmentState.instance.updateEquippedItem(null);
  }

  HandItem? getEquippedItem() =>
      getIt<InventoryManager>().getSlotByIndex(_currentMainHandSlotIndex)?.item;

  bool hasEquippedItem() => getEquippedItem() != null;

  List<HandItem> getAllEquippedItems() {
    final item = getEquippedItem();
    return item != null ? [item] : [];
  }

  int getTotalDamage() {
    final mainHand = getEquippedItem();
    if (mainHand == null) return 0;
    if (mainHand is WeaponItem) return mainHand.damage;
    return 0;
  }

  double getTotalDps() {
    final mainHand = getEquippedItem();
    if (mainHand == null) return 0;
    if (mainHand is WeaponItem) return mainHand.damage.toDouble();
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
    return {'selectedSlotIndex': _currentMainHandSlotIndex};
  }

  void fromJson(
    Map<String, dynamic> json,
    HandItem? Function(HandItemId itemId) itemFactory,
  ) {
    _currentMainHandSlotIndex = json['selectedSlotIndex'] as int? ?? 0;
    // Clamp to available slots
    if (_currentMainHandSlotIndex >= getIt<InventoryManager>().maxSlots) {
      _currentMainHandSlotIndex = 0;
    }
    selectedSlotIndexNotifier.value = _currentMainHandSlotIndex;

    // Update UI with current item
    final item = getIt<InventoryManager>()
        .getSlotByIndex(_currentMainHandSlotIndex)
        ?.item;
    EquipmentState.instance.updateEquippedItem(item);

    GameLogger.info(
      '[EquipmentManager] Loaded selected slot $_currentMainHandSlotIndex',
    );
  }

  void reset() {
    _currentMainHandSlotIndex = 0;
    selectedSlotIndexNotifier.value = 0;

    // Notify Flutter overlays
    EquipmentState.instance.updateEquippedItem(
      getIt<InventoryManager>().getSlotByIndex(0)?.item,
    );

    GameLogger.info('[EquipmentManager] Equipment reset');
  }

  void _handleInventorySlotsChanged() {
    final selectedIndex = _currentMainHandSlotIndex;
    final slot = getIt<InventoryManager>().getSlotByIndex(selectedIndex);
    if (slot == null) return;

    // Keep overlay synced with whatever is in the selected slot
    EquipmentState.instance.updateEquippedItem(slot.item);
  }
}
