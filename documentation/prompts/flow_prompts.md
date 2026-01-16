eu preciso q vc preencha meu InputHelper com todas as acoes do meu jogo relacionado a isInteractionAction.
// lib/core/input/input_helper.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/state/game_state_machine.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:flutter/foundation.dart';

/// Helper centralizado que processa TODOS os inputs do jogo
/// Segue ordem hierárquica: UI > Interações > Items > Movimento
class InputHelper {
  static final InputHelper instance = InputHelper._();
  InputHelper._();

  /// Referência para o objeto interativo mais próximo (Market, NPC, Chest, Door)
  GameComponent? nearestInteractable;

  /// Player atual (referência opcional)
  SimplePlayer? currentPlayer;

  /// MÉTODO PRINCIPAL: Processa input seguindo hierarquia
  /// Retorna TRUE se consumiu o input, FALSE se deve continuar processando
  bool processInput(JoystickActionEvent event) {
    if (kDebugMode) {
      debugPrint('[InputHelper] 🎮 Input: ${event.id} | ${event.event}');
    }

    // ✅ 1. VERIFICA SE PODE PROCESSAR (baseado no GameState)
    if (!_canProcessInput()) {
      if (kDebugMode) debugPrint('[InputHelper] ❌ Blocked by GameState');
      return true; // Bloqueia input
    }

    // ✅ 2. UI OVERLAYS (prioridade máxima)
    if (_handleUIOverlays(event)) {
      if (kDebugMode) debugPrint('[InputHelper] ✅ Consumed by UI Overlay');
      return true;
    }

    // ✅ 3. INTERAÇÕES COM MUNDO (NPCs, Market, Doors, Chests)
    if (_handleWorldInteractions(event)) {
      if (kDebugMode)
        debugPrint('[InputHelper] ✅ Consumed by World Interaction');
      return true;
    }

    // ✅ 4. HOTKEYS GLOBAIS (Inventory, Crafting, etc)
    if (_handleGlobalHotkeys(event)) {
      if (kDebugMode) debugPrint('[InputHelper] ✅ Consumed by Global Hotkey');
      return true;
    }

    // ✅ 5. USO DE ITEMS/EQUIPAMENTO (Farming, Combat, Consumables)
    // NÃO consumimos aqui, deixamos os Behaviors processarem
    if (kDebugMode) debugPrint('[InputHelper] ⚠️ Passing to Behaviors');
    return false;
  }

  // ====================================================================
  // HIERARQUIA DE PROCESSAMENTO
  // ====================================================================

  /// 1️⃣ UI OVERLAYS (Market, Dialogue, Crafting, Menus)
  bool _handleUIOverlays(JoystickActionEvent event) {
    final state = GameStateMachine.instance.getRxCurrentState().value;

    // ========== MARKET ABERTO ==========
    if (state == GameState.uiOverlayMarket) {
      // ESC fecha o market
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.UP) {
        GameStateMachine.instance.closeMarket();
        return true;
      }
      // Consome TODOS os inputs enquanto market aberto
      return true;
    }

    // ========== DIALOGUE/CONVERSATION ABERTO ==========
    if (state == GameState.uiOverlayConversation) {
      // INTERACT avança diálogo
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.DOWN) {
        // TODO: Avançar diálogo (implementar DialogueManager)
        debugPrint('[InputHelper] Advancing dialogue...');
        GameStateMachine.instance.endConversation();
        return true;
      }
      // Bloqueia outros inputs
      return true;
    }

    // ========== CHOICE DIALOG ABERTO ==========
    if (state == GameState.uiOverlayChoiceDialog) {
      // INTERACT confirma escolha
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.DOWN) {
        // TODO: Confirmar escolha (implementar DialogueManager)
        debugPrint('[InputHelper] Confirming choice...');
        return true;
      }
      return true;
    }

    // ========== CRAFTING ABERTO ==========
    if (state == GameState.uiOverlayCrafting) {
      // ESC ou K fecha crafting
      if ((InputDef.isInteractionAction(event.id) ||
              InputDef.isCraftingAction(event.id)) &&
          event.event == ActionEvent.DOWN) {
        GameStateMachine.instance.closeCrafting();
        return true;
      }
      return true;
    }

    // ========== COOKING ABERTO ==========
    if (state == GameState.uiOverlayCooking) {
      // ESC fecha cooking
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.DOWN) {
        GameStateMachine.instance.closeCooking();
        return true;
      }
      return true;
    }

    // ========== MENUS FULLSCREEN ABERTOS ==========
    if (state == GameState.uiMenuInventory) {
      // ESC ou TAB fecha inventory
      if ((InputDef.isInteractionAction(event.id) ||
              InputDef.isToggleInventoryAction(event.id)) &&
          event.event == ActionEvent.DOWN) {
        GameStateMachine.instance.closeInventory();
        return true;
      }
      return true;
    }

    if (state == GameState.uiMenuMap) {
      // ESC fecha map
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.DOWN) {
        GameStateMachine.instance.closeMap();
        return true;
      }
      return true;
    }

    if (state == GameState.uiMenuQuest) {
      // ESC fecha quest
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.DOWN) {
        GameStateMachine.instance.closeQuest();
        return true;
      }
      return true;
    }

    if (state == GameState.uiMenuSettings) {
      // ESC fecha settings
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.DOWN) {
        GameStateMachine.instance.closeSettings();
        return true;
      }
      return true;
    }

    // ========== FISHING MINIGAME ==========
    if (state == GameState.uiOverlayMinigameFishing) {
      // PRIMARY ACTION interage com minigame
      if (InputDef.isPrimaryAction(event.id)) {
        // TODO: Processar fishing minigame
        debugPrint('[InputHelper] Fishing minigame action...');
        return true;
      }
      return true;
    }

    // ========== GAME PAUSED ==========
    if (state == GameState.gameplayPaused) {
      // ESC resume
      if (InputDef.isInteractionAction(event.id) &&
          event.event == ActionEvent.DOWN) {
        GameStateMachine.instance.resumeGame();
        return true;
      }
      return true;
    }

    return false; // Não consumiu
  }

  /// 2️⃣ INTERAÇÕES COM MUNDO (NPCs, Decorações, Portas, Baús)
  bool _handleWorldInteractions(JoystickActionEvent event) {
    // Só processa tecla de interação (E, F, INTERACT)
    if (!InputDef.isInteractionAction(event.id)) {
      return false;
    }

    if (event.event != ActionEvent.DOWN) {
      return false;
    }

    // TEM ALGO PRÓXIMO PARA INTERAGIR?
    if (nearestInteractable != null) {
      if (kDebugMode) {
        debugPrint(
          '[InputHelper] 🔗 Interacting with: ${nearestInteractable.runtimeType}',
        );
      }

      // A interação específica já está implementada no component:
      // - MarketDecoration.onJoystickAction → abre market
      // - NPCDecoration.onJoystickAction → inicia diálogo
      // - ChestDecoration.onJoystickAction → abre baú
      // - DoorDecoration.onJoystickAction → troca de mapa

      // CONSOME o input para não usar item equipado
      return true;
    }

    return false;
  }

  /// 3️⃣ HOTKEYS GLOBAIS (Inventory, Crafting, Slot Selection)
  bool _handleGlobalHotkeys(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) {
      return false;
    }

    final currentState = GameStateMachine.instance.getRxCurrentState().value;

    // Só processa hotkeys em gameplay
    if (currentState != GameState.gameplayResumed) {
      return false;
    }

    // ========== INVENTORY (TAB/I) ==========
    if (InputDef.isToggleInventoryAction(event.id)) {
      GameStateMachine.instance.openInventory();
      return true;
    }

    // ========== CRAFTING (K) ==========
    if (InputDef.isCraftingAction(event.id)) {
      GameStateMachine.instance.openCrafting();
      return true;
    }

    // ========== TOOLBAR SLOT SELECTION (1-9) ==========
    final slotNumber = InputDef.getToolbarSlotNumber(event.id);
    if (slotNumber != null) {
      // TODO: Selecionar slot no EquipmentManager
      debugPrint('[InputHelper] 🎯 Selecting slot: $slotNumber');
      // EquipmentManager.instance.selectSlotIndex(slotNumber);
      return true;
    }

    // ========== NEXT/PREV SLOT (Q/E) ==========
    if (InputDef.isEquipMainHandAction(event.id)) {
      // TODO: Próximo slot
      debugPrint('[InputHelper] ➡️ Next slot');
      // EquipmentManager.instance.selectNextSlot();
      return true;
    }

    if (InputDef.isEquipMainHandReverseAction(event.id)) {
      // TODO: Slot anterior
      debugPrint('[InputHelper] ⬅️ Previous slot');
      // EquipmentManager.instance.selectPreviousSlot();
      return true;
    }

    // ========== DEBUG ACTIONS (apenas em debug mode) ==========
    if (kDebugMode) {
      if (InputDef.isAdvanceDayAction(event.id)) {
        debugPrint('[InputHelper] ⏭️ Advance day (debug)');
        // TimeManager.instance.advanceDay();
        return true;
      }

      if (InputDef.isClearSaveAction(event.id)) {
        debugPrint('[InputHelper] 🗑️ Clear save (debug)');
        // GameSaveController.instance.clearSave();
        return true;
      }

      if (InputDef.isAddTestItemsAction(event.id)) {
        debugPrint('[InputHelper] 🎁 Add test items (debug)');
        // InventoryManager.instance.addTestItems();
        return true;
      }

      if (InputDef.isToggleTutorialInputsAction(event.id)) {
        debugPrint('[InputHelper] 📖 Toggle tutorial inputs (debug)');
        // TutorialManager.instance.toggle();
        return true;
      }
    }

    return false;
  }

  // ====================================================================
  // VERIFICAÇÕES
  // ====================================================================

  /// Verifica se pode processar input baseado no GameState
  bool _canProcessInput() {
    final state = GameStateMachine.instance.getRxCurrentState().value;

    // Estados que bloqueiam input completamente
    if (state == GameState.gameLoading ||
        state == GameState.gameTransitioning ||
        state == GameState.gameCutscene ||
        state == GameState.uiOverlayGameover) {
      return false;
    }

    return true;
  }

  /// Reset (útil para quando player morre ou troca de mapa)
  void reset() {
    nearestInteractable = null;
    currentPlayer = null;
    debugPrint('[InputHelper] Reset complete');
  }
}

import 'package:bonfire/input/player_controller.dart';
import 'package:dawnforge/game/systems/input_actions/joysctick_setup.dart';
import 'package:dawnforge/game/systems/input_actions/keyboard_setup.dart';
import 'package:dawnforge/core/managers/settings_manager.dart';

final class InputDef {
  const InputDef._();

  static PlayerController create() =>
      switch (SettingsManager.instance.inputSelected) {
        InputActionsType.keyboard => KeyboardSetup.createInput(),
        InputActionsType.joystick => JoystickSetup.createInput(),
      };

  static bool isPrimaryAction(dynamic actionId) {
    final isPrimary =
        actionId == JoystickSetup.kPrimaryActionId ||
        actionId == KeyboardSetup.kPrimaryActionKey;

    return isPrimary;
  }

  static bool isInteractionAction(dynamic actionId) {
    return actionId == JoystickSetup.kInteractionId ||
        actionId == KeyboardSetup.kInteractionKey;
  }

  static bool isRunAction(dynamic actionId) {
    return actionId == JoystickSetup.kRunId ||
        actionId == KeyboardSetup.kRunKey;
  }

  static bool isAdvanceDayAction(dynamic actionId) {
    return actionId == JoystickSetup.kAdvanceDayId ||
        actionId == KeyboardSetup.kAdvanceDayKey;
  }

  static bool isClearSaveAction(dynamic actionId) {
    return actionId == JoystickSetup.kClearSaveId ||
        actionId == KeyboardSetup.kClearSaveKey;
  }

  static bool isToggleInventoryAction(dynamic actionId) {
    return actionId == JoystickSetup.kToggleInventoryId ||
        actionId == KeyboardSetup.kToggleInventoryKey;
  }

  static bool isToggleTutorialInputsAction(dynamic actionId) {
    return actionId == JoystickSetup.kToggleTutorialInputsId ||
        actionId == KeyboardSetup.kToggleInputsKey;
  }

  static bool isEquipMainHandAction(dynamic actionId) {
    return actionId == JoystickSetup.kSlotNavNextId ||
        actionId == KeyboardSetup.kSlotNavNextKey;
  }

  static bool isEquipMainHandReverseAction(dynamic actionId) {
    return actionId == JoystickSetup.kSlotNavPrevId ||
        actionId == KeyboardSetup.kSlotNavPrevKey;
  }

  static bool isAddTestItemsAction(dynamic actionId) {
    return actionId == JoystickSetup.kAddTestItemsId ||
        actionId == KeyboardSetup.kAddTestItemsKey;
  }

  // ========== TOOLBAR SLOT SELECTION (SV style) ==========
  static int? getToolbarSlotNumber(dynamic actionId) {
    if (actionId == KeyboardSetup.kSlot1Key) return 0;
    if (actionId == KeyboardSetup.kSlot2Key) return 1;
    if (actionId == KeyboardSetup.kSlot3Key) return 2;
    if (actionId == KeyboardSetup.kSlot4Key) return 3;
    if (actionId == KeyboardSetup.kSlot5Key) return 4;
    if (actionId == KeyboardSetup.kSlot6Key) return 5;
    if (actionId == KeyboardSetup.kSlot7Key) return 6;
    if (actionId == KeyboardSetup.kSlot8Key) return 7;
    if (actionId == KeyboardSetup.kSlot9Key) return 8;
    if (actionId == KeyboardSetup.kSlot10Key) return 9;
    if (actionId == KeyboardSetup.kSlot11Key) return 10;
    if (actionId == KeyboardSetup.kSlot12Key) return 11;
    return null;
  }

  static bool isCraftingAction(dynamic actionId) {
    return actionId == KeyboardSetup.kCraftingKey;
  }

  static bool isConsumeAction(dynamic actionId) => isPrimaryAction(actionId);
  static bool isDefenseAction(dynamic actionId) => isInteractionAction(actionId);

  
}

casos:
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/wizard/wizard_npc_controller.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/wizard/wizard_npc_def.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:dawnforge/game/systems/audio/audio_manager.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/game/systems/ui/ui_state_manager.dart';

class WizardNpcView extends SimpleNpc with PlayerControllerListener {
  bool _playerIsNearby = false;
  PlayerController? _playerInput;

  final WizardNpcController _controller = WizardNpcController(
    model: WizardNpcModel(),
  );

  WizardNpcView({required super.position})
    : super(
        animation: WizardNpcDef.animationWalkDirectional,
        size: WizardNpcDef.componentSize,
      );

  @override
  Future<void> onLoad() {
    _controller.attachView(this);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }

  // TODO(Kevin): pass it through controller
  void onDetectPlayerInCloseVisionRadius() {
    if (gameRef.player is SimplePlayer) {
      seeComponent(
        gameRef.player!,
        radiusVision: WizardNpcDef.kCloseVisionRadius,
        observed: (_) {
          if (!_playerIsNearby) {
            _playerIsNearby = true;

            // Register to receive player controller events
            final PlayerController? playerInput =
                gameRef.playerControllers?.firstOrNull;
            if (playerInput != null && _playerInput != playerInput) {
              _playerInput?.removeObserver(this);
              _playerInput = playerInput;
              playerInput.addObserver(this);
            }

            _controller.onPlayerDetected(
              gameRef.player!,
              interactionRequested: false,
            );
          }
        },
        notObserved: () {
          _playerIsNearby = false;
          // Unregister when player leaves
          if (_playerInput != null) {
            _playerInput!.removeObserver(this);
            _playerInput = null;
          }
        },
      );
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (_playerIsNearby &&
        event.event == ActionEvent.DOWN &&
        InputDef.isInteractionAction(event.id)) {
      _controller.onPlayerDetected(gameRef.player!, interactionRequested: true);
    }
  }

  void showConversation(Player player) {
    _controller.model.hasBeenFirstInteraction = true;
    AudioManager.instance.playConversationInteractionSfx();
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: WizardNpcDef.createConversationSequence(),
      onChangeConversation: _controller.onConversationChanged,
      onFinishConversation: _controller.onConversationFinished,
    );
  }

  @override
  void onRemove() {
    if (_playerInput != null) {
      _playerInput!.removeObserver(this);
      _playerInput = null;
    }
    super.onRemove();
  }
}
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/combat/death/character_fx_sprite_animations_def.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/game/systems/ui/emote_manager.dart';
import 'package:dawnforge/game/features/game_world/decorations/chest/chest_decoration_def.dart';
import 'package:dawnforge/game/features/game_world/decorations/chest/chest_decoration_controller.dart';
import 'package:dawnforge/game/features/game_world/decorations/chest/chest_decoration_model.dart';
import 'package:dawnforge/game/features/game_world/decorations/life_potion/life_potion_decoration.dart';
import 'package:dawnforge/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class ChestDecorationView extends DDInputReceiverDecorationView {
  late final ChestDecorationController _controller;
  late final TextPaint _textConfig;

  ChestDecorationView({
    required super.position,
    required ChestDecorationModel model,
  }) : super.withAnimation(
         animation: ChestDecorationConfig.loadAnimation(),
         size: ChestDecorationConfig.componentSize,
       ) {
    _initializeController(model);
  }

  ChestDecorationModel get model => _controller.model;

  void _initializeController(ChestDecorationModel model) {
    _controller = ChestDecorationController(
      model: model,
      onOpenChest: _onOpenChest,
      onDisplayExclamationEmote: _onDisplayExclamationEmote,
      onDetectPlayerInCloseVisionRadius: _onDetectPlayerInCloseVisionRadius,
    );
  }

  @override
  Future<void> onLoad() {
    _textConfig = ChestDecorationConfig.createTextConfig(width);
    add(ChestDecorationConfig.createHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (checkInterval(
      ChestDecorationConfig.kVisionCheckIntervalId,
      ChestDecorationConfig.kVisionCheckInterval,
      dt,
    )) {
      _controller.update(dt, gameRef.player as DDBasePlayerView?);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_controller.model.isDetectPlayer && !_controller.model.isOpened) {
      final textPosition = ChestDecorationConfig.getTextPosition(width, height);
      _textConfig.render(
        canvas,
        ChestDecorationConfig.interactionPromptText,
        textPosition,
      );
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (_controller.model.canInteract &&
        event.event == ActionEvent.DOWN &&
        InputDef.isInteractionAction(event.id)) {
      _controller.openChest();
    }
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  void _onDisplayExclamationEmote() {
    add(EmoteManager.displayEmoteAboveDecoration(size));
  }

  void _onOpenChest() {
    _spawnLifePotions();
    removeFromParent();
  }

  void _spawnLifePotions() {
    _spawnLifePotion();
    _spawnLifePotion();
  }

  void _spawnLifePotion() {
    final random = Random();
    final offset = Vector2(random.nextInt(5) + 1, random.nextInt(5) + 1);
    final potionPosition = position - offset;

    _addSmokeExplosion(potionPosition);
    gameRef.add(
      LifePotionDecorationView(
        position: potionPosition,
        healAmount: ChestDecorationConfig.kHealAmountPerPotion,
      ),
    );
  }

  void _addSmokeExplosion(Vector2 potionPosition) {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsDef.loadAnimationExplosionSmokeRight(),
        position: potionPosition,
        size: size,
        loop: false,
      ),
    );
  }

  void _onDetectPlayerInCloseVisionRadius({
    required DDBasePlayerView player,
    required void Function(DDBasePlayerView) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  }) {
    seeComponent(
      player as GameComponent,
      radiusVision: closeVisionRadius,
      observed: (GameComponent comp) {
        final playerView = comp as DDBasePlayerView;
        // Register to receive player controller events when player is nearby
        final PlayerController? playerInput =
            gameRef.playerControllers?.firstOrNull;
        if (playerInput != null) {
          registerToPlayerController(playerInput);
        }
        observed(playerView);
      },
      notObserved: () {
        // Unregister when player leaves
        unregisterFromPlayerController();
        notObserved();
      },
    );
  }
}
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/game/systems/ui/emote_manager.dart';
import 'package:dawnforge/game/features/game_world/decorations/torch/torch_decoration_config.dart';
import 'package:dawnforge/game/features/game_world/decorations/torch/torch_decoration_controller.dart';
import 'package:dawnforge/game/features/game_world/decorations/torch/torch_decoration_model.dart';
import 'package:dawnforge/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class TorchDecorationView extends DDInputReceiverDecorationView {
  late final TorchDecorationController _controller;
  late final TextPaint _interactionPromptTextPaint;

  TorchDecorationView.lightingEnabled({
    required super.position,
    required TorchDecorationModel model,
  }) : super.withAnimation(
         animation: TorchDecorationDef.loadAnimation(),
         size: TorchDecorationDef.componentSize,
       ) {
    _initializeController(model);
  }

  TorchDecorationView.lightingDisabled({
    required super.position,
    required TorchDecorationModel model,
  }) : super.withAnimation(
         animation: TorchDecorationDef.loadAnimation(),
         size: TorchDecorationDef.componentSize,
       ) {
    _initializeController(model);
  }

  TorchDecorationModel get model => _controller.model;

  void _initializeController(TorchDecorationModel model) {
    _controller = TorchDecorationController(
      model: model,
      onDisplayExclamationEmote: _onDisplayExclamationEmote,
      onToggleTorchState: _onToggleTorchState,
      onDetectPlayerInCloseVisionRadius: _onDetectPlayerInCloseVisionRadius,
    );
  }

  @override
  Future<void> onLoad() {
    setupLighting(TorchDecorationDef.lighting);
    _interactionPromptTextPaint = TorchDecorationDef.createTextConfig(width);

    if (model.isOn)
      lightingEnabled = true;
    else
      lightingEnabled = false;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (checkInterval(
      TorchDecorationDef.kVisionCheckIntervalId,
      TorchDecorationDef.kVisionCheckInterval,
      dt,
    )) {
      _controller.update(dt, gameRef.player as DDBasePlayerView?);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_shouldDisplayInteractionPrompt()) {
      _renderInteractionPrompt(canvas);
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (_controller.model.canInteract &&
        event.event == ActionEvent.DOWN &&
        InputDef.isInteractionAction(event.id)) {
      _controller.toggleTorchState();
    }
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  bool _shouldDisplayInteractionPrompt() {
    return _controller.model.isDetectPlayer && !_controller.model.isOn;
  }

  void _renderInteractionPrompt(Canvas canvas) {
    final textPosition = TorchDecorationDef.getTextPosition(width, height);
    _interactionPromptTextPaint.render(
      canvas,
      TorchDecorationDef.interactionPromptText,
      textPosition,
    );
  }

  void _onDisplayExclamationEmote() {
    add(EmoteManager.displayEmoteAboveDecoration(size));
  }

  void _onToggleTorchState() {
    lightingEnabled = model.isOn;
  }

  void _onDetectPlayerInCloseVisionRadius({
    required DDBasePlayerView player,
    required void Function(DDBasePlayerView) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  }) {
    seeComponent(
      player as GameComponent,
      radiusVision: closeVisionRadius,
      observed: (GameComponent comp) {
        final playerView = comp as DDBasePlayerView;
        // Register to receive player controller events when player is nearby
        final PlayerController? playerInput =
            gameRef.playerControllers?.firstOrNull;
        if (playerInput != null) {
          registerToPlayerController(playerInput);
        }
        observed(playerView);
      },
      notObserved: () {
        // Unregister when player leaves
        unregisterFromPlayerController();
        notObserved();
      },
    );
  }
}
import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/shared/framework/decorations/dd_contact_decoration.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:dawnforge/core/utils/game_logger.dart';

class MarketDecoration extends DDContactDecoration
    with PlayerControllerListener {
  static final Set<String> _spawnedPositions = <String>{};

  static void clearSpawnRegistry() {
    GameLogger.debug(
      '[MarketDecoration] Clearing spawn registry (${_spawnedPositions.length} entries)',
    );
    _spawnedPositions.clear();
  }

  final String? overlayId;
  final FutureOr<void> Function() onOpenMarket;
  final FutureOr<void> Function() onCloseMarket;
  final Sprite? interactionIcon;

  bool _registered = false;
  bool _hasActiveContact = false;

  PlayerController? _playerInput;
  DDBasePlayerView? _currentPlayer;

  MarketDecoration({
    required super.position,
    required super.size,
    required this.onOpenMarket,
    required this.onCloseMarket,
    this.overlayId,
    this.interactionIcon,
  });

  @override
  void onContact(SimplePlayer component) {
    super.onContact(component);
    if (_hasActiveContact) return;

    _hasActiveContact = true;
    _currentPlayer = component is DDBasePlayerView ? component : _currentPlayer;
    _registerToPlayerController();

    GameLogger.debug(
      '[MarketDecoration] onContact -> waiting interaction at $_spawnKey',
    );
  }

  @override
  void onContactExit(SimplePlayer component) {
    super.onContactExit(component);

    _hasActiveContact = false;
    _currentPlayer = null;

    _unregisterFromPlayerController();

    GameLogger.debug(
      '[MarketDecoration] onContactExit -> unlock at $_spawnKey',
    );

    onCloseMarket.call();
  }

  @override
  void onMount() {
    super.onMount();

    final key = _spawnKey;
    if (_spawnedPositions.contains(key)) {
      GameLogger.warning(
        '[MarketDecoration] Duplicate instance detected at $key; removing extra copy.',
      );
      scheduleMicrotask(removeFromParent);
      return;
    }

    _registered = true;
    _spawnedPositions.add(key);
  }

  @override
  void onRemove() {
    _unregisterFromPlayerController();

    if (_registered) {
      _spawnedPositions.remove(_spawnKey);
    }

    GameLogger.debug(
      '[MarketDecoration] removed at $_spawnKey (registered=$_registered)',
    );

    super.onRemove();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (!_hasActiveContact) return;
    if (event.event != ActionEvent.DOWN) return;
    if (!InputDef.isInteractionAction(event.id)) return;

    final player = _currentPlayer;
    if (player == null) {
      GameLogger.debug(
        '[MarketDecoration] interaction ignored, no player reference at $_spawnKey',
      );
      return;
    }

    onOpenMarket.call();
  }

  // @override
  // void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
  //   if (event.directional == JoystickMoveDirectional.IDLE) return;

  //   GameLogger.debug(
  //     '[MarketDecoration] movement detected -> closing market at $_spawnKey',
  //   );

  //   _closeMarket();
  // }

  void _registerToPlayerController() {
    final PlayerController? playerInput =
        gameRef.playerControllers?.firstOrNull;
    if (playerInput == null || _playerInput == playerInput) return;

    _playerInput?.removeObserver(this);
    playerInput.addObserver(this);
    _playerInput = playerInput;
  }

  void _unregisterFromPlayerController() {
    _playerInput?.removeObserver(this);
    _playerInput = null;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderHint(canvas);
  }

  void _renderHint(Canvas canvas) {
    // Desenha um pequeno ícone de interação acima do market para guiar o jogador.
    if (interactionIcon == null) return;

    final hintOffset = Offset(size.x / 2 - 8, -18);
    interactionIcon!.render(
      canvas,
      position: Vector2(hintOffset.dx, hintOffset.dy),
      size: Vector2.all(16),
    );
  }

  String get _spawnKey =>
      '${position.x.toStringAsFixed(3)}|${position.y.toStringAsFixed(3)}';
}
