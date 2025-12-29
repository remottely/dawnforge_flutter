import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'constants/inventory_constants.dart';
import 'item_factory.dart';
import 'entities/inventory_slot.dart';
import 'entities/item.dart';

final class InventoryManager {
  InventoryManager._() {
    _initializeSlots(_currentMaxSlots);
    developer.log(
      '[InventoryManager] Initialized with $_currentMaxSlots slots',
    );
  }

  static final instance = InventoryManager._();

  int _currentMaxSlots = InventoryConstants.kDefaultInventorySize;

  late List<InventorySlot> _slots;

  /// Notifies listeners when inventory changes with the current slots state
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

  /// Find first item matching the predicate, starting from afterIndex
  /// Returns null if no item is found
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

  /// Find first item matching the predicate, searching backwards from beforeIndex
  /// Returns null if no item is found
  ({int index, Item item})? findItemReverse(
    bool Function(Item item) predicate, {
    int beforeIndex = -1,
  }) {
    // Se beforeIndex = -1 (primeira busca), busca do final ao início (sem wrap)
    if (beforeIndex == -1) {
      for (int i = _slots.length - 1; i >= 0; i--) {
        final slot = _slots[i];
        if (slot.item != null && predicate(slot.item!)) {
          return (index: i, item: slot.item!);
        }
      }
      return null; // Não encontrou nada
    }

    // Se beforeIndex >= 0, busca de beforeIndex-1 até 0
    for (int i = beforeIndex - 1; i >= 0; i--) {
      final slot = _slots[i];
      if (slot.item != null && predicate(slot.item!)) {
        return (index: i, item: slot.item!);
      }
    }

    // Wrap around: do final até beforeIndex (inclusive)
    for (int i = _slots.length - 1; i >= beforeIndex; i--) {
      final slot = _slots[i];
      if (slot.item != null && predicate(slot.item!)) {
        return (index: i, item: slot.item!);
      }
    }

    return null;
  }

  List<InventorySlot> getSlotsByItemId(String itemId) {
    return _slots.where((s) => s.item?.id == itemId).toList();
  }

  bool moveItem(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _slots.length) return false;
    if (toIndex < 0 || toIndex >= _slots.length) return false;
    if (fromIndex == toIndex) return true;

    final fromSlot = _slots[fromIndex];
    final toSlot = _slots[toIndex];

    if (fromSlot.isEmpty) return false;

    if (toSlot.isEmpty) {
      _slots[toIndex] = InventorySlot(
        index: toIndex,
        item: fromSlot.item,
        quantity: fromSlot.quantity,
      );
      _slots[fromIndex] = InventorySlot(index: fromIndex);
      developer.log(
        '[InventoryManager] Moved item from $fromIndex to $toIndex',
      );
      _notifyChange();
      return true;
    }

    if (toSlot.item!.id == fromSlot.item!.id && toSlot.item!.isStackable) {
      final spaceInTo = toSlot.item!.maxStackSize - toSlot.quantity;
      final amountToMove = min(fromSlot.quantity, spaceInTo);

      if (amountToMove > 0) {
        _slots[toIndex] = toSlot.addQuantity(amountToMove);
        _slots[fromIndex] = fromSlot.removeQuantity(amountToMove);
        developer.log(
          '[InventoryManager] Stacked $amountToMove from $fromIndex to $toIndex',
        );
        _notifyChange();
        return true;
      }
    }

    return false;
  }

  bool swapSlots(int index1, int index2) {
    if (index1 < 0 || index1 >= _slots.length) return false;
    if (index2 < 0 || index2 >= _slots.length) return false;
    if (index1 == index2) return true;

    final slot1 = _slots[index1];
    final slot2 = _slots[index2];

    _slots[index1] = InventorySlot(
      index: index1,
      item: slot2.item,
      quantity: slot2.quantity,
    );
    _slots[index2] = InventorySlot(
      index: index2,
      item: slot1.item,
      quantity: slot1.quantity,
    );

    developer.log('[InventoryManager] Swapped slots $index1 and $index2');
    _notifyChange();
    return true;
  }

  void clear() {
    _slots = List.generate(
      _currentMaxSlots,
      (index) => InventorySlot(index: index),
    );
    developer.log('[InventoryManager] Inventory cleared');
    _notifyChange();
  }

  void sortByType() {
    final occupiedSlots = _slots.where((s) => !s.isEmpty).toList();
    occupiedSlots.sort(
      (a, b) => a.item!.type.index.compareTo(b.item!.type.index),
    );

    clear();
    for (var i = 0; i < occupiedSlots.length; i++) {
      _slots[i] = InventorySlot(
        index: i,
        item: occupiedSlots[i].item,
        quantity: occupiedSlots[i].quantity,
      );
    }

    developer.log('[InventoryManager] Sorted by type');
    _notifyChange();
  }

  void sortByRarity() {
    final occupiedSlots = _slots.where((s) => !s.isEmpty).toList();
    occupiedSlots.sort(
      (a, b) => b.item!.rarity.index.compareTo(a.item!.rarity.index),
    );

    clear();
    for (var i = 0; i < occupiedSlots.length; i++) {
      _slots[i] = InventorySlot(
        index: i,
        item: occupiedSlots[i].item,
        quantity: occupiedSlots[i].quantity,
      );
    }

    developer.log('[InventoryManager] Sorted by rarity');
    _notifyChange();
  }

  void sortByName() {
    final occupiedSlots = _slots.where((s) => !s.isEmpty).toList();
    occupiedSlots.sort((a, b) => a.item!.name.compareTo(b.item!.name));

    clear();
    for (var i = 0; i < occupiedSlots.length; i++) {
      _slots[i] = InventorySlot(
        index: i,
        item: occupiedSlots[i].item,
        quantity: occupiedSlots[i].quantity,
      );
    }

    developer.log('[InventoryManager] Sorted by name');
    _notifyChange();
  }

  Map<String, dynamic> toJson() {
    final slotsData = _slots
        .where((s) => !s.isEmpty)
        .map((s) => s.toJson())
        .toList();

    return {'maxSlots': maxSlots, 'slots': slotsData};
  }

  void fromJson(Map<String, dynamic> json) {
    clear();

    final slotsData = json['slots'] as List<dynamic>?;
    if (slotsData == null) return;

    for (final slotJson in slotsData) {
      final slot = InventorySlot.fromJson(
        slotJson as Map<String, dynamic>,
        ItemFactory.createItem,
      );

      if (slot.index >= 0 && slot.index < _slots.length) {
        _slots[slot.index] = slot;
      }
    }

    developer.log(
      '[InventoryManager] Loaded ${slotsData.length} slots from JSON',
    );
    _notifyChange();
  }

  void reset() {
    clear();
    developer.log('[InventoryManager] Reset');
    _notifyChange();
  }
}
