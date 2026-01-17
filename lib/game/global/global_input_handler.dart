// lib/game/global/global_input_handler.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/global/global_state_machine.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:flutter/foundation.dart';

typedef InteractionCallback = void Function();

class InteractableData {
  final InteractionType type;
  final InteractionCallback onExecute;

  InteractableData({required this.type, required this.onExecute});
}

/// ✅ AGORA É UM FACTORY NORMAL (não mais singleton)
final class GlobalInputHandler extends GameComponent
    with PlayerControllerListener {
  final PlayerController playerInput;

  // ✅ ESTADO COMPARTILHADO (singleton separado)
  static final _SharedState _state = _SharedState.instance;

  GlobalInputHandler({required this.playerInput});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    print('🔥🔥🔥 [GlobalInput] onLoad START');
    print('🔥 playerInput.hashCode: ${playerInput.hashCode}');

    playerInput.addObserver(this);

    print('🔥 ✅ Observer REGISTRADO');
    print('🔥🔥🔥 [GlobalInput] onLoad END');

    GameLogger.debug('[GlobalInput] 🎮 Handler loaded and ready');
  }

  @override
  void onRemove() {
    print('🔥🔥🔥 [GlobalInput] onRemove START');
    print('🔥 playerInput.hashCode: ${playerInput.hashCode}');
    print(
      '🔥 Interactables compartilhados ANTES de limpar: ${_state._registeredInteractables.length}',
    );

    playerInput.removeObserver(this);

    // ✅ LIMPA TODO O ESTADO COMPARTILHADO
    _state.dispose();

    print('🔥 ✅ Observer REMOVIDO');
    print('🔥 ✅ SharedState LIMPO (dispose)');
    print(
      '🔥 Interactables compartilhados DEPOIS de limpar: ${_state._registeredInteractables.length}',
    );
    print('🔥🔥🔥 [GlobalInput] onRemove END');

    super.onRemove();
    GameLogger.debug('[GlobalInput] Handler removed and state cleared');
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

    if (_handleUIOverlays(event)) {
      if (kDebugMode) GameLogger.debug('[GlobalInput] ✅ UI handled');
      return;
    }

    if (_handleWorldInteractions(event)) {
      if (kDebugMode)
        GameLogger.debug('[GlobalInput] ✅ World interaction handled');
      return;
    }

    if (_handleGlobalHotkeys(event)) {
      if (kDebugMode) GameLogger.debug('[GlobalInput] ✅ Global hotkey handled');
      return;
    }

    if (kDebugMode)
      GameLogger.debug('[GlobalInput] ⚠️ No handler consumed input');
  }

  bool _canProcessInput() {
    final state = GlobalStateMachine.instance.getCurrentState();
    return state != GlobalState.gameLoading &&
        state != GlobalState.gameTransitioning &&
        state != GlobalState.gameCutscene &&
        state != GlobalState.uiOverlayGameover;
  }

  bool _handleUIOverlays(JoystickActionEvent event) {
    final state = GlobalStateMachine.instance.getCurrentState();

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

    if (state == GlobalState.uiOverlayChoice) {
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

    if (state == GlobalState.gameplayResumedFishing) {
      if (InputDef.isPrimaryAction(event.id)) {
        GameLogger.debug('[GlobalInput] Fishing action');
        return true;
      }
      return true;
    }

    if (state == GlobalState.gameplayPaused) {
      if (InputDef.isInteractionAction(event.id)) {
        GlobalStateMachine.instance.resumeGameplay();
        return true;
      }
      return true;
    }

    return false;
  }

  bool _handleWorldInteractions(JoystickActionEvent event) {
    if (!InputDef.isInteractionAction(event.id)) {
      return false;
    }

    if (kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] 🔍 Checking interactables... Total: ${_state._registeredInteractables.length}',
      );
    }

    final highestPriority = _state._getHighestPriorityInteractable();

    if (highestPriority == null) {
      return false;
    }

    final id = highestPriority.$1;
    final data = highestPriority.$2;

    if (kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] 🎯 Executing: $id (priority: ${data.type.priority})',
      );
    }

    try {
      data.onExecute();
    } catch (e) {
      GameLogger.error('[GlobalInput] ❌ Error executing callback: $e');
    }

    return true;
  }

  bool _handleGlobalHotkeys(JoystickActionEvent event) {
    final state = GlobalStateMachine.instance.getCurrentState();

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
      GameLogger.debug('[GlobalInput] 🎯 Selecting slot: $slotNumber');
      return true;
    }

    if (InputDef.isEquipMainHandAction(event.id)) {
      GameLogger.debug('[GlobalInput] ➡️ Next slot');
      return true;
    }

    if (InputDef.isEquipMainHandReverseAction(event.id)) {
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

  // ✅ MÉTODOS ESTÁTICOS para acessar estado compartilhado
  static void register({
    required String id,
    required InteractionType type,
    required InteractionCallback onExecute,
  }) {
    _state.register(id: id, type: type, onExecute: onExecute);
  }

  static void unregister(String id) {
    _state.unregister(id);
  }

  static void reset() {
    _state.reset();
  }
}

/// ✅ ESTADO COMPARTILHADO (Singleton separado)
final class _SharedState {
  _SharedState._();
  static final _SharedState instance = _SharedState._();

  final Map<String, InteractableData> _registeredInteractables = {};

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
        '[GlobalInput] ➕ Registered: $id (priority: ${type.priority}) Total: ${_registeredInteractables.length}',
      );
    }
  }

  void unregister(String id) {
    final removed = _registeredInteractables.remove(id);

    if (removed != null && kDebugMode) {
      GameLogger.debug(
        '[GlobalInput] ➖ Unregistered: $id Remaining: ${_registeredInteractables.length}',
      );
    }
  }

  void reset() {
    _registeredInteractables.clear();
    if (kDebugMode) GameLogger.debug('[GlobalInput] 🔄 Reset complete');
  }

  // ✅ MÉTODO DISPOSE para limpar completamente
  void dispose() {
    print(
      '🔥 [SharedState] dispose() chamado - Limpando ${_registeredInteractables.length} interactables',
    );
    _registeredInteractables.clear();
    if (kDebugMode) GameLogger.debug('[GlobalInput] 🗑️ SharedState disposed');
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
