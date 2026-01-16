// // lib/core/input/input_helper.dart
// import 'package:bonfire/bonfire.dart';
// import 'package:dawnforge/game/state/game_state_machine.dart';
// import 'package:dawnforge/game/systems/input_actions/input_def.dart';
// import 'package:flutter/foundation.dart';

// /// Helper centralizado que processa TODOS os inputs do jogo
// /// Segue ordem hierárquica: UI > Interações > Items > Movimento
// class InputHelper {
//   static final InputHelper instance = InputHelper._();
//   InputHelper._();

//   /// Referência para o objeto interativo mais próximo (Market, NPC, Chest, Door, Torch)
//   GameComponent? nearestInteractable;

//   /// Player atual (referência opcional)
//   SimplePlayer? currentPlayer;

//   /// MÉTODO PRINCIPAL: Processa input seguindo hierarquia
//   /// Retorna TRUE se consumiu o input, FALSE se deve continuar processando
//   bool processInput(JoystickActionEvent event) {
//     if (kDebugMode) {
//       debugPrint('[InputHelper] 🎮 Input: ${event.id} | ${event.event}');
//     }

//     // ✅ 1. VERIFICA SE PODE PROCESSAR (baseado no GameState)
//     if (!_canProcessInput()) {
//       if (kDebugMode) debugPrint('[InputHelper] ❌ Blocked by GameState');
//       return true; // Bloqueia input
//     }

//     // ✅ 2. UI OVERLAYS (prioridade máxima)
//     if (_handleUIOverlays(event)) {
//       if (kDebugMode) debugPrint('[InputHelper] ✅ Consumed by UI Overlay');
//       return true;
//     }

//     // ✅ 3. INTERAÇÕES COM MUNDO (NPCs, Market, Doors, Chests, Torches)
//     if (_handleWorldInteractions(event)) {
//       if (kDebugMode) {
//         debugPrint('[InputHelper] ✅ Consumed by World Interaction');
//       }
//       return true;
//     }

//     // ✅ 4. HOTKEYS GLOBAIS (Inventory, Crafting, etc)
//     if (_handleGlobalHotkeys(event)) {
//       if (kDebugMode) debugPrint('[InputHelper] ✅ Consumed by Global Hotkey');
//       return true;
//     }

//     // ✅ 5. USO DE ITEMS/EQUIPAMENTO (Farming, Combat, Consumables)
//     // NÃO consumimos aqui, deixamos os Behaviors processarem
//     if (kDebugMode) debugPrint('[InputHelper] ⚠️ Passing to Behaviors');
//     return false;
//   }

//   // ====================================================================
//   // HIERARQUIA DE PROCESSAMENTO
//   // ====================================================================

//   /// 1️⃣ UI OVERLAYS (Market, Dialogue, Crafting, Menus)
//   bool _handleUIOverlays(JoystickActionEvent event) {
//     final state = GameStateMachine.instance.getRxCurrentState().value;

//     // ========== MARKET ABERTO ==========
//     if (state == GameState.uiOverlayMarket) {
//       // ESC fecha o market
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.closeMarket();
//         return true;
//       }
//       // Consome TODOS os inputs enquanto market aberto (bloqueia movimento)
//       return true;
//     }

//     // ========== DIALOGUE/CONVERSATION ABERTO ==========
//     if (state == GameState.uiOverlayConversation) {
//       // INTERACT avança diálogo
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         // TODO: Avançar diálogo (UIStateManager.instance.advanceConversation())
//         debugPrint('[InputHelper] Advancing conversation...');
//         return true;
//       }
      
//       // ESC fecha diálogo (emergência)
//       if (event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.endConversation();
//         return true;
//       }
      
//       // Bloqueia outros inputs
//       return true;
//     }

//     // ========== CHOICE DIALOG ABERTO ==========
//     if (state == GameState.uiOverlayChoiceDialog) {
//       // INTERACT confirma escolha selecionada
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         // TODO: Confirmar escolha (UIStateManager.instance.confirmChoice())
//         debugPrint('[InputHelper] Confirming choice...');
//         return true;
//       }
      
//       // Direcionais navegam entre opções
//       // (já processado pelo UI, só consome para não interferir)
//       return true;
//     }

//     // ========== CRAFTING ABERTO ==========
//     if (state == GameState.uiOverlayCrafting) {
//       // ESC ou K fecha crafting
//       if ((InputDef.isInteractionAction(event.id) ||
//               InputDef.isCraftingAction(event.id)) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.closeCrafting();
//         return true;
//       }
      
//       // PRIMARY ACTION crafta item selecionado
//       if (InputDef.isPrimaryAction(event.id) && event.event == ActionEvent.DOWN) {
//         // TODO: CraftingManager.instance.craftSelectedItem()
//         debugPrint('[InputHelper] Crafting selected item...');
//         return true;
//       }
      
//       return true;
//     }

//     // ========== COOKING ABERTO ==========
//     if (state == GameState.uiOverlayCooking) {
//       // ESC fecha cooking
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.closeCooking();
//         return true;
//       }
      
//       // PRIMARY ACTION cozinha item selecionado
//       if (InputDef.isPrimaryAction(event.id) && event.event == ActionEvent.DOWN) {
//         // TODO: CookingManager.instance.cookSelectedItem()
//         debugPrint('[InputHelper] Cooking selected item...');
//         return true;
//       }
      
//       return true;
//     }

//     // ========== INVENTORY MENU ABERTO ==========
//     if (state == GameState.uiMenuInventory) {
//       // ESC ou TAB fecha inventory
//       if ((InputDef.isInteractionAction(event.id) ||
//               InputDef.isToggleInventoryAction(event.id)) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.closeInventory();
//         return true;
//       }
      
//       // PRIMARY ACTION usa/equipa item selecionado
//       if (InputDef.isPrimaryAction(event.id) && event.event == ActionEvent.DOWN) {
//         // TODO: InventoryManager.instance.useSelectedItem()
//         debugPrint('[InputHelper] Using selected item from inventory...');
//         return true;
//       }
      
//       return true;
//     }

//     // ========== MAP MENU ABERTO ==========
//     if (state == GameState.uiMenuMap) {
//       // ESC fecha map
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.closeMap();
//         return true;
//       }
//       return true;
//     }

//     // ========== QUEST LOG ABERTO ==========
//     if (state == GameState.uiMenuQuest) {
//       // ESC fecha quest log
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.closeQuest();
//         return true;
//       }
//       return true;
//     }

//     // ========== SETTINGS MENU ABERTO ==========
//     if (state == GameState.uiMenuSettings) {
//       // ESC fecha settings (volta para estado anterior)
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.closeSettings();
//         return true;
//       }
//       return true;
//     }

//     // ========== FISHING MINIGAME ==========
//     if (state == GameState.uiOverlayMinigameFishing) {
//       // PRIMARY ACTION puxa vara
//       if (InputDef.isPrimaryAction(event.id)) {
//         // TODO: FishingMinigame.instance.pullRod()
//         debugPrint('[InputHelper] Fishing: pulling rod...');
//         return true;
//       }
      
//       // ESC cancela fishing
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         // TODO: FishingMinigame.instance.cancel()
//         debugPrint('[InputHelper] Canceling fishing...');
//         GameStateMachine.instance._changeState(GameState.gameplayResumed);
//         return true;
//       }
      
//       return true;
//     }

//     // ========== GAME PAUSED ==========
//     if (state == GameState.gameplayPaused) {
//       // ESC resume
//       if (InputDef.isInteractionAction(event.id) &&
//           event.event == ActionEvent.DOWN) {
//         GameStateMachine.instance.resumeGame();
//         return true;
//       }
//       return true;
//     }

//     return false; // Não consumiu
//   }

//   /// 2️⃣ INTERAÇÕES COM MUNDO (NPCs, Decorações, Portas, Baús, Tochas)
//   bool _handleWorldInteractions(JoystickActionEvent event) {
//     // Só processa tecla de interação (E, F, INTERACT)
//     if (!InputDef.isInteractionAction(event.id)) {
//       return false;
//     }

//     // Só no DOWN (não no UP)
//     if (event.event != ActionEvent.DOWN) {
//       return false;
//     }

//     // TEM ALGO PRÓXIMO PARA INTERAGIR?
//     if (nearestInteractable == null) {
//       return false;
//     }

//     if (kDebugMode) {
//       debugPrint(
//         '[InputHelper] 🔗 Interacting with: ${nearestInteractable.runtimeType}',
//       );
//     }

//     // ✅ A INTERAÇÃO ESPECÍFICA É PROCESSADA PELO PRÓPRIO COMPONENT:
//     //
//     // MarketDecoration.onJoystickAction:
//     //   - Chama onOpenMarket()
//     //   - GameStateMachine.openMarket()
//     //   - MarketState.openAndSetPlayerModel()
//     //
//     // WizardNpcView.onJoystickAction:
//     //   - WizardNpcController.onPlayerDetected(interactionRequested: true)
//     //   - UIStateManager.showConversation()
//     //   - GameStateMachine.startDialogue()
//     //
//     // ChestDecorationView.onJoystickAction:
//     //   - ChestDecorationController.openChest()
//     //   - Spawna items
//     //   - Remove chest do jogo
//     //
//     // TorchDecorationView.onJoystickAction:
//     //   - TorchDecorationController.toggleTorchState()
//     //   - Alterna lighting on/off
//     //
//     // DoorDecoration.onJoystickAction:
//     //   - MapTransitionController.requestTransition()
//     //   - Troca de mapa
//     //
//     // ✅ CONSOME O INPUT AQUI para evitar que:
//     // - Use item equipado (shovel, axe, etc)
//     // - Ataque com arma
//     // - Consuma comida
//     //
//     // O component já registrou o listener via PlayerControllerListener,
//     // então ele receberá o evento ANTES de chegar nos Behaviors.

//     return true; // CONSUMIDO - não processa behaviors
//   }

//   /// 3️⃣ HOTKEYS GLOBAIS (Inventory, Crafting, Slot Selection)
//   bool _handleGlobalHotkeys(JoystickActionEvent event) {
//     if (event.event != ActionEvent.DOWN) {
//       return false;
//     }

//     final currentState = GameStateMachine.instance.getRxCurrentState().value;

//     // Só processa hotkeys em gameplay ativo
//     if (currentState != GameState.gameplayResumed) {
//       return false;
//     }

//     // ========== INVENTORY (TAB/I) ==========
//     if (InputDef.isToggleInventoryAction(event.id)) {
//       GameStateMachine.instance.openInventory();
//       return true;
//     }

//     // ========== CRAFTING (K) ==========
//     if (InputDef.isCraftingAction(event.id)) {
//       GameStateMachine.instance.openCrafting();
//       return true;
//     }

//     // ========== TOOLBAR SLOT SELECTION (1-9, 0, -, =) ==========
//     final slotNumber = InputDef.getToolbarSlotNumber(event.id);
//     if (slotNumber != null) {
//       // TODO: Selecionar slot no EquipmentManager
//       debugPrint('[InputHelper] 🎯 Selecting slot: $slotNumber');
//       // EquipmentManager.instance.selectSlotIndex(slotNumber);
//       return true;
//     }

//     // ========== NEXT/PREV SLOT (Q/E ou Scroll) ==========
//     if (InputDef.isEquipMainHandAction(event.id)) {
//       // TODO: Próximo slot
//       debugPrint('[InputHelper] ➡️ Next slot');
//       // EquipmentManager.instance.selectNextSlot();
//       return true;
//     }

//     if (InputDef.isEquipMainHandReverseAction(event.id)) {
//       // TODO: Slot anterior
//       debugPrint('[InputHelper] ⬅️ Previous slot');
//       // EquipmentManager.instance.selectPreviousSlot();
//       return true;
//     }

//     // ========== DEBUG ACTIONS (apenas em debug mode) ==========
//     if (kDebugMode) {
//       if (InputDef.isAdvanceDayAction(event.id)) {
//         debugPrint('[InputHelper] ⏭️ Advance day (debug)');
//         // TimeManager.instance.advanceDay();
//         return true;
//       }

//       if (InputDef.isClearSaveAction(event.id)) {
//         debugPrint('[InputHelper] 🗑️ Clear save (debug)');
//         // GameSaveController.instance.clearSave();
//         return true;
//       }

//       if (InputDef.isAddTestItemsAction(event.id)) {
//         debugPrint('[InputHelper] 🎁 Add test items (debug)');
//         // InventoryManager.instance.addTestItems();
//         return true;
//       }

//       if (InputDef.isToggleTutorialInputsAction(event.id)) {
//         debugPrint('[InputHelper] 📖 Toggle tutorial inputs (debug)');
//         // TutorialManager.instance.toggle();
//         return true;
//       }
//     }

//     return false;
//   }

//   // ====================================================================
//   // VERIFICAÇÕES
//   // ====================================================================

//   /// Verifica se pode processar input baseado no GameState
//   bool _canProcessInput() {
//     final state = GameStateMachine.instance.getRxCurrentState().value;

//     // Estados que bloqueiam input completamente
//     if (state == GameState.gameLoading ||
//         state == GameState.gameTransitioning ||
//         state == GameState.gameCutscene ||
//         state == GameState.uiOverlayGameover) {
//       return false;
//     }

//     return true;
//   }

//   /// Reset (útil para quando player morre ou troca de mapa)
//   void reset() {
//     nearestInteractable = null;
//     currentPlayer = null;
//     if (kDebugMode) debugPrint('[InputHelper] Reset complete');
//   }
// }