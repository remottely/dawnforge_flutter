import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../config/inventory_def.dart';
import '../entities/inventory_slot.dart';
import '../entities/hand_item.dart';

/// Manager for inventory state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
class InventoryManager {
  InventoryManager._() {
    _initializeSlots(_currentMaxSlots);
    developer.log(
      '[InventoryManager] Initialized with $_currentMaxSlots slots',
    );
  }

  static final instance = InventoryManager._();

  int _currentMaxSlots = InventoryDef.kSizeInventoryDefault;

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

  bool get canUpgrade => _currentMaxSlots < InventoryDef.kSizeInventoryMax;

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

    if (_currentMaxSlots == InventoryDef.kSizeInventoryDefault) {
      _currentMaxSlots = InventoryDef.kSizeInventoryUpgradeLvl2;
    } else if (_currentMaxSlots == InventoryDef.kSizeInventoryUpgradeLvl2) {
      _currentMaxSlots = InventoryDef.kSizeInventoryUpgradeLvl3;
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

  /// Update a slot at the given index and notify listeners
  void updateSlot(int index, InventorySlot slot) {
    if (index < 0 || index >= _slots.length) {
      developer.log('[InventoryManager] Invalid slot index: $index');
      return;
    }
    _slots[index] = slot;
    _notifyChange();
  }

  /// Consume a quantity from a slot and free it when it reaches zero
  void consumeFromSlot(int index, int amount) {
    if (amount <= 0) return;
    final slot = getSlotByIndex(index);
    if (slot == null || slot.isEmpty) return;

    final updated = slot.removeQuantity(amount);
    updateSlot(index, updated);
  }

  int getItemQuantity(String itemId) {
    return _slots
      .where((s) => s.item?.id.name == itemId)
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
      if (slot.item?.id.name == itemId) return slot;
    }
    return null;
  }

  /// Find first item matching the predicate, starting from afterIndex
  ({int index, HandItem item})? findItem(
    bool Function(HandItem item) predicate, {
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
  ({int index, HandItem item})? findItemReverse(
    bool Function(HandItem item) predicate, {
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

  Map<String, dynamic> toJson() {
    final slotsData = _slots
        .where((s) => !s.isEmpty)
        .map((s) => s.toJson())
        .toList();

    return {'maxSlots': maxSlots, 'slots': slotsData};
  }

  void fromJson(
    Map<String, dynamic> json,
    HandItem? Function(String itemId) itemFactory,
  ) {
    // Load maxSlots first
    final maxSlotsFromJson = json['maxSlots'] as int? ?? _currentMaxSlots;
    if (maxSlotsFromJson != _currentMaxSlots) {
      setMaxSlots(maxSlotsFromJson);
    }

    // Clear all slots
    for (var i = 0; i < _slots.length; i++) {
      _slots[i] = InventorySlot(index: i);
    }

    final slotsData = json['slots'] as List<dynamic>?;
    if (slotsData == null) {
      _notifyChange();
      return;
    }

    for (final slotJson in slotsData) {
      final slot = InventorySlot.fromJson(
        slotJson as Map<String, dynamic>,
        itemFactory,
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
    _currentMaxSlots = InventoryDef.kSizeInventoryDefault;
    _slots = List.generate(
      _currentMaxSlots,
      (index) => InventorySlot(index: index),
    );
    _notifyChange();
    developer.log('[InventoryManager] Reset');
  }
}
