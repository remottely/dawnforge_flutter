import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay/gameplay_hud_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/item_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/services.dart';

class InventoryInputHandler extends GameComponent with KeyboardEventListener {
  bool _isInitialized = false;
  int _currentWeaponIndex = -1;

  @override
  void onMount() {
    super.onMount();
    developer.log('[InventoryInput] Component mounted!');
    developer.log('[InventoryInput] gameRef.interface: ${gameRef.interface}');
    _initializeTestItems();
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == KeyboardSetup.kToggleInventoryKey) {
        _toggleInventory();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kAddTestItemsKey) {
        _addTestItems();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kEquipWeaponKey) {
        _equipFirstWeapon();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kUnequipWeaponKey) {
        _unequipWeapon();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kEquipOffhandKey) {
        _equipFirstOffhand();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kUnequipOffhandKey) {
        _unequipOffhand();
        return true;
      }
    }
    return false;
  }

  void _toggleInventory() {
    (gameRef.interface as GameplayHUDView).inventoryHUD.toggleIsVisible();
  }

  void _initializeTestItems() {
    if (_isInitialized) return;
    _isInitialized = true;

    developer.log('[InventoryInput] Inicializando itens de teste...');

    _debugInsertItem('shovel');
    _debugInsertItem('ironSword');
    _debugInsertItem('staff');
    _debugInsertItem('wateringCan');
    _debugInsertItem('strawberry');
    _debugInsertItem('harvestBasket');

    developer.log(
      '[InventoryInput] Itens de teste adicionados! ${InventoryManager.instance.usedSlots} slots usados',
    );
  }

  void _debugInsertItem(String itemKey) {
    if (InventoryManager.instance.getItemQuantity(itemKey) == 0) {
      final item = ItemFactory.createItem(itemKey);
      if (item != null) {
        InventoryManager.instance.addItem(item);
      }
    }
  }

  void _addTestItems() {
    developer.log('[InventoryInput] Adicionando mais itens de teste...');

    final stone = ItemFactory.createItem('stone');
    final ironOre = ItemFactory.createItem('iron_ore');

    if (stone != null) {
      InventoryManager.instance.addItem(stone, 100);
      developer.log('[InventoryInput] Adicionado 100x stone');
    }

    if (ironOre != null) {
      InventoryManager.instance.addItem(ironOre, 25);
      developer.log('[InventoryInput] Adicionado 25x iron_ore');
    }
  }

  void _equipFirstWeapon() {
    developer.log(
      '[InventoryInput] Procurando SWORD ou AXE para equipar no weapon (Space)...',
    );

    final max = InventoryManager.instance.maxSlots;
    int? foundIndex;

    for (int i = _currentWeaponIndex + 1; i < max; i++) {
      final slot = InventoryManager.instance.getSlotByIndex(i);
      if (slot == null || slot.item == null) continue;
      final item = slot.item!;
      if (item.type != ItemType.weapon) continue;
      if (item is! WeaponItem) continue;
      final equippedHandType = item.equippedHandType;
      if (equippedHandType != EquippedHandType.ironSword &&
          equippedHandType != EquippedHandType.staff &&
          equippedHandType != EquippedHandType.shovel &&
          equippedHandType != EquippedHandType.wateringCan &&
          equippedHandType != EquippedHandType.strawberry &&
          equippedHandType != EquippedHandType.harvestBasket)
        continue;
      foundIndex = i;
      break;
    }

    if (foundIndex == null) {
      for (int i = 0; i <= _currentWeaponIndex && i < max; i++) {
        final slot = InventoryManager.instance.getSlotByIndex(i);
        if (slot == null || slot.item == null) continue;
        final item = slot.item!;
        if (item.type != ItemType.weapon) continue;
        if (item is! WeaponItem) continue;
        final equippedHandType = item.equippedHandType;
        if (equippedHandType != EquippedHandType.ironSword &&
            equippedHandType != EquippedHandType.staff &&
            equippedHandType != EquippedHandType.shovel &&
            equippedHandType != EquippedHandType.wateringCan &&
            equippedHandType != EquippedHandType.strawberry &&
            equippedHandType != EquippedHandType.harvestBasket)
          continue;
        foundIndex = i;
        break;
      }
    }

    if (foundIndex == null) {
      developer.log(
        '[InventoryInput] Nenhuma SWORD ou AXE encontrada no inventário',
      );
      return;
    }

    final slot = InventoryManager.instance.getSlotByIndex(foundIndex);
    if (slot == null || slot.item == null) return;
    final item = slot.item!;

    final success = EquipmentManager.instance.equip(
      EquipmentSlotType.weapon,
      item,
    );

    if (success) {
      _currentWeaponIndex = foundIndex;
      developer.log(
        '[InventoryInput] ✓ Equipado no weapon: ${item.name} (${(item is WeaponItem) ? item.equippedHandType : 'unknown'})',
      );
      if (item is WeaponItem) _notifyEquipmentChanged(item.equippedHandType);
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
    }
  }

  void _unequipWeapon() {
    final item = EquipmentManager.instance.unequip(EquipmentSlotType.weapon);
    if (item != null) {
      developer.log('[InventoryInput] ✓ Desequipado do weapon: ${item.name}');
      final equippedHandType = (item as WeaponItem).equippedHandType;
      _notifyEquipmentChanged(equippedHandType);
      _currentWeaponIndex = -1;
    } else {
      developer.log('[InventoryInput] Weapon slot já está vazio');
    }
  }

  void _equipFirstOffhand() {
    developer.log(
      '[InventoryInput] Procurando SHIELD ou STAFF para equipar no offhand (Z)...',
    );

    for (int i = 0; i < InventoryManager.instance.maxSlots; i++) {
      final slot = InventoryManager.instance.getSlotByIndex(i);
      if (slot != null && slot.item != null) {
        final item = slot.item!;

        if (item.type != ItemType.weapon) continue;

        if (item is! WeaponItem) continue;

        final equippedHandType = item.equippedHandType;

        final success = EquipmentManager.instance.equip(
          EquipmentSlotType.offhand,
          item,
        );

        if (success) {
          developer.log(
            '[InventoryInput] ✓ Equipado no offhand: ${item.name} (${item.equippedHandType})',
          );
          _notifyEquipmentChanged(equippedHandType);
        }

        return;
      }
    }
  }

  void _unequipOffhand() {
    final item = EquipmentManager.instance.unequip(EquipmentSlotType.offhand);
    if (item != null) {
      final equippedHandType = (item as WeaponItem).equippedHandType;
      _notifyEquipmentChanged(equippedHandType);
      _notifyEquipmentChanged(equippedHandType);
    }
  }

  void _notifyEquipmentChanged(EquippedHandType equippedHandType) {
    final players = gameRef.query<DDBasePlayerView>();
    if (players.isEmpty) {
      return;
    }

    final player = players.first;

    player.controller.model.setEquipment(equippedHandType);
  }
}
