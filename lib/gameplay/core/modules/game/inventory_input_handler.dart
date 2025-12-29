import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/tutorial_inputs/tutorial_inputs_state.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/input_def.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/usecases/add_item_use_case.dart';
import 'package:darkness_dungeon/gameplay/inventory/usecases/unequip_item_use_case.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/equipment_slot.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

/// Handles inventory and equipment inputs from both keyboard and joystick/mobile
class InventoryInputHandler extends GameComponent
    with KeyboardEventListener, PlayerControllerListener {
  final PlayerController? playerController;

  bool _isInitialized = false;

  InventoryInputHandler({this.playerController});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (playerController != null) {
      playerController!.addObserver(this);
    }
    getIt<EquipmentManager>().selectedSlotIndexNotifier.addListener(
      _handleSelectedSlotChanged,
    );
  }

  @override
  void onRemove() {
    if (playerController != null) {
      playerController!.removeObserver(this);
    }
    getIt<EquipmentManager>().selectedSlotIndexNotifier.removeListener(
      _handleSelectedSlotChanged,
    );
    super.onRemove();
  }

  @override
  void onMount() {
    super.onMount();
    developer.log('[InventoryInput] Component mounted!');
    developer.log('[InventoryInput] gameRef.interface: ${gameRef.interface}');
    _initializeTestItems();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      _handleAction(event.id);
    }
  }

  bool _handleAction(dynamic actionId) {
    if (InputDef.isToggleInventoryAction(actionId)) {
      _toggleInventory();
      return true;
    }

    if (InputDef.isToggleTutorialInputsAction(actionId)) {
      _toggleInputs();
      return true;
    }

    if (InputDef.isAddTestItemsAction(actionId)) {
      _addTestItems();
      return true;
    }

    if (InputDef.isEquipMainHandAction(actionId)) {
      _equipMainHand();
      return true;
    }

    if (InputDef.isEquipMainHandReverseAction(actionId)) {
      _equipMainHandReverse();
      return true;
    }

    if (InputDef.isUnequipMainHandAction(actionId)) {
      _unequipMainHand();
      return true;
    }

    return false;
  }

  void _toggleInventory() {
    InventoryState.instance.toggle();
  }

  void _toggleInputs() {
    TutorialInputsState.instance.toggle();
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
      '[InventoryInput] Itens de teste adicionados! ${getIt<InventoryManager>().usedSlots} slots usados',
    );
  }

  void _debugInsertItem(String itemKey) {
    if (getIt<InventoryManager>().getItemQuantity(itemKey) == 0) {
      getIt<AddItemUseCase>()(itemKey, 1);
    }
  }

  void _addTestItems() {
    developer.log('[InventoryInput] Adicionando mais itens de teste...');

    final testMaterials = [('stone', 100), ('iron_ore', 25)];

    for (final (itemKey, quantity) in testMaterials) {
      final success = getIt<AddItemUseCase>()(itemKey, quantity);
      if (success) {
        developer.log('[InventoryInput] Adicionado ${quantity}x $itemKey');
      }
    }
  }

  void _equipMainHand() {
    developer.log(
      '[InventoryInput] Procurando item equipável para o main hand slot...',
    );

    // Busca o próximo item equipável usando o método helper
    final currentSlotIndex = getIt<EquipmentManager>().currentMainHandSlotIndex;
    final result = getIt<InventoryManager>().findItem((item) {
      return item is MainHandItem;
    }, afterIndex: currentSlotIndex);

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = getIt<EquipmentManager>().selectSlotIndex(result.index);

    if (success) {
      final mainHandItem = item as MainHandItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no main hand: ${item.name} (${mainHandItem.equippedHandType})',
      );
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
    }
  }

  void _equipMainHandReverse() {
    developer.log(
      '[InventoryInput] Procurando item equipável ANTERIOR para o main hand slot...',
    );

    // Busca o item equipável anterior usando o método helper
    final currentSlotIndex = getIt<EquipmentManager>().currentMainHandSlotIndex;
    final result = getIt<InventoryManager>().findItemReverse((item) {
      return item is MainHandItem;
    }, beforeIndex: currentSlotIndex);

    if (result == null) {
      developer.log(
        '[InventoryInput] Nenhum item equipável encontrado no inventário',
      );
      return;
    }

    final item = result.item;
    final success = getIt<EquipmentManager>().selectSlotIndex(result.index);

    if (success) {
      final mainHandItem = item as MainHandItem;
      developer.log(
        '[InventoryInput] ✓ Equipado no main hand (reverso): ${item.name} (${mainHandItem.equippedHandType})',
      );
    } else {
      developer.log('[InventoryInput] ✗ Falha ao equipar: ${item.name}');
    }
  }

  void _unequipMainHand() {
    final item = getIt<UnequipItemUseCase>()(EquipmentSlotType.mainHand);
    if (item != null) {
      developer.log(
        '[InventoryInput] ✓ Desequipado do main hand: ${item.name}',
      );
      _notifyEquipmentChanged(null);
    } else {
      developer.log('[InventoryInput] main hand slot já está vazio');
    }
  }

  void _notifyEquipmentChanged(EquippedHandType? equippedHandType) {
    final players = gameRef.query<DDBasePlayerView>();
    if (players.isEmpty) {
      return;
    }

    final player = players.first;

    player.controller.model.setEquipment(equippedHandType);
  }

  void _handleSelectedSlotChanged() {
    final selectedItem = getIt<EquipmentManager>().getEquippedItem(
      EquipmentSlotType.mainHand,
    );
    final equippedHandType = selectedItem is MainHandItem
        ? selectedItem.equippedHandType
        : null;
    _notifyEquipmentChanged(equippedHandType);
  }
}
