import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/tutorial_inputs/tutorial_inputs_state.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/input_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/state/inventory_state.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/usecases/add_item_use_case.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/main_hand_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_id.dart';

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
    // Check toolbar slot number keys (1-0 in SV style)
    final slotNumber = InputDef.getToolbarSlotNumber(actionId);
    if (slotNumber != null) {
      _selectSlotByNumber(slotNumber);
      return true;
    }

    if (InputDef.isToggleInventoryAction(actionId)) {
      if (AppEnvironment.kIsDebugMode) {
        _toggleInventory(); // TODO(kevin): remove it?
      }
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

    if (InputDef.isCraftingAction(actionId)) {
      _openCrafting();
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

    // Se já tem itens (carregados de save), não adicionar itens de teste
    final inventoryManager = getIt<InventoryManager>();
    if (inventoryManager.usedSlots > 0) {
      developer.log(
        '[InventoryInput] ✓ Inventário já possui ${inventoryManager.usedSlots} itens (carregado de save), pulando itens de teste',
      );
      _ensureInitialSlotSelection();
      return;
    }

    developer.log('[InventoryInput] Inicializando itens de teste...');

    const testItems = [
      (HandItemId.shovel, 1),
      (HandItemId.radish_seed_bag, 50),
      (HandItemId.strawberry_seed_bag, 50),
      (HandItemId.apple_seed_bag, 50),
      (HandItemId.tomato_seed_bag, 50),
      (HandItemId.wateringCan, 1),
      (HandItemId.harvestBasket, 1),
      (HandItemId.ironSword, 1),
      (HandItemId.staff, 1),
    ];

    _addItems(testItems);

    developer.log(
      '[InventoryInput] Itens de teste adicionados! ${getIt<InventoryManager>().usedSlots} slots usados',
    );

    // Ensure first non-empty slot is selected
    _ensureInitialSlotSelection();
  }

  void _ensureInitialSlotSelection() {
    final equipmentManager = getIt<EquipmentManager>();
    final currentSlotIndex = equipmentManager.currentMainHandSlotIndex;
    final currentSlot = getIt<InventoryManager>().getSlotByIndex(
      currentSlotIndex,
    );

    // If current slot already has any item, select it to sync UI
    if (currentSlot?.item != null) {
      developer.log(
        '[InventoryInput] Slot $currentSlotIndex already has item: ${currentSlot?.item?.name}, syncing with UI',
      );
      equipmentManager.selectSlotIndex(currentSlotIndex);
      return;
    }

    // Find first non-empty slot and select it
    final result = getIt<InventoryManager>().findItem((_) => true);

    if (result != null) {
      equipmentManager.selectSlotIndex(result.index);
      developer.log(
        '[InventoryInput] Auto-selected slot ${result.index} with ${result.item.name}',
      );
    } else {
      developer.log(
        '[InventoryInput] No items found in inventory - slot 0 remains selected (empty)',
      );
    }
  }

  void _debugInsertItem(HandItemId itemKey) {
    if (getIt<InventoryManager>().getItemQuantity(itemKey.name) == 0) {
      getIt<AddItemUseCase>()(itemKey, 1);
    }
  }

  void _addItems(List<(HandItemId, int)> items) {
    final success = getIt<AddItemUseCase>().addMultiple(items);

    if (!success) {
      developer.log(
        '[InventoryInput] Nenhum item adicionado (talvez inventário cheio)',
      );
    }
  }

  void _addTestItems() {
    developer.log('[InventoryInput] Adicionando mais itens de teste...');

    final testMaterials = [
      (HandItemId.stone, 100),
      (HandItemId.iron_ore, 25),
    ];

    for (final (itemKey, quantity) in testMaterials) {
      final success = getIt<AddItemUseCase>()(itemKey, quantity);
      if (success) {
        developer.log('[InventoryInput] Adicionado ${quantity}x $itemKey');
      }
    }
  }

  void _equipMainHand() {
    developer.log(
      '[InventoryInput] Procurando próximo item no inventário para selecionar...',
    );

    final inventoryManager = getIt<InventoryManager>();
    final equipmentManager = getIt<EquipmentManager>();

    if (inventoryManager.maxSlots == 0) {
      developer.log('[InventoryInput] Nenhum slot disponível no inventário');
      return;
    }

    final currentSlotIndex = equipmentManager.currentMainHandSlotIndex;
    final nextIndex = (currentSlotIndex + 1) % inventoryManager.maxSlots;

    final success = equipmentManager.selectSlotIndex(nextIndex);

    if (success) {
      final item = inventoryManager.getSlotByIndex(nextIndex)?.item;
      final handSuffix = item is MainHandItem
          ? ' (${item.equippedHandType})'
          : '';
      final itemName = item?.name ?? 'vazio';
      developer.log(
        '[InventoryInput] ✓ Slot selecionado: $itemName$handSuffix',
      );
    } else {
      developer.log(
        '[InventoryInput] ✗ Falha ao selecionar slot ${nextIndex + 1}',
      );
    }
  }

  void _equipMainHandReverse() {
    developer.log(
      '[InventoryInput] Procurando item anterior no inventário para selecionar...',
    );

    final inventoryManager = getIt<InventoryManager>();
    final equipmentManager = getIt<EquipmentManager>();

    if (inventoryManager.maxSlots == 0) {
      developer.log('[InventoryInput] Nenhum slot disponível no inventário');
      return;
    }

    final currentSlotIndex = equipmentManager.currentMainHandSlotIndex;
    final previousIndex =
        (currentSlotIndex - 1 + inventoryManager.maxSlots) %
        inventoryManager.maxSlots;

    final success = equipmentManager.selectSlotIndex(previousIndex);

    if (success) {
      final item = inventoryManager.getSlotByIndex(previousIndex)?.item;
      final handSuffix = item is MainHandItem
          ? ' (${item.equippedHandType})'
          : '';
      final itemName = item?.name ?? 'vazio';
      developer.log(
        '[InventoryInput] ✓ Slot selecionado (reverso): $itemName$handSuffix',
      );
    } else {
      developer.log(
        '[InventoryInput] ✗ Falha ao selecionar slot ${previousIndex + 1}',
      );
    }
  }

  void _notifyEquipmentChanged(HandItemId? equippedHandType) {
    // Equipment is now queried dynamically from the player model
    // No need to notify - the model always returns the current selected slot
    developer.log(
      '[InventoryInput] Equipment changed to: ${equippedHandType?.name ?? "empty"}',
    );
  }

  void _handleSelectedSlotChanged() {
    final selectedItem = getIt<EquipmentManager>().getEquippedItem();
    final equippedHandType = selectedItem is MainHandItem
        ? selectedItem.equippedHandType
        : null;
    _notifyEquipmentChanged(equippedHandType);
  }

  // ========== SV STYLE SLOT SELECTION ==========
  void _selectSlotByNumber(int slotIndex) {
    final inventoryManager = getIt<InventoryManager>();
    final equipmentManager = getIt<EquipmentManager>();

    // Check if slot exists
    if (slotIndex >= inventoryManager.maxSlots) {
      developer.log(
        '[InventoryInput] Slot $slotIndex não existe (max: ${inventoryManager.maxSlots})',
      );
      return;
    }

    final slot = inventoryManager.getSlotByIndex(slotIndex);
    if (slot == null) {
      developer.log('[InventoryInput] Slot $slotIndex não encontrado');
      return;
    }

    // Select the slot (even if empty - SV style)
    final success = equipmentManager.selectSlotIndex(slotIndex);

    if (success) {
      final item = slot.item;
      if (item != null) {
        developer.log(
          '[InventoryInput] ✓ Slot ${slotIndex + 1} selecionado: ${item.name}',
        );
      } else {
        developer.log(
          '[InventoryInput] ✓ Slot ${slotIndex + 1} selecionado (vazio)',
        );
      }
    } else {
      developer.log(
        '[InventoryInput] ✗ Falha ao selecionar slot ${slotIndex + 1}',
      );
    }
  }

  void _openCrafting() {
    developer.log(
      '[InventoryInput] Crafting menu não implementado ainda (tecla C)',
    );
    // TODO: Implementar menu de crafting no futuro
  }
}
