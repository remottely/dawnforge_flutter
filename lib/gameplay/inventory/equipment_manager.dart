import 'dart:developer' as developer;

import 'inventory_manager.dart';
import 'item_factory.dart';
import 'items/weapon_item.dart';
import 'models/equipment_slot.dart';
import 'models/item.dart';

/// Gerenciador singleton de equipamentos do jogador
///
/// Responsável por:
/// - Equipar/desequipar itens
/// - Validar compatibilidade de itens com slots
/// - Calcular stats totais dos equipamentos
/// - Serialização dos equipamentos
final class EquipmentManager {
  EquipmentManager._() {
    // Inicializar todos os slots vazios
    for (final slotType in EquipmentSlotType.values) {
      _equipmentSlots[slotType] = EquipmentSlot(slotType: slotType);
    }
    developer.log(
      '[EquipmentManager] Initialized with ${_equipmentSlots.length} slots',
    );
  }

  static final instance = EquipmentManager._();

  final Map<EquipmentSlotType, EquipmentSlot> _equipmentSlots = {};

  /// Obter todos os slots de equipamento (cópia)
  Map<EquipmentSlotType, EquipmentSlot> get equipmentSlots =>
      Map.unmodifiable(_equipmentSlots);

  /// Equipar item em um slot
  ///
  /// Retorna true se o item foi equipado com sucesso.
  /// Retorna false se:
  /// - Item não pode ser equipado no slot
  /// - Item não está no inventário
  /// - Inventário está cheio (não pode desequipar item atual)
  bool equip(EquipmentSlotType slotType, Item item) {
    developer.log('[EquipmentManager] Equipping ${item.name} to $slotType');

    // 1. Validar se item pode ser equipado neste slot
    if (!_canEquipItemInSlot(item, slotType)) {
      developer.log('[EquipmentManager] Item cannot be equipped in this slot');
      return false;
    }

    // 2. Se já há item equipado, desequipar primeiro
    final currentItem = getEquippedItem(slotType);
    if (currentItem != null) {
      if (!InventoryManager.instance.addItem(currentItem)) {
        developer.log('[EquipmentManager] Inventory full, cannot equip');
        return false;
      }
    }

    // 3. Remover item do inventário
    if (!InventoryManager.instance.removeItem(item.id, 1)) {
      // Se falhou, devolver o item anterior ao equipamento
      if (currentItem != null) {
        InventoryManager.instance.removeItem(currentItem.id, 1);
        _equipmentSlots[slotType] = _equipmentSlots[slotType]!.equip(
          currentItem,
        );
      }
      developer.log('[EquipmentManager] Item not in inventory');
      return false;
    }

    // 4. Equipar item
    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.equip(item);
    developer.log('[EquipmentManager] Item equipped successfully');
    return true;
  }

  /// Desequipar item de um slot
  ///
  /// Retorna o item desequipado ou null se:
  /// - Slot está vazio
  /// - Inventário está cheio (não pode adicionar item)
  Item? unequip(EquipmentSlotType slotType) {
    developer.log('[EquipmentManager] Unequipping from $slotType');

    final item = getEquippedItem(slotType);
    if (item == null) {
      developer.log('[EquipmentManager] Slot is empty');
      return null;
    }

    // Tentar adicionar ao inventário
    if (!InventoryManager.instance.addItem(item)) {
      developer.log('[EquipmentManager] Inventory full, cannot unequip');
      return null;
    }

    // Desequipar
    _equipmentSlots[slotType] = _equipmentSlots[slotType]!.unequip();
    developer.log('[EquipmentManager] Item unequipped successfully');
    return item;
  }

  /// Obter item equipado em um slot
  Item? getEquippedItem(EquipmentSlotType slotType) {
    return _equipmentSlots[slotType]?.equippedItem;
  }

  /// Verificar se slot está ocupado
  bool isSlotOccupied(EquipmentSlotType slotType) {
    return _equipmentSlots[slotType]?.isOccupied ?? false;
  }

  /// Obter todos os itens equipados
  List<Item> getAllEquippedItems() {
    return _equipmentSlots.values
        .where((slot) => slot.isOccupied)
        .map((slot) => slot.equippedItem!)
        .toList();
  }

  /// Validar se item pode ser equipado no slot
  bool _canEquipItemInSlot(Item item, EquipmentSlotType slotType) {
    // Armas podem ser equipadas em weapon ou offhand
    if (item is WeaponItem) {
      return slotType == EquipmentSlotType.weapon ||
          slotType == EquipmentSlotType.offhand;
    }

    // TODO: Implementar validação para outros tipos de equipamento
    // (armaduras, acessórios, etc) quando forem criados

    return false;
  }

  /// Calcular dano total de todas as armas equipadas
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

  /// Calcular DPS total de todas as armas equipadas
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

  /// Calcular defesa total (placeholder para quando implementar armaduras)
  int getTotalDefense() {
    // TODO: Implementar quando criar itens de armadura
    return 0;
  }

  /// Obter todos os stats dos equipamentos
  Map<String, dynamic> getTotalStats() {
    return {
      'damage': getTotalDamage(),
      'dps': getTotalDps(),
      'defense': getTotalDefense(),
    };
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() {
    final slotsData = <String, dynamic>{};

    for (final entry in _equipmentSlots.entries) {
      if (entry.value.isOccupied) {
        slotsData[entry.key.toJson()] = entry.value.toJson();
      }
    }

    return {'equipmentSlots': slotsData};
  }

  /// Deserialização de JSON
  void fromJson(Map<String, dynamic> json) {
    // Limpar slots
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

  /// Resetar equipamentos (remove tudo)
  void reset() {
    for (final slotType in EquipmentSlotType.values) {
      _equipmentSlots[slotType] = EquipmentSlot(slotType: slotType);
    }
    developer.log('[EquipmentManager] Reset');
  }

  /// Desequipar todos os itens (move para inventário)
  bool unequipAll() {
    developer.log('[EquipmentManager] Unequipping all items');

    final itemsToUnequip = getAllEquippedItems();

    // Verificar se há espaço no inventário
    if (itemsToUnequip.length > InventoryManager.instance.freeSlots) {
      developer.log('[EquipmentManager] Not enough inventory space');
      return false;
    }

    // Desequipar todos
    for (final slotType in EquipmentSlotType.values) {
      if (isSlotOccupied(slotType)) {
        unequip(slotType);
      }
    }

    developer.log('[EquipmentManager] All items unequipped');
    return true;
  }
}
