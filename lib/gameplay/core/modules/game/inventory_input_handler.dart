import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/inputs_state.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/services.dart';

class InventoryInputHandler extends GameComponent with KeyboardEventListener {
  bool _isInitialized = false;
  int _currentMainHandIndex = -1;
  int _currentOffHandIndex = -1; // ← ADICIONAR ESTA LINHA

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
      if (event.logicalKey == KeyboardSetup.kToggleInputsKey) {
        _toggleInputs();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kToggleInventoryKey) {
        _toggleInventory();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kAddTestItemsKey) {
        _addTestItems();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kEquipMainHandKey) {
        _equipMainHand();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kEquipMainHandReverseKey) {
        _equipMainHandReverse();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kUnequipMainHandKey) {
        _unequipMainHand();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kEquipOffhandKey) {
        _equipOffhand();
        return true;
      }

      if (event.logicalKey == KeyboardSetup.kEquipOffhandReverseKey) {
        _equipOffhandReverse();
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
    InventoryState.instance.toggle();
  }

  void _toggleInputs() {
    InputsState.instance.toggle();
  }

  void _initializeTestItems() {
    if (_isInitialized) return;
    _isInitialized = true;

    developer.log('[InventoryInput] Inicializando itens de teste...');

    const testItems = [
      'shovel',
      'staff',
      'ironSword',
      'woodenShield',
      'wateringCan',
      'strawberry_seed_bag',
      'tomato_seed_bag',
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

  void _equipMainHand() {
    developer.log(
      '[InventoryInput] Procurando item equipável para o main hand slot...',
    );

    // Busca o próximo item equipável usando o método helper
    final result = InventoryManager.instance.findItem((item) {
      if (item is! MainHandItem) return false;
      return item.equippedHandType.canBeEquippedInMainHandSlot;
    }, afterIndex: _currentMainHandIndex);

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = EquipmentManager.instance.equip(
      EquipmentSlotType.mainHand,
      item,
    );

    if (success) {
      _currentMainHandIndex = result.index;
      final mainHandItem = item as MainHandItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no main hand: ${item.name} (${mainHandItem.equippedHandType})',
      );
      _notifyEquipmentChanged(mainHandItem.equippedHandType);
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
    }
  }

  void _equipMainHandReverse() {
    developer.log(
      '[InventoryInput] Procurando item equipável ANTERIOR para o main hand slot...',
    );

    // Busca o item equipável anterior usando o método helper
    final result = InventoryManager.instance.findItemReverse((item) {
      if (item is! MainHandItem) return false;
      return item.equippedHandType.canBeEquippedInMainHandSlot;
    }, beforeIndex: _currentMainHandIndex);

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = EquipmentManager.instance.equip(
      EquipmentSlotType.mainHand,
      item,
    );

    if (success) {
      _currentMainHandIndex = result.index;
      final mainHandItem = item as MainHandItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no main hand (reverso): ${item.name} (${mainHandItem.equippedHandType})',
      );
      _notifyEquipmentChanged(mainHandItem.equippedHandType);
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
    }
  }

  void _unequipMainHand() {
    final item = EquipmentManager.instance.unequip(EquipmentSlotType.mainHand);
    if (item != null) {
      developer.log(
        '[InventoryInput] ✓ Desequipado do main hand: ${item.name}',
      );
      final equippedHandType = (item as MainHandItem).equippedHandType;
      _notifyEquipmentChanged(equippedHandType);
      _currentMainHandIndex = -1;
    } else {
      developer.log('[InventoryInput] main hand slot já está vazio');
    }
  }

  void _equipOffhand() {
    developer.log(
      '[InventoryInput] Procurando item equipável para o offhand slot...',
    );

    // ← MODIFICAR ESTA SEÇÃO PARA CICLAR COMO O MAINHAND
    final result = InventoryManager.instance.findItem((item) {
      if (item is! MainHandItem) return false;
      return item
          .equippedHandType
          .canBeEquippedInOffHandSlot; // ← Assumindo que existe este método
    }, afterIndex: _currentOffHandIndex); // ← Usar o índice do offhand

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = EquipmentManager.instance.equip(
      EquipmentSlotType.offHand,
      item,
    );

    if (success) {
      _currentOffHandIndex = result.index; // ← Atualizar o índice do offhand
      final offHandItem = item as MainHandItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no offhand: ${item.name} (${offHandItem.equippedHandType})',
      );
      _notifyEquipmentChanged(offHandItem.equippedHandType);
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
    }
  }

  void _equipOffhandReverse() {
    developer.log(
      '[InventoryInput] Procurando item equipável ANTERIOR para o offhand slot...',
    );

    // Busca o item equipável anterior usando o método helper
    final result = InventoryManager.instance.findItemReverse((item) {
      if (item is! MainHandItem) return false;
      return item.equippedHandType.canBeEquippedInOffHandSlot;
    }, beforeIndex: _currentOffHandIndex);

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = EquipmentManager.instance.equip(
      EquipmentSlotType.offHand,
      item,
    );

    if (success) {
      _currentOffHandIndex = result.index;
      final offHandItem = item as MainHandItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no offhand (reverso): ${item.name} (${offHandItem.equippedHandType})',
      );
      _notifyEquipmentChanged(offHandItem.equippedHandType);
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
    }
  }

  void _unequipOffhand() {
    final item = EquipmentManager.instance.unequip(EquipmentSlotType.offHand);
    if (item != null) {
      developer.log(
        '[InventoryInput] ✓ Desequipado do offhand: ${item.name}',
      );
      final equippedHandType = (item as MainHandItem).equippedHandType;
      _notifyEquipmentChanged(equippedHandType);
      _currentOffHandIndex = -1;
    } else {
      developer.log(
        '[InventoryInput] offhand slot já está vazio',
      );
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
