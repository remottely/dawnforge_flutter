eu quero q vc transforme o build de UnifiedGameOverlay em um switch q percorre obrigatoriamente todos os estados de GameState:
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/state/game_state_machine.dart';
import 'package:dawnforge/game/systems/overlay/hud.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

final class UnifiedGameOverlay extends StatelessWidget {
  final DDBasePlayerView player;
  final PlayerController? playerController;

  const UnifiedGameOverlay({
    super.key,
    required this.player,
    this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppDesignSystem.of(context).screenSize.isDesktop;

    const flexA = 1;
    const flexB = 6;
    const flexC = flexA + flexB;

    return ValueListenableBuilder<GameState>(
      valueListenable: GameStateMachine.instance.getRxCurrentState(),
      builder: (context, gameState, _) {
        return Stack(
          children: [
            // ✅ BASE UI (sempre visível ou condicionalmente)
            Hud(
              flexA: flexA,
              isDesktop: isDesktop,
              flexC: flexC,
              flexB: flexB,
              player: player,
              playerController: playerController,
              gameState: gameState,
            ),

            // // ✅ STATE-BASED OVERLAYS (sobrepõe a UI base)
            // if (gameState == GameState.paused)
            //   const PauseMenuOverlay(),

            // if (gameState == GameState.dialogue)
            //   const DialogueOverlay(),
            if (gameState == GameState.uiOverlayMarket)
              MarketPanelOverlay(player: player),

            // if (gameState == GameState.questLog)
            //   const QuestLogOverlay(),

            // if (gameState == GameState.map)
            //   const MapOverlay(),

            // if (gameState == GameState.settings)
            //   const SettingsOverlay(),

            // ✅ LOADING (overlay completo)
            if (gameState == GameState.gameLoading) const LoadingOverlay(),
          ],
        );
      },
    );
  }
}

te enviando o GameStateMachine atualizado:
// lib/core/state/game_state_machine.dart (VERSÃO LIMPA)
import 'package:flutter/foundation.dart';
import 'package:bonfire/bonfire.dart';

enum GameState {
  gameLoading,
  gameCutscene,
  gameTransitioning,
  gamePlaying,
  pausedInGamePlaying,
  uiMenuInventory,
  uiMenuQuest,
  uiMenuMap,
  uiMenuSettings,
  uiOverlayCrafting,
  uiOverlayCooking,
  uiOverlayChoiceDialog,
  uiOverlayConversation,
  uiOverlayMarket,
  uiOverlayFishing,
  uiOverlayGameover,
}

class GameStateMachine {
  static final GameStateMachine instance = GameStateMachine._();
  GameStateMachine._();

  // ✅ ÚNICA FONTE DA VERDADE
  final ValueNotifier<GameState> _rxCurrentState = ValueNotifier(
    // GameState.loading, // TODO(Kevin): NOW NOW - put it back
    GameState.gamePlaying, // TODO(Kevin): NOW NOW - remove it
  );
  ValueNotifier<GameState> getRxCurrentState() => _rxCurrentState;

  GameState? _previousState;
  final List<GameState> _stateHistory = [];

  BonfireGameInterface? _gameRef;

  bool get isGameLoading => _rxCurrentState.value == GameState.gameLoading;
  bool get isGameCutscene => _rxCurrentState.value == GameState.gameCutscene;
  bool get isGameTransitioning =>
      _rxCurrentState.value == GameState.gameTransitioning;
  bool get isGamePlaying => _rxCurrentState.value == GameState.gamePlaying;
  bool get isPausedInGamePlaying =>
      _rxCurrentState.value == GameState.pausedInGamePlaying;
  bool get isUiMenuInventory =>
      _rxCurrentState.value == GameState.uiMenuInventory;
  bool get isUiMenuQuest => _rxCurrentState.value == GameState.uiMenuQuest;
  bool get isUiMenuMap => _rxCurrentState.value == GameState.uiMenuMap;
  bool get isUiMenuSettings =>
      _rxCurrentState.value == GameState.uiMenuSettings;
  bool get isUiOverlayCrafting =>
      _rxCurrentState.value == GameState.uiOverlayCrafting;
  bool get isUiOverlayCooking =>
      _rxCurrentState.value == GameState.uiOverlayCooking;
  bool get isUiOverlayChoiceDialog =>
      _rxCurrentState.value == GameState.uiOverlayChoiceDialog;
  bool get isUiOverlayConversation =>
      _rxCurrentState.value == GameState.uiOverlayConversation;
  bool get isUiOverlayMarket =>
      _rxCurrentState.value == GameState.uiOverlayMarket;
  bool get isUiOverlayFishing =>
      _rxCurrentState.value == GameState.uiOverlayFishing;
  bool get isUiOverlayGameover =>
      _rxCurrentState.value == GameState.uiOverlayGameover;

  bool get isTimePlaying => _rxCurrentState.value == GameState.gamePlaying;

  bool get isTimePaused =>
      _rxCurrentState.value == GameState.gameLoading ||
      _rxCurrentState.value == GameState.gameCutscene ||
      _rxCurrentState.value == GameState.gameTransitioning ||
      _rxCurrentState.value == GameState.pausedInGamePlaying ||
      _rxCurrentState.value == GameState.uiMenuInventory ||
      _rxCurrentState.value == GameState.uiMenuQuest ||
      _rxCurrentState.value == GameState.uiMenuMap ||
      _rxCurrentState.value == GameState.uiMenuSettings ||
      _rxCurrentState.value == GameState.uiOverlayCrafting ||
      _rxCurrentState.value == GameState.uiOverlayCooking ||
      _rxCurrentState.value == GameState.uiOverlayChoiceDialog ||
      _rxCurrentState.value == GameState.uiOverlayConversation ||
      _rxCurrentState.value == GameState.uiOverlayMarket ||
      _rxCurrentState.value == GameState.uiOverlayFishing ||
      _rxCurrentState.value == GameState.uiOverlayGameover;

  // bool get canPlayerMove => isTimePlaying;

  // bool get canPlayerAttack => isTimePlaying;

  // bool get canPlayerInteract =>
  //     rxCurrentState.value == GameState.playing ||
  //     rxCurrentState.value == GameState.conversation;

  // bool get canOpenInventory =>
  //     rxCurrentState.value == GameState.playing ||
  //     rxCurrentState.value == GameState.pausedInPlayingMode;

  bool get shouldShowHUD => isTimePlaying;

  // bool get shouldPauseGameLogic =>
  //     rxCurrentState.value == GameState.pausedInPlayingMode ||
  //     rxCurrentState.value == GameState.inventory ||
  //     rxCurrentState.value == GameState.uiOverlayMarket ||
  //     rxCurrentState.value == GameState.map ||
  //     rxCurrentState.value == GameState.settings;

  // bool shouldShowOverlay(GameState state) => rxCurrentState.value == state;

  void initialize(BonfireGameInterface gameRef) {
    _gameRef = gameRef;
    debugPrint('[GameState] Initialized');
  }

  void _changeState(GameState newState) {
    if (_rxCurrentState.value == newState) {
      debugPrint('[GameState] Already in ${newState.name}');
      return;
    }

    debugPrint('[GameState] ${_rxCurrentState.value.name} → ${newState.name}');

    _previousState = _rxCurrentState.value;
    _stateHistory.add(_rxCurrentState.value);

    _onStateExit(_rxCurrentState.value);

    // ✅ ÚNICA MUDANÇA DE ESTADO
    _rxCurrentState.value = newState;

    _onStateEnter(newState);
  }

  void _returnToPreviousState() {
    if (_previousState != null) {
      _changeState(_previousState!);
    } else {
      _changeState(GameState.gamePlaying);
    }
  }

  void _onStateExit(GameState state) {
    switch (state) {
      case GameState.pausedInGamePlaying:
      case GameState.uiMenuInventory:
      case GameState.uiOverlayMarket:
      case GameState.uiMenuMap:
      case GameState.uiMenuSettings:
        _resumeEngine();
        break;
      default:
        break;
    }
  }

  void _onStateEnter(GameState state) {
    switch (state) {
      case GameState.gamePlaying:
        _resumeEngine();
        break;

      case GameState.pausedInGamePlaying:
      case GameState.uiMenuInventory:
      case GameState.uiOverlayMarket:
      case GameState.uiMenuMap:
      case GameState.uiMenuSettings:
        _pauseEngine();
        break;

      case GameState.uiOverlayConversation:
        _stopPlayerMovement();
        break;

      case GameState.gameCutscene:
        _pauseEngine();
        _stopPlayerMovement();
        break;

      default:
        break;
    }
  }

  void _pauseEngine() {
    if (_gameRef != null) {
      _gameRef!.pauseEngine();
      debugPrint('[GameState] ⏸️ Engine paused');
    }
  }

  void _resumeEngine() {
    if (_gameRef != null) {
      _gameRef!.resumeEngine();
      debugPrint('[GameState] ▶️ Engine resumed');
    }
  }

  void _stopPlayerMovement() {
    debugPrint('[GameState] 🛑 Player movement stopped');
  }

  // Helpers para transições comuns
  void openInventory() => _changeState(GameState.uiMenuInventory);
  void closeInventory() => _changeState(GameState.gamePlaying);

  void openMarket() => _changeState(GameState.uiOverlayMarket);
  void closeMarket() => _changeState(GameState.gamePlaying);

  void startDialogue() => _changeState(GameState.uiOverlayConversation);
  void endDialogue() => _changeState(GameState.gamePlaying);

  void pauseGame() => _changeState(GameState.pausedInGamePlaying);
  void resumeGame() => _changeState(GameState.gamePlaying);

  void openQuestLog() => _changeState(GameState.uiMenuQuest);
  void closeQuestLog() => _changeState(GameState.gamePlaying);

  void openMap() => _changeState(GameState.uiMenuMap);
  void closeMap() => _changeState(GameState.gamePlaying);

  void openSettings() => _changeState(GameState.uiMenuSettings);
  void closeSettings() => _returnToPreviousState();

  // Debug
  void printStateHistory() {
    debugPrint(
      '[GameState] History: ${_stateHistory.map((s) => s.name).join(" → ")}',
    );
  }

  void dispose() {
    _rxCurrentState.dispose();
  }
}
