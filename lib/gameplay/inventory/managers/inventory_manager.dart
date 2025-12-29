import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../constants/inventory_constants.dart';
import '../entities/inventory_slot.dart';
import '../entities/item.dart';

/// Manager for inventory state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
class InventoryManager {
  InventoryManager._() {
    _initializeSlots(_currentMaxSlots);
    developer.log(
      '[InventoryManager] Initialized with $_currentMaxSlots slots',
    );
  }

  static final instance = InventoryManager._();

  int _currentMaxSlots = InventoryConstants.kDefaultInventorySize;

  late List<InventorySlot> _slots;

  /// Notifies listeners when inventory changes (C1: ValueNotifier)
  late final ValueNotifier<List<InventorySlot>> slotsNotifier;

  void _notifyChange() {
    slotsNotifier.value = List.unmodifiable(_slots);
    developer.log(
      '[InventoryManager] Notifying change with ${_slots.length} slots',
    );
  }

  int get maxSlots => _currentMaxSlots;

  bool get canUpgrade =>
      _currentMaxSlots < InventoryConstants.kMaxInventorySize;

  /// Manually set max slots (used by LoadInventoryUseCase)
  void setMaxSlots(int newMaxSlots) {
    if (newMaxSlots == _currentMaxSlots) return;

    if (newMaxSlots > _currentMaxSlots) {
      // Add new slots
      final slotsToAdd = newMaxSlots - _currentMaxSlots;
      for (var i = 0; i < slotsToAdd; i++) {
        _slots.add(InventorySlot(index: _currentMaxSlots + i));
      }
    } else {
      // Remove slots (only empty ones)
      _slots = _slots.sublist(0, newMaxSlots);
    }

    _currentMaxSlots = newMaxSlots;
    _notifyChange();
  }

  bool upgradeInventory() {
    if (!canUpgrade) {
      developer.log('[InventoryManager] Already at max capacity');
      return false;
    }

    final oldSize = _currentMaxSlots;

    if (_currentMaxSlots == InventoryConstants.kDefaultInventorySize) {
      _currentMaxSlots = InventoryConstants.kFirstUpgradeSize;
    } else if (_currentMaxSlots == InventoryConstants.kFirstUpgradeSize) {
      _currentMaxSlots = InventoryConstants.kSecondUpgradeSize;
    }

    final newSlotsNeeded = _currentMaxSlots - oldSize;
    for (var i = 0; i < newSlotsNeeded; i++) {
      _slots.add(InventorySlot(index: oldSize + i));
    }

    developer.log(
      '[InventoryManager] Upgraded from $oldSize to $_currentMaxSlots slots',
    );
    _notifyChange();
    return true;
  }

  void _initializeSlots(int count) {
    _slots = List.generate(count, (index) => InventorySlot(index: index));
    slotsNotifier = ValueNotifier(List.unmodifiable(_slots));
  }

  int get usedSlots => _slots.where((s) => !s.isEmpty).length;

  int get freeSlots => maxSlots - usedSlots;

  List<InventorySlot> get slots => List.unmodifiable(_slots);

  bool get isFull => freeSlots == 0;

  bool get isEmpty => usedSlots == 0;

  bool addItem(Item item, [int quantity = 1]) {
    developer.log('[InventoryManager] Adding $quantity x ${item.name}');

    if (quantity <= 0) {
      developer.log('[InventoryManager] Invalid quantity: $quantity');
      return false;
    }

    int remainingQuantity = quantity;

    if (item.isStackable) {
      for (var i = 0; i < _slots.length && remainingQuantity > 0; i++) {
        final slot = _slots[i];
        if (slot.isEmpty) continue;
        if (slot.item!.id != item.id) continue;
        if (slot.isFull) continue;

        final spaceInSlot = item.maxStackSize - slot.quantity;
        if (spaceInSlot <= 0) continue;

        final amountToAdd = min(remainingQuantity, spaceInSlot);
        _slots[i] = slot.addQuantity(amountToAdd);
        remainingQuantity -= amountToAdd;

        developer.log(
          '[InventoryManager] Stacked $amountToAdd in slot $i, remaining: $remainingQuantity',
        );
      }
    }

    while (remainingQuantity > 0) {
      final emptySlotIndex = _slots.indexWhere((s) => s.isEmpty);
      if (emptySlotIndex == -1) {
        developer.log(
          '[InventoryManager] Inventory full! Cannot add remaining $remainingQuantity',
        );
        return quantity > remainingQuantity;
      }

      final amountForSlot = item.isStackable
          ? min(remainingQuantity, item.maxStackSize)
          : 1;

      _slots[emptySlotIndex] = InventorySlot(
        index: emptySlotIndex,
        item: item,
        quantity: amountForSlot,
      );

      remainingQuantity -= amountForSlot;
      developer.log(
        '[InventoryManager] Created new slot $emptySlotIndex with $amountForSlot items',
      );
    }

    developer.log('[InventoryManager] Item added successfully');
    _notifyChange();
    return true;
  }

  bool removeItem(String itemId, [int quantity = 1]) {
    developer.log('[InventoryManager] Removing $quantity x $itemId');

    if (quantity <= 0) {
      developer.log('[InventoryManager] Invalid quantity: $quantity');
      return false;
    }

    final totalQuantity = getItemQuantity(itemId);
    if (totalQuantity < quantity) {
      developer.log(
        '[InventoryManager] Not enough items. Has: $totalQuantity, needs: $quantity',
      );
      return false;
    }

    int remainingToRemove = quantity;

    for (var i = _slots.length - 1; i >= 0 && remainingToRemove > 0; i--) {
      final slot = _slots[i];
      if (slot.item?.id != itemId) continue;

      final amountToRemove = min(remainingToRemove, slot.quantity);
      _slots[i] = slot.removeQuantity(amountToRemove);
      remainingToRemove -= amountToRemove;

      developer.log('[InventoryManager] Removed $amountToRemove from slot $i');
    }

    developer.log('[InventoryManager] Item removed successfully');
    _notifyChange();
    return true;
  }

  int getItemQuantity(String itemId) {
    return _slots
        .where((s) => s.item?.id == itemId)
        .fold(0, (sum, slot) => sum + slot.quantity);
  }

  bool hasItem(String itemId, [int quantity = 1]) {
    return getItemQuantity(itemId) >= quantity;
  }

  InventorySlot? getSlotByIndex(int index) {
    if (index < 0 || index >= _slots.length) return null;
    return _slots[index];
  }

  InventorySlot? findSlotByItemId(String itemId) {
    for (final slot in _slots) {
      if (slot.item?.id == itemId) return slot;
    }
    return null;
  }

  /// Find first item matching the predicate, starting from afterIndex
  ({int index, Item item})? findItem(
    bool Function(Item item) predicate, {
    int afterIndex = -1,
  }) {
    // Search forward from afterIndex + 1
    for (int i = afterIndex + 1; i < _slots.length; i++) {
      final slot = _slots[i];
      if (slot.item != null && predicate(slot.item!)) {
        return (index: i, item: slot.item!);
      }
    }

    // Wrap around: search from 0 to afterIndex
    if (afterIndex >= 0) {
      for (int i = 0; i <= afterIndex && i < _slots.length; i++) {
        final slot = _slots[i];
        if (slot.item != null && predicate(slot.item!)) {
          return (index: i, item: slot.item!);
        }
      }
    }

    return null;
  }

  /// Find first item matching the predicate, searching backwards
  ({int index, Item item})? findItemReverse(
    bool Function(Item item) predicate, {
    int beforeIndex = -1,
  }) {
    if (beforeIndex == -1) {
      for (int i = _slots.length - 1; i >= 0; i--) {
        final slot = _slots[i];
        if (slot.item != null && predicate(slot.item!)) {
          return (index: i, item: slot.item!);
        }
      }
      return null;
    }

    for (int i = beforeIndex - 1; i >= 0; i--) {
      final slot = _slots[i];
      if (slot.item != null && predicate(slot.item!)) {
        return (index: i, item: slot.item!);
      }
    }

    for (int i = _slots.length - 1; i >= beforeIndex; i--) {
      final slot = _slots[i];
      if (slot.item != null && predicate(slot.item!)) {
        return (index: i, item: slot.item!);
      }
    }

    return null;
  }

  void clear() {
    _slots = List.generate(
      _currentMaxSlots,
      (index) => InventorySlot(index: index),
    );
    _notifyChange();
    developer.log('[InventoryManager] Inventory cleared');
  }
}
