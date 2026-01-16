import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/overlay/tutorial_inputs/tutorial_inputs_state.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/core/utils/app_environment.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/state/inventory_state.dart';
import 'package:dawnforge/game/features/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/game/features/inventory/usecases/add_item_use_case.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';

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
    EquipmentManager.instance.selectedSlotIndexNotifier.addListener(
      _handleSelectedSlotChanged,
    );
  }

  @override
  void onRemove() {
    if (playerController != null) {
      playerController!.removeObserver(this);
    }
    EquipmentManager.instance.selectedSlotIndexNotifier.removeListener(
      _handleSelectedSlotChanged,
    );
    super.onRemove();
  }

  @override
  void onMount() {
    super.onMount();
    GameLogger.info('[InventoryInput] Component mounted!');
    GameLogger.info('[InventoryInput] gameRef.interface: ${gameRef.interface}');
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
    final inventoryManager = InventoryManager.instance;
    if (inventoryManager.usedSlots > 0) {
      GameLogger.info(
        '[InventoryInput] ✓ Inventário já possui ${inventoryManager.usedSlots} itens (carregado de save), pulando itens de teste',
      );
      _ensureInitialSlotSelection();
      return;
    }

    GameLogger.info('[InventoryInput] Inicializando itens de teste...');

    const testItems = [
      (HandItemId.shovel, 1),
      // (HandItemId.radish_seed_bag, 20),
      (HandItemId.strawberry_seed_bag, 20),
      (HandItemId.apple_seed_bag, 20),
      (HandItemId.tomato_seed_bag, 20),
      (HandItemId.wateringCan, 1),
      (HandItemId.harvestBasket, 1),
      (HandItemId.ironSword, 1),
      (HandItemId.staff, 1),
    ];

    _addItems(testItems);

    GameLogger.info(
      '[InventoryInput] Itens de teste adicionados! ${InventoryManager.instance.usedSlots} slots usados',
    );

    // Ensure first non-empty slot is selected
    _ensureInitialSlotSelection();
  }

  void _ensureInitialSlotSelection() {
    final equipmentManager = EquipmentManager.instance;
    final currentSlotIndex = equipmentManager.currentMainHandSlotIndex;
    final currentSlot = InventoryManager.instance.getSlotByIndex(
      currentSlotIndex,
    );

    // If current slot already has any item, select it to sync UI
    if (currentSlot?.item != null) {
      GameLogger.info(
        '[InventoryInput] Slot $currentSlotIndex already has item: ${currentSlot?.item?.name}, syncing with UI',
      );
      equipmentManager.selectSlotIndex(currentSlotIndex);
      return;
    }

    // Find first non-empty slot and select it
    final result = InventoryManager.instance.findItem((_) => true);

    if (result != null) {
      equipmentManager.selectSlotIndex(result.index);
      GameLogger.info(
        '[InventoryInput] Auto-selected slot ${result.index} with ${result.item.name}',
      );
    } else {
      GameLogger.info(
        '[InventoryInput] No items found in inventory - slot 0 remains selected (empty)',
      );
    }
  }

  void _debugInsertItem(HandItemId itemKey) {
    if (InventoryManager.instance.getItemQuantity(itemKey.name) == 0) {
      getIt<AddItemUseCase>()(itemKey, 1);
    }
  }

  void _addItems(List<(HandItemId, int)> items) {
    final success = getIt<AddItemUseCase>().addMultiple(items);

    if (!success) {
      GameLogger.warning(
        '[InventoryInput] Nenhum item adicionado (talvez inventário cheio)',
      );
    }
  }

  void _addTestItems() {
    GameLogger.info('[InventoryInput] Adicionando mais itens de teste...');

    final testMaterials = [(HandItemId.stone, 100), (HandItemId.iron_ore, 25)];

    for (final (itemKey, quantity) in testMaterials) {
      final success = getIt<AddItemUseCase>()(itemKey, quantity);
      if (success) {
        GameLogger.info('[InventoryInput] Adicionado ${quantity}x $itemKey');
      }
    }
  }

  void _equipMainHand() {
    GameLogger.info(
      '[InventoryInput] Procurando próximo item no inventário para selecionar...',
    );

    final inventoryManager = InventoryManager.instance;
    final equipmentManager = EquipmentManager.instance;

    if (inventoryManager.maxSlots == 0) {
      GameLogger.warning(
        '[InventoryInput] Nenhum slot disponível no inventário',
      );
      return;
    }
    final currentSlotIndex = equipmentManager.currentMainHandSlotIndex;
    final nextIndex = (currentSlotIndex + 1) % inventoryManager.maxSlots;

    final success = equipmentManager.selectSlotIndex(nextIndex);

    if (success) {
      final item = inventoryManager.getSlotByIndex(nextIndex)?.item;
      final handSuffix = item != null ? ' (${item.id})' : '';
      final itemName = item?.name ?? 'vazio';
      GameLogger.info(
        '[InventoryInput] ✓ Slot selecionado: $itemName$handSuffix',
      );
    } else {
      GameLogger.warning(
        '[InventoryInput] ✗ Falha ao selecionar slot ${nextIndex + 1}',
      );
    }
  }

  void _equipMainHandReverse() {
    GameLogger.info(
      '[InventoryInput] Procurando item anterior no inventário para selecionar...',
    );

    final inventoryManager = InventoryManager.instance;
    final equipmentManager = EquipmentManager.instance;

    if (inventoryManager.maxSlots == 0) {
      GameLogger.warning(
        '[InventoryInput] Nenhum slot disponível no inventário',
      );
      return;
    }
    final currentSlotIndex = equipmentManager.currentMainHandSlotIndex;
    final previousIndex =
        (currentSlotIndex - 1 + inventoryManager.maxSlots) %
        inventoryManager.maxSlots;

    final success = equipmentManager.selectSlotIndex(previousIndex);

    if (success) {
      final item = inventoryManager.getSlotByIndex(previousIndex)?.item;
      final handSuffix = item != null ? ' (${item.id})' : '';
      final itemName = item?.name ?? 'vazio';
      GameLogger.info(
        '[InventoryInput] ✓ Slot selecionado (reverso): $itemName$handSuffix',
      );
    } else {
      GameLogger.warning(
        '[InventoryInput] ✗ Falha ao selecionar slot ${previousIndex + 1}',
      );
    }
  }

  void _notifyEquipmentChanged(HandItemId? handItemId) {
    // Equipment is now queried dynamically from the player model
    // No need to notify - the model always returns the current selected slot
    GameLogger.info(
      '[InventoryInput] Equipment changed to: ${handItemId?.name ?? "empty"}',
    );
  }

  void _handleSelectedSlotChanged() {
    final selectedItem = EquipmentManager.instance.getEquippedItem();
    _notifyEquipmentChanged(selectedItem?.id);
  }

  // ========== SV STYLE SLOT SELECTION ==========
  void _selectSlotByNumber(int slotIndex) {
    final inventoryManager = InventoryManager.instance;
    final equipmentManager = EquipmentManager.instance;

    // Check if slot exists
    if (slotIndex >= inventoryManager.maxSlots) {
      GameLogger.warning(
        '[InventoryInput] Slot $slotIndex não existe (max: ${inventoryManager.maxSlots})',
      );
      return;
    }

    final slot = inventoryManager.getSlotByIndex(slotIndex);
    if (slot == null) {
      GameLogger.warning('[InventoryInput] Slot $slotIndex não encontrado');
      return;
    }

    // Select the slot (even if empty - SV style)
    final success = equipmentManager.selectSlotIndex(slotIndex);

    if (success) {
      final item = slot.item;
      if (item != null) {
        GameLogger.info(
          '[InventoryInput] ✓ Slot ${slotIndex + 1} selecionado: ${item.name}',
        );
      } else {
        GameLogger.info(
          '[InventoryInput] ✓ Slot ${slotIndex + 1} selecionado (vazio)',
        );
      }
    } else {
      GameLogger.warning(
        '[InventoryInput] ✗ Falha ao selecionar slot ${slotIndex + 1}',
      );
    }
  }

  void _openCrafting() {
    GameLogger.info(
      '[InventoryInput] Crafting menu não implementado ainda (tecla C)',
    );
    // TODO: Implementar menu de crafting no futuro
  }
}
