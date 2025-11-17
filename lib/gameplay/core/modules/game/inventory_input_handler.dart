import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/hud_view.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_to_knight_adapter.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/weapon_type.dart';
import 'package:flutter/services.dart';

/// Componente que gerencia entrada de teclado para inventário
class InventoryInputHandler extends GameComponent with KeyboardEventListener {
  bool _isInitialized = false;
  // HUDView? _cachedHUD;

  @override
  void onMount() {
    super.onMount();
    developer.log('[InventoryInput] Component mounted!');
    developer.log('[InventoryInput] gameRef.interface: ${gameRef.interface}');
    _initializeTestItems();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // // Cache o HUD na primeira vez que for encontrado
    // // O gameRef.interface JÁ É o HUDView, não precisa procurar nos children
    // if (_cachedHUD == null && gameRef.interface != null) {
    //   _cachedHUD = gameRef.interface as HUDView?;
    //   if (_cachedHUD != null) {
    //     developer.log('[InventoryInput] HUD encontrado e cacheado!');
    //   }
    // }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // Tecla I: Toggle inventário
      if (event.logicalKey == LogicalKeyboardKey.keyI) {
        _toggleInventory();
        return true;
      }

      // Tecla T: Adicionar itens de teste
      if (event.logicalKey == LogicalKeyboardKey.keyT) {
        _addTestItems();
        return true;
      }

      // Tecla E: Equipar primeiro item de arma do inventário no WEAPON slot
      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        _equipFirstWeapon();
        return true;
      }

      // Tecla U: Desequipar arma do WEAPON slot
      if (event.logicalKey == LogicalKeyboardKey.keyU) {
        _unequipWeapon();
        return true;
      }

      // Tecla O: Equipar primeiro item de arma do inventário no OFFHAND slot
      if (event.logicalKey == LogicalKeyboardKey.keyO) {
        _equipFirstOffhand();
        return true;
      }

      // Tecla P: Desequipar arma do OFFHAND slot
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        _unequipOffhand();
        return true;
      }
    }
    return false;
  }

  void _toggleInventory() {
    // if (_cachedHUD == null) {
    //   developer.log(
    //     '[InventoryInput] HUD ainda não foi carregado. Tentando encontrar...',
    //   );
    //   // O gameRef.interface JÁ É o HUDView
    //   _cachedHUD = gameRef.interface as HUDView?;

    //   if (_cachedHUD == null) {
    //     developer.log('[InventoryInput] HUD não encontrado!');
    //     developer.log('[InventoryInput] Interface: ${gameRef.interface}');
    //     return;
    //   }
    // }

    (gameRef.interface as HUDView).inventoryHUD.toggle();
    // developer.log(
    //   '[InventoryInput] Inventário ${_cachedHUD!.inventoryHUD.isVisible ? "aberto" : "fechado"}',
    // );
  }

  void _initializeTestItems() {
    if (_isInitialized) return;
    _isInitialized = true;

    developer.log('[InventoryInput] Inicializando itens de teste...');

    // Adicionar alguns itens de teste ao inventário
    final sword = ItemFactory.createItem('iron_sword');
    final axe = ItemFactory.createItem('steel_axe');
    final staff = ItemFactory.createItem('fire_staff');
    final shield = ItemFactory.createItem('wooden_shield');
    final potion = ItemFactory.createItem('health_potion');
    final wood = ItemFactory.createItem('wood');
    final seeds = ItemFactory.createItem('tomato_seeds');

    if (sword != null) InventoryManager.instance.addItem(sword);
    if (axe != null) InventoryManager.instance.addItem(axe);
    if (staff != null) InventoryManager.instance.addItem(staff);
    if (shield != null) InventoryManager.instance.addItem(shield);
    if (potion != null) InventoryManager.instance.addItem(potion, 5);
    if (wood != null) InventoryManager.instance.addItem(wood, 50);
    if (seeds != null) InventoryManager.instance.addItem(seeds, 10);

    developer.log(
      '[InventoryInput] Itens de teste adicionados! ${InventoryManager.instance.usedSlots} slots usados',
    );
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
      '[InventoryInput] Procurando SWORD ou AXE para equipar no weapon (Right Hand - Space)...',
    );

    // Percorrer todos os slots do inventário procurando SWORD ou AXE
    for (int i = 0; i < InventoryManager.instance.maxSlots; i++) {
      final slot = InventoryManager.instance.getSlotByIndex(i);
      if (slot != null && slot.item != null) {
        final item = slot.item!;

        // Validar se é weapon
        if (item.type.name != 'weapon') continue;

        // Validar se é WeaponItem
        if (item is! WeaponItem) continue;

        final weaponType = item.weaponType;

        // Validar se é SWORD ou AXE
        // if (!weaponType.contains('sword') && !weaponType.contains('axe')) {
        if (weaponType != WeaponType.sword && weaponType != WeaponType.axe) {
          developer.log(
            '[InventoryInput] Ignorando ${item.name} (tipo: $weaponType) - apenas sword/axe no weapon slot',
          );
          continue;
        }

        // Tentar equipar
        final success = EquipmentManager.instance.equip(
          EquipmentSlotType.weapon,
          item,
        );

        if (success) {
          developer.log(
            '[InventoryInput] ✓ Equipado no weapon (Right Hand): ${item.name} (${item.weaponType})',
          );
          _notifyEquipmentChanged();
        } else {
          developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
        }
        return;
      }
    }

    developer.log(
      '[InventoryInput] Nenhuma SWORD ou AXE encontrada no inventário',
    );
  }

  void _unequipWeapon() {
    final item = EquipmentManager.instance.unequip(EquipmentSlotType.weapon);
    if (item != null) {
      developer.log(
        '[InventoryInput] ✓ Desequipado do weapon (Right Hand): ${item.name}',
      );
      _notifyEquipmentChanged();
    } else {
      developer.log('[InventoryInput] Weapon slot já está vazio');
    }
  }

  void _equipFirstOffhand() {
    developer.log(
      '[InventoryInput] Procurando SHIELD ou STAFF para equipar no offhand (Left Hand - Z)...',
    );

    // Percorrer todos os slots do inventário procurando SHIELD ou STAFF
    for (int i = 0; i < InventoryManager.instance.maxSlots; i++) {
      final slot = InventoryManager.instance.getSlotByIndex(i);
      if (slot != null && slot.item != null) {
        final item = slot.item!;

        // Validar se é weapon
        if (item.type.name != 'weapon') continue;

        // Validar se é WeaponItem
        if (item is! WeaponItem) continue;

        final weaponType = item.weaponType;

        // Validar se é SHIELD ou STAFF ou WAND
        // if (!weaponType.contains('shield') &&
        //           !weaponType.contains('staff') &&
        //           !weaponType.contains('wand')) {
        if (weaponType != WeaponType.shield &&
            weaponType != WeaponType.staff &&
            weaponType != WeaponType.wand) {
          developer.log(
            '[InventoryInput] Ignorando ${item.name} (tipo: $weaponType) - apenas shield/staff/wand no offhand slot',
          );
          continue;
        }

        // Tentar equipar
        final success = EquipmentManager.instance.equip(
          EquipmentSlotType.offhand,
          item,
        );

        if (success) {
          developer.log(
            '[InventoryInput] ✓ Equipado no offhand (Left Hand): ${item.name} (${item.weaponType})',
          );
          _notifyEquipmentChanged();
        } else {
          developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
        }
        return;
      }
    }

    developer.log(
      '[InventoryInput] Nenhuma SHIELD ou STAFF encontrada no inventário',
    );
  }

  void _unequipOffhand() {
    final item = EquipmentManager.instance.unequip(EquipmentSlotType.offhand);
    if (item != null) {
      developer.log(
        '[InventoryInput] ✓ Desequipado do offhand (Left Hand): ${item.name}',
      );
      _notifyEquipmentChanged();
    } else {
      developer.log('[InventoryInput] Offhand slot já está vazio');
    }
  }

  /// Notifica o player que o equipamento mudou
  /// Para recarregar o loadout visual
  void _notifyEquipmentChanged() {
    developer.log('[InventoryInput] Equipamento mudou! Procurando player...');

    // Buscar o CustomPlayerView no jogo
    final players = gameRef.query<CustomPlayerView>();
    if (players.isEmpty) {
      developer.log('[InventoryInput] CustomPlayer não encontrado');
      return;
    }

    final player = players.first;
    developer.log(
      '[InventoryInput] CustomPlayer encontrado! Recarregando loadout...',
    );

    // Criar novo loadout baseado no equipamento atual
    final newLoadout = EquipmentToKnightAdapter.instance
        .createLoadoutFromEquipment();

    // Recarregar loadout do player
    player.reloadEquipmentLoadout(newLoadout);

    developer.log('[InventoryInput] Loadout recarregado com sucesso!');
  }
}
