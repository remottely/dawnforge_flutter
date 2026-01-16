// // lib/game/global/global_input_handler.dart
// import 'package:bonfire/bonfire.dart';
// import 'package:dawnforge/game/global/global_state_machine.dart';
// import 'package:dawnforge/game/systems/input_actions/input_def.dart';
// import 'package:dawnforge/core/utils/game_logger.dart';
// import 'package:flutter/foundation.dart';

// typedef InteractionCallback = void Function();

// class InteractableData {
//   final InteractionType type;
//   final InteractionCallback onExecute;

//   InteractableData({
//     required this.type,
//     required this.onExecute,
//   });
// }

// class GlobalInputHandler extends GameComponent with PlayerControllerListener {
//   static GlobalInputHandler? _instance;
//   static GlobalInputHandler get instance {
//     if (_instance == null) {
//       throw Exception(
//         '[GlobalInputHandler] Not initialized! Add to BonfireWidget components first.',
//       );
//     }
//     return _instance!;
//   }

//   // ✅ NÃO É MAIS final (pode ser atualizado)
//   PlayerController _playerInput;
//   PlayerController get playerInput => _playerInput;

//   final Map<String, InteractableData> _registeredInteractables = {};

//   GlobalInputHandler._({required PlayerController playerInput})
//       : _playerInput = playerInput;

//   factory GlobalInputHandler({required PlayerController playerInput}) {
//     if (_instance != null) {
//       GameLogger.debug('[GlobalInput] ♻️ Reusing existing instance, updating playerInput');
      
//       // ✅ REMOVE OBSERVER DO ANTIGO
//       _instance!._playerInput.removeObserver(_instance!);
      
//       // ✅ ATUALIZA playerInput
//       _instance!._playerInput = playerInput;
      
//       // ✅ REGISTRA NO NOVO
//       playerInput.addObserver(_instance!);
      
//       // ✅ LIMPA INTERACTABLES ANTIGOS
//       _instance!._registeredInteractables.clear();
      
//       return _instance!;
//     }
    
//     _instance = GlobalInputHandler._(playerInput: playerInput);
//     return _instance!;
//   }

//   @override
//   Future<void> onLoad() async {
//     await super.onLoad();
//     _playerInput.addObserver(this);
//     GameLogger.debug('[GlobalInput] 🎮 Handler loaded and ready');
//   }

//   @override
//   void onRemove() {
//     _playerInput.removeObserver(this);
    
//     // ❌ NÃO RESETAR _instance
//     // _instance = null;
    
//     // ✅ APENAS LIMPA INTERACTABLES
//     _registeredInteractables.clear();
    
//     super.onRemove();
//     GameLogger.debug('[GlobalInput] Handler removed (instance kept alive)');
//   }

//   @override
//   void onJoystickAction(JoystickActionEvent event) {
//     if (kDebugMode) {
//       GameLogger.debug(
//         '[GlobalInput] 🎮 Input received: ${event.id} | ${event.event}',
//       );
//     }

//     if (event.event != ActionEvent.DOWN) return;

//     if (!_canProcessInput()) {
//       if (kDebugMode) GameLogger.debug('[GlobalInput] ❌ Blocked by GameState');
//       return;
//     }

//     if (_handleUIOverlays(event)) {
//       if (kDebugMode) GameLogger.debug('[GlobalInput] ✅ UI handled');
//       return;
//     }

//     if (_handleWorldInteractions(event)) {
//       if (kDebugMode) GameLogger.debug('[GlobalInput] ✅ World interaction handled');
//       return;
//     }

//     if (_handleGlobalHotkeys(event)) {
//       if (kDebugMode) GameLogger.debug('[GlobalInput] ✅ Global hotkey handled');
//       return;
//     }

//     if (kDebugMode) GameLogger.debug('[GlobalInput] ⚠️ No handler consumed input');
//   }

//   bool _canProcessInput() {
//     final state = GlobalStateMachine.instance.getRxCurrentState().value;
//     return state != GlobalState.gameLoading &&
//            state != GlobalState.gameTransitioning &&
//            state != GlobalState.gameCutscene &&
//            state != GlobalState.uiOverlayGameover;
//   }

//   bool _handleUIOverlays(JoystickActionEvent event) {
//     final state = GlobalStateMachine.instance.getRxCurrentState().value;

//     if (state == GlobalState.uiOverlayMarket) {
//       if (InputDef.isInteractionAction(event.id)) {
//         GlobalStateMachine.instance.closeMarket();
//         return true;
//       }
//       return true;
//     }

//     // ... resto dos overlays igual
    
//     return false;
//   }

//   bool _handleWorldInteractions(JoystickActionEvent event) {
//     if (!InputDef.isInteractionAction(event.id)) {
//       return false;
//     }

//     if (kDebugMode) {
//       GameLogger.debug(
//         '[GlobalInput] 🔍 Checking interactables... Total: ${_registeredInteractables.length}',
//       );
//     }

//     final highestPriority = _getHighestPriorityInteractable();

//     if (highestPriority == null) {
//       return false;
//     }

//     final id = highestPriority.$1;
//     final data = highestPriority.$2;

//     if (kDebugMode) {
//       GameLogger.debug(
//         '[GlobalInput] 🎯 Executing: $id (priority: ${data.type.priority})',
//       );
//     }

//     try {
//       data.onExecute();
//     } catch (e) {
//       GameLogger.error('[GlobalInput] ❌ Error executing callback: $e');
//     }

//     return true;
//   }

//   (String, InteractableData)? _getHighestPriorityInteractable() {
//     if (_registeredInteractables.isEmpty) return null;

//     String? bestId;
//     InteractableData? bestData;

//     for (final entry in _registeredInteractables.entries) {
//       final id = entry.key;
//       final data = entry.value;

//       if (bestData == null || data.type.priority < bestData.type.priority) {
//         bestId = id;
//         bestData = data;
//       }
//     }

//     return bestId != null && bestData != null ? (bestId, bestData) : null;
//   }

//   bool _handleGlobalHotkeys(JoystickActionEvent event) {
//     final state = GlobalStateMachine.instance.getRxCurrentState().value;

//     if (state != GlobalState.gameplayResumed) return false;

//     // ... resto dos hotkeys igual

//     return false;
//   }

//   void register({
//     required String id,
//     required InteractionType type,
//     required InteractionCallback onExecute,
//   }) {
//     _registeredInteractables[id] = InteractableData(
//       type: type,
//       onExecute: onExecute,
//     );
    
//     if (kDebugMode) {
//       GameLogger.debug(
//         '[GlobalInput] ➕ Registered: $id (priority: ${type.priority}) Total: ${_registeredInteractables.length}',
//       );
//     }
//   }

//   void unregister(String id) {
//     final removed = _registeredInteractables.remove(id);
    
//     if (removed != null && kDebugMode) {
//       GameLogger.debug(
//         '[GlobalInput] ➖ Unregistered: $id Remaining: ${_registeredInteractables.length}',
//       );
//     }
//   }

//   void reset() {
//     _registeredInteractables.clear();
//     if (kDebugMode) GameLogger.debug('[GlobalInput] 🔄 Reset complete');
//   }
// }

// enum InteractionType {
//   npc(priority: 1),
//   market(priority: 2),
//   chest(priority: 3),
//   torch(priority: 4),
//   door(priority: 5),
//   consumable(priority: 10);

//   final int priority;
//   const InteractionType({required this.priority});
// }
