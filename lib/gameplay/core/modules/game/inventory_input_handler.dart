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

    // TODO(Kevin): NOW - put it all back
    const testItems = [
      'shovel',
      'ironSword',
      'staff',
      'wateringCan',
      'strawberry',
      'tomato',
      'harvestBasket',
    ];

    for (final itemKey in testItems) {
      _debugInsertItem(itemKey);
    }

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

    final testMaterials = [('stone', 100), ('iron_ore', 25)];

    for (final (itemKey, quantity) in testMaterials) {
      final item = ItemFactory.createItem(itemKey);
      if (item != null) {
        InventoryManager.instance.addItem(item, quantity);
        developer.log('[InventoryInput] Adicionado ${quantity}x $itemKey');
      }
    }
  }

  void _equipFirstWeapon() {
    developer.log(
      '[InventoryInput] Procurando item equipável para o weapon slot...',
    );

    // Busca o próximo item equipável usando o método helper
    final result = InventoryManager.instance.findItem((item) {
      if (item is! WeaponItem) return false;
      return item.equippedHandType.canBeEquippedInWeaponSlot;
    }, afterIndex: _currentWeaponIndex);

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = EquipmentManager.instance.equip(
      EquipmentSlotType.weapon,
      item,
    );

    if (success) {
      _currentWeaponIndex = result.index;
      final weaponItem = item as WeaponItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no weapon: ${item.name} (${weaponItem.equippedHandType})',
      );
      _notifyEquipmentChanged(weaponItem.equippedHandType);
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
      '[InventoryInput] Procurando item equipável para o offhand slot...',
    );

    final result = InventoryManager.instance.findItem(
      (item) => item is WeaponItem && item.equippedHandType.isEquippable,
    );

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = EquipmentManager.instance.equip(
      EquipmentSlotType.offhand,
      item,
    );

    if (success) {
      final weaponItem = item as WeaponItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no offhand: ${item.name} (${weaponItem.equippedHandType})',
      );
      _notifyEquipmentChanged(weaponItem.equippedHandType);
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
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
