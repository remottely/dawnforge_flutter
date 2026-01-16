// lib/game/global/global_input_handler.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/global/global_state_machine.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:flutter/foundation.dart';

/// Callback para executar ação de interação
typedef InteractionCallback = void Function();

/// Dados de um interactable registrado
class InteractableData {
  final InteractionType type;
  final InteractionCallback onExecute;

  InteractableData({required this.type, required this.onExecute});
}

class GlobalInputHandler extends GameComponent with PlayerControllerListener {
  static GlobalInputHandler? _instance;
  static GlobalInputHandler get instance {
    if (_instance == null) {
      throw Exception(
        '[GlobalInputHandler] Not initialized! Add to BonfireWidget components first.',
      );
    }
    return _instance!;
  }

  PlayerController playerInput;

  // ✅ MAPA COM CALLBACKS
  final Map<String, InteractableData> _registeredInteractables = {};

  GlobalInputHandler._({required this.playerInput});

  factory GlobalInputHandler({required PlayerController playerInput}) {
    _instance ??= GlobalInputHandler._(playerInput: playerInput);
    return _instance!;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    playerInput.addObserver(this);

    print('🔥 [GlobalInput] onLoad chamado');
    print('🔥 [GlobalInput] playerInput: $playerInput');
    print('🔥 [GlobalInput] playerInput.hashCode: ${playerInput.hashCode}');

    print('🔥 [GlobalInput] addObserver chamado');
    print('🔥 [GlobalInput] Observers: ${playerInput}');

    GameLogger.debug('[GlobalInput] 🎮 Handler loaded and ready');
  }

  @override
  void onRemove() {
    playerInput.removeObserver(this);

    // ❌ NÃO RESETAR _instance (causa erro no MarketDecoration.onRemove)
    // _instance = null;

    // ✅ APENAS LIMPA INTERACTABLES
    _registeredInteractables.clear();

    super.onRemove();
    GameLogger.debug('[GlobalInput] Handler removed (instance kept alive)');
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] 🎮 Input received: ${event.id} | ${event.event}',
      );
    }

    if (event.event != ActionEvent.DOWN) return;

    if (!_canProcessInput()) {
      if (kDebugMode) GameLogger.debug('[GlobalInput] ❌ Blocked by GameState');
      return;
    }

    // ✅ HIERARQUIA

    // 1. UI Overlays
    if (_handleUIOverlays(event)) {
      if (kDebugMode) GameLogger.debug('[GlobalInput] ✅ UI handled');
      return;
    }

    // 2. World Interactions (com callbacks)
    if (_handleWorldInteractions(event)) {
      if (kDebugMode)
        GameLogger.debug('[GlobalInput] ✅ World interaction handled');
      return;
    }

    // 3. Global Hotkeys
    if (_handleGlobalHotkeys(event)) {
      if (kDebugMode) GameLogger.debug('[GlobalInput] ✅ Global hotkey handled');
      return;
    }

    if (kDebugMode)
      GameLogger.debug('[GlobalInput] ⚠️ No handler consumed input');
  }

  bool _canProcessInput() {
    final state = GlobalStateMachine.instance.getRxCurrentState().value;
    return state != GlobalState.gameLoading &&
        state != GlobalState.gameTransitioning &&
        state != GlobalState.gameCutscene &&
        state != GlobalState.uiOverlayGameover;
  }

  bool _handleUIOverlays(JoystickActionEvent event) {
    final state = GlobalStateMachine.instance.getRxCurrentState().value;

    if (state == GlobalState.uiOverlayMarket) {
      if (InputDef.isInteractionAction(event.id)) {
        GlobalStateMachine.instance.closeMarket();
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiOverlayConversation) {
      if (InputDef.isInteractionAction(event.id)) {
        GameLogger.debug('[GlobalInput] Advancing dialogue');
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiOverlayChoiceDialog) {
      if (InputDef.isInteractionAction(event.id)) {
        GameLogger.debug('[GlobalInput] Confirming choice');
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiOverlayCrafting) {
      if (InputDef.isInteractionAction(event.id) ||
          InputDef.isCraftingAction(event.id)) {
        GlobalStateMachine.instance.closeCrafting();
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiOverlayCooking) {
      if (InputDef.isInteractionAction(event.id)) {
        GlobalStateMachine.instance.closeCooking();
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiMenuInventory) {
      if (InputDef.isInteractionAction(event.id) ||
          InputDef.isToggleInventoryAction(event.id)) {
        GlobalStateMachine.instance.closeInventory();
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiMenuMap) {
      if (InputDef.isInteractionAction(event.id)) {
        GlobalStateMachine.instance.closeMap();
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiMenuQuest) {
      if (InputDef.isInteractionAction(event.id)) {
        GlobalStateMachine.instance.closeQuest();
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiMenuSettings) {
      if (InputDef.isInteractionAction(event.id)) {
        GlobalStateMachine.instance.closeSettings();
        return true;
      }
      return true;
    }

    if (state == GlobalState.uiOverlayMinigameFishing) {
      if (InputDef.isPrimaryAction(event.id)) {
        GameLogger.debug('[GlobalInput] Fishing action');
        return true;
      }
      return true;
    }

    if (state == GlobalState.gameplayPaused) {
      if (InputDef.isInteractionAction(event.id)) {
        GlobalStateMachine.instance.resumeGame();
        return true;
      }
      return true;
    }

    return false;
  }

  // ✅ WORLD INTERACTIONS COM CALLBACKS
  bool _handleWorldInteractions(JoystickActionEvent event) {
    if (!InputDef.isInteractionAction(event.id)) {
      if (kDebugMode) {
        GameLogger.debug(
          '[GlobalInput] Not an interaction action: ${event.id}',
        );
      }
      return false;
    }

    if (kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] 🔍 Checking interactables... Total registered: ${_registeredInteractables.length}',
      );
      for (final entry in _registeredInteractables.entries) {
        GameLogger.debug(
          '[GlobalInput]   - ${entry.key}: ${entry.value.type.name} (priority: ${entry.value.type.priority})',
        );
      }
    }

    // Pega o de maior prioridade
    final highestPriority = _getHighestPriorityInteractable();

    if (highestPriority == null) {
      if (kDebugMode) {
        GameLogger.debug('[GlobalInput] ⚠️ No interactables found');
      }
      return false;
    }

    final id = highestPriority.$1;
    final data = highestPriority.$2;

    if (kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] 🎯 Executing: $id '
        '(priority: ${data.type.priority} - ${data.type.name})',
      );

      if (_registeredInteractables.length > 1) {
        final ignored = _registeredInteractables.entries
            .where((e) => e.key != id)
            .map((e) => '${e.key}(${e.value.type.name})')
            .join(', ');
        GameLogger.debug('[GlobalInput] 🚫 Ignored: $ignored');
      }
    }

    // ✅ EXECUTA O CALLBACK
    try {
      data.onExecute();
      if (kDebugMode) {
        GameLogger.debug('[GlobalInput] ✅ Callback executed successfully');
      }
    } catch (e) {
      GameLogger.error('[GlobalInput] ❌ Error executing callback: $e');
    }

    return true;
  }

  (String, InteractableData)? _getHighestPriorityInteractable() {
    if (_registeredInteractables.isEmpty) return null;

    String? bestId;
    InteractableData? bestData;

    for (final entry in _registeredInteractables.entries) {
      final id = entry.key;
      final data = entry.value;

      if (bestData == null || data.type.priority < bestData.type.priority) {
        bestId = id;
        bestData = data;
      }
    }

    return bestId != null && bestData != null ? (bestId, bestData) : null;
  }

  bool _handleGlobalHotkeys(JoystickActionEvent event) {
    final state = GlobalStateMachine.instance.getRxCurrentState().value;

    if (state != GlobalState.gameplayResumed) return false;

    if (InputDef.isToggleInventoryAction(event.id)) {
      GlobalStateMachine.instance.openInventory();
      return true;
    }

    if (InputDef.isCraftingAction(event.id)) {
      GlobalStateMachine.instance.openCrafting();
      return true;
    }

    final slotNumber = InputDef.getToolbarSlotNumber(event.id);
    if (slotNumber != null) {
      // TODO: EquipmentManager.instance.selectSlotIndex(slotNumber);
      GameLogger.debug('[GlobalInput] 🎯 Selecting slot: $slotNumber');
      return true;
    }

    if (InputDef.isEquipMainHandAction(event.id)) {
      // TODO: EquipmentManager.instance.selectNextSlot();
      GameLogger.debug('[GlobalInput] ➡️ Next slot');
      return true;
    }

    if (InputDef.isEquipMainHandReverseAction(event.id)) {
      // TODO: EquipmentManager.instance.selectPreviousSlot();
      GameLogger.debug('[GlobalInput] ⬅️ Previous slot');
      return true;
    }

    if (kDebugMode) {
      if (InputDef.isAdvanceDayAction(event.id)) {
        GameLogger.debug('[GlobalInput] ⏭️ Advance day');
        return true;
      }

      if (InputDef.isClearSaveAction(event.id)) {
        GameLogger.debug('[GlobalInput] 🗑️ Clear save');
        return true;
      }

      if (InputDef.isAddTestItemsAction(event.id)) {
        GameLogger.debug('[GlobalInput] 🎁 Add test items');
        return true;
      }
    }

    return false;
  }

  // ✅ REGISTRO COM CALLBACK
  void register({
    required String id,
    required InteractionType type,
    required InteractionCallback onExecute,
  }) {
    _registeredInteractables[id] = InteractableData(
      type: type,
      onExecute: onExecute,
    );

    if (kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] ➕ Registered: $id '
        '(priority: ${type.priority} - ${type.name}) '
        'Total: ${_registeredInteractables.length}',
      );
    }
  }

  void unregister(String id) {
    final removed = _registeredInteractables.remove(id);

    if (removed != null && kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] ➖ Unregistered: $id '
        'Remaining: ${_registeredInteractables.length}',
      );
    }
  }

  void reset() {
    _registeredInteractables.clear();
    if (kDebugMode) GameLogger.debug('[GlobalInput] 🔄 Reset complete');
  }
}

enum InteractionType {
  npc(priority: 1),
  market(priority: 2),
  chest(priority: 3),
  torch(priority: 4),
  door(priority: 5),
  consumable(priority: 10);

  final int priority;
  const InteractionType({required this.priority});
}
