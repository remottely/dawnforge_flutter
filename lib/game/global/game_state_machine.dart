// lib/core/state/game_state_machine.dart (VERSÃO LIMPA)
import 'package:flutter/foundation.dart';
import 'package:bonfire/bonfire.dart';

enum GameState {
  gameLoading,
  gameCutscene,
  gameTransitioning,
  gameplayResumed,
  gameplayPaused,
  uiMenuInventory,
  uiMenuQuest,
  uiMenuMap,
  uiMenuSettings,
  uiOverlayMinigameFishing,
  uiOverlayCrafting,
  uiOverlayCooking,
  uiOverlayMarket,
  uiOverlayChoiceDialog,
  uiOverlayConversation,
  uiOverlayGameover,
}

class GameStateMachine {
  static final GameStateMachine instance = GameStateMachine._();
  GameStateMachine._();

  // ✅ ÚNICA FONTE DA VERDADE
  final ValueNotifier<GameState> _rxCurrentState = ValueNotifier(
    // GameState.loading, // TODO(Kevin): NOW NOW - put it back
    GameState.gameplayResumed, // TODO(Kevin): NOW NOW - remove it
  );
  ValueNotifier<GameState> getRxCurrentState() => _rxCurrentState;

  GameState? _previousState;
  final List<GameState> _stateHistory = [];

  BonfireGameInterface? _gameRef;

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
      _changeState(GameState.gameplayResumed);
    }
  }

  void _onStateExit(GameState state) {
    switch (state) {
      case GameState.gameplayPaused:
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
      case GameState.gameplayResumed:
        _resumeEngine();
        break;

      case GameState.gameplayPaused:
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

  bool get isGameLoading => _rxCurrentState.value == GameState.gameLoading;
  bool get isGameCutscene => _rxCurrentState.value == GameState.gameCutscene;
  bool get isGameTransitioning =>
      _rxCurrentState.value == GameState.gameTransitioning;
  bool get isGamePlaying => _rxCurrentState.value == GameState.gameplayResumed;
  bool get isPausedInGamePlaying =>
      _rxCurrentState.value == GameState.gameplayPaused;
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
      _rxCurrentState.value == GameState.uiOverlayMinigameFishing;
  bool get isUiOverlayGameover =>
      _rxCurrentState.value == GameState.uiOverlayGameover;

  bool get isTimePlaying => _rxCurrentState.value == GameState.gameplayResumed;

  bool get isTimePaused =>
      _rxCurrentState.value == GameState.gameLoading ||
      _rxCurrentState.value == GameState.gameCutscene ||
      _rxCurrentState.value == GameState.gameTransitioning ||
      _rxCurrentState.value == GameState.gameplayPaused ||
      _rxCurrentState.value == GameState.uiMenuInventory ||
      _rxCurrentState.value == GameState.uiMenuQuest ||
      _rxCurrentState.value == GameState.uiMenuMap ||
      _rxCurrentState.value == GameState.uiMenuSettings ||
      _rxCurrentState.value == GameState.uiOverlayCrafting ||
      _rxCurrentState.value == GameState.uiOverlayCooking ||
      _rxCurrentState.value == GameState.uiOverlayChoiceDialog ||
      _rxCurrentState.value == GameState.uiOverlayConversation ||
      _rxCurrentState.value == GameState.uiOverlayMarket ||
      _rxCurrentState.value == GameState.uiOverlayMinigameFishing ||
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

  // Helpers para transições comuns
  void openInventory() => _changeState(GameState.uiMenuInventory);
  void closeInventory() => _changeState(GameState.gameplayResumed);

  void openMarket() => _changeState(GameState.uiOverlayMarket);
  void closeMarket() => _changeState(GameState.gameplayResumed);

  void startConversation() => _changeState(GameState.uiOverlayConversation);
  void endConversation() => _changeState(GameState.gameplayResumed);

  void pauseGame() => _changeState(GameState.gameplayPaused);
  void resumeGame() => _changeState(GameState.gameplayResumed);

  void openQuest() => _changeState(GameState.uiMenuQuest);
  void closeQuest() => _changeState(GameState.gameplayResumed);

  void openMap() => _changeState(GameState.uiMenuMap);
  void closeMap() => _changeState(GameState.gameplayResumed);

  void openSettings() => _changeState(GameState.uiMenuSettings);
  void closeSettings() => _returnToPreviousState();

  void openCrafting() => _changeState(GameState.uiOverlayCrafting);
  void closeCrafting() => _changeState(GameState.gameplayResumed);

  void openCooking() => _changeState(GameState.uiOverlayCooking);
  void closeCooking() => _changeState(GameState.gameplayResumed);

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
