import 'dart:developer' as developer;
import 'dart:math';

import 'constants/inventory_constants.dart';
import 'item_factory.dart';
import 'models/inventory_slot.dart';
import 'models/item.dart';

/// Inventory manager following Stardew Valley patterns.
///
/// **Features:**
/// - Expandable inventory (12 → 24 → 36 slots)
/// - Auto-stacking of stackable items
/// - Quality-aware item management
/// - Drag & drop support (move/swap)
/// - Category-based sorting
/// - Serialization for save/load
///
/// **Stardew Valley Rules:**
/// - Starting inventory: 12 slots
/// - First backpack upgrade: +12 slots (total 24)
/// - Second backpack upgrade: +12 slots (total 36)
/// - Most items stack to 999
/// - Equipment and tools don't stack
final class InventoryManager {
  InventoryManager._() {
    _initializeSlots(_currentMaxSlots);
    developer.log(
      '[InventoryManager] Initialized with $_currentMaxSlots slots',
    );
  }

  static final instance = InventoryManager._();

  // Current inventory capacity (starts at 12, can upgrade to 24 then 36)
  int _currentMaxSlots = InventoryConstants.kDefaultInventorySize;

  late List<InventorySlot> _slots;

  // ============================================================================
  // Inventory Capacity Management
  // ============================================================================

  /// Current maximum number of slots
  int get maxSlots => _currentMaxSlots;

  /// Can upgrade to next backpack tier?
  bool get canUpgrade =>
      _currentMaxSlots < InventoryConstants.kMaxInventorySize;

  /// Upgrade inventory to next tier (24 or 36 slots)
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

    // Expand slots array
    final newSlotsNeeded = _currentMaxSlots - oldSize;
    for (var i = 0; i < newSlotsNeeded; i++) {
      _slots.add(InventorySlot(index: oldSize + i));
    }

    developer.log(
      '[InventoryManager] Upgraded from $oldSize to $_currentMaxSlots slots',
    );
    return true;
  }

  void _initializeSlots(int count) {
    _slots = List.generate(count, (index) => InventorySlot(index: index));
  }

  // ============================================================================
  // Inventory Stats
  // ============================================================================

  /// Quantidade de slots ocupados
  int get usedSlots => _slots.where((s) => !s.isEmpty).length;

  /// Quantidade de slots vazios
  int get freeSlots => maxSlots - usedSlots;

  /// Obter todos os slots (cópia)
  List<InventorySlot> get slots => List.unmodifiable(_slots);

  /// Inventário está cheio?
  bool get isFull => freeSlots == 0;

  /// Inventário está vazio?
  bool get isEmpty => usedSlots == 0;

  /// Adicionar item ao inventário
  ///
  /// Retorna true se o item foi adicionado com sucesso.
  /// Retorna false se o inventário está cheio.
  ///
  /// Se o item é empilhável, tenta empilhar em slots existentes primeiro.
  bool addItem(Item item, [int quantity = 1]) {
    developer.log('[InventoryManager] Adding $quantity x ${item.name}');

    if (quantity <= 0) {
      developer.log('[InventoryManager] Invalid quantity: $quantity');
      return false;
    }

    int remainingQuantity = quantity;

    // 1. Tentar empilhar em slots existentes
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

    // 2. Criar novos slots para quantidade restante
    while (remainingQuantity > 0) {
      final emptySlotIndex = _slots.indexWhere((s) => s.isEmpty);
      if (emptySlotIndex == -1) {
        developer.log(
          '[InventoryManager] Inventory full! Cannot add remaining $remainingQuantity',
        );
        return quantity >
            remainingQuantity; // Retorna true se adicionou pelo menos algo
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
    return true;
  }

  /// Remover item do inventário
  ///
  /// Retorna true se o item foi removido com sucesso.
  /// Retorna false se não há quantidade suficiente.
  bool removeItem(String itemId, [int quantity = 1]) {
    developer.log('[InventoryManager] Removing $quantity x $itemId');

    if (quantity <= 0) {
      developer.log('[InventoryManager] Invalid quantity: $quantity');
      return false;
    }

    // Verificar se tem quantidade suficiente
    final totalQuantity = getItemQuantity(itemId);
    if (totalQuantity < quantity) {
      developer.log(
        '[InventoryManager] Not enough items. Has: $totalQuantity, needs: $quantity',
      );
      return false;
    }

    int remainingToRemove = quantity;

    // Remover dos slots (começando do final para manter ordem)
    for (var i = _slots.length - 1; i >= 0 && remainingToRemove > 0; i--) {
      final slot = _slots[i];
      if (slot.item?.id != itemId) continue;

      final amountToRemove = min(remainingToRemove, slot.quantity);
      _slots[i] = slot.removeQuantity(amountToRemove);
      remainingToRemove -= amountToRemove;

      developer.log('[InventoryManager] Removed $amountToRemove from slot $i');
    }

    developer.log('[InventoryManager] Item removed successfully');
    return true;
  }

  /// Obter quantidade total de um item no inventário
  int getItemQuantity(String itemId) {
    return _slots
        .where((s) => s.item?.id == itemId)
        .fold(0, (sum, slot) => sum + slot.quantity);
  }

  /// Verificar se possui item com quantidade mínima
  bool hasItem(String itemId, [int quantity = 1]) {
    return getItemQuantity(itemId) >= quantity;
  }

  /// Obter slot por índice
  InventorySlot? getSlotByIndex(int index) {
    if (index < 0 || index >= _slots.length) return null;
    return _slots[index];
  }

  /// Obter todos os slots que contêm um item específico
  List<InventorySlot> getSlotsByItemId(String itemId) {
    return _slots.where((s) => s.item?.id == itemId).toList();
  }

  /// Mover item de um slot para outro
  ///
  /// Se o slot de destino está vazio, move o item.
  /// Se contém o mesmo item empilhável, tenta empilhar.
  /// Retorna false se a operação não é possível.
  bool moveItem(int fromIndex, int toIndex) {
    if (fromIndex < 0 || fromIndex >= _slots.length) return false;
    if (toIndex < 0 || toIndex >= _slots.length) return false;
    if (fromIndex == toIndex) return true;

    final fromSlot = _slots[fromIndex];
    final toSlot = _slots[toIndex];

    if (fromSlot.isEmpty) return false;

    // Se destino está vazio, move tudo
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
      return true;
    }

    // Se contém o mesmo item empilhável, tenta empilhar
    if (toSlot.item!.id == fromSlot.item!.id && toSlot.item!.isStackable) {
      final spaceInTo = toSlot.item!.maxStackSize - toSlot.quantity;
      final amountToMove = min(fromSlot.quantity, spaceInTo);

      if (amountToMove > 0) {
        _slots[toIndex] = toSlot.addQuantity(amountToMove);
        _slots[fromIndex] = fromSlot.removeQuantity(amountToMove);
        developer.log(
          '[InventoryManager] Stacked $amountToMove from $fromIndex to $toIndex',
        );
        return true;
      }
    }

    return false;
  }

  /// Trocar conteúdo de dois slots
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
    return true;
  }

  /// Limpar inventário (remove todos os itens)
  void clear() {
    _slots = List.generate(
      _currentMaxSlots,
      (index) => InventorySlot(index: index),
    );
    developer.log('[InventoryManager] Inventory cleared');
  }

  /// Ordenar inventário por tipo de item
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
  }

  /// Ordenar inventário por raridade
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
  }

  /// Ordenar inventário alfabeticamente por nome
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
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() {
    final slotsData = _slots
        .where((s) => !s.isEmpty)
        .map((s) => s.toJson())
        .toList();

    return {'maxSlots': maxSlots, 'slots': slotsData};
  }

  /// Deserialização de JSON
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
  }

  /// Resetar inventário (limpar tudo)
  void reset() {
    clear();
    developer.log('[InventoryManager] Reset');
  }
}
