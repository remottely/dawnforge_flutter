// lib/core/state/game_state_machine.dart (VERSÃO LIMPA)
import 'package:flutter/foundation.dart';
import 'package:bonfire/bonfire.dart';

enum GlobalState {
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

class GlobalStateMachine {
  static final GlobalStateMachine instance = GlobalStateMachine._();
  GlobalStateMachine._();

  // ✅ ÚNICA FONTE DA VERDADE
  final ValueNotifier<GlobalState> _rxCurrentState = ValueNotifier(
    // GlobalState.loading, // TODO(Kevin): NOW NOW - put it back
    GlobalState.gameplayResumed, // TODO(Kevin): NOW NOW - remove it
  );
  ValueNotifier<GlobalState> getRxCurrentState() => _rxCurrentState;

  GlobalState? _previousState;
  final List<GlobalState> _stateHistory = [];

  BonfireGameInterface? _gameRef;

  void initialize(BonfireGameInterface gameRef) {
    _gameRef = gameRef;
    debugPrint('[GlobalState] Initialized');
  }

  void _changeState(GlobalState newState) {
    if (_rxCurrentState.value == newState) {
      debugPrint('[GlobalState] Already in ${newState.name}');
      return;
    }

    debugPrint(
      '[GlobalState] ${_rxCurrentState.value.name} → ${newState.name}',
    );

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
      _changeState(GlobalState.gameplayResumed);
    }
  }

  void _onStateExit(GlobalState state) {
    switch (state) {
      case GlobalState.gameplayPaused:
      case GlobalState.uiMenuInventory:
      case GlobalState.uiOverlayMarket:
      case GlobalState.uiMenuMap:
      case GlobalState.uiMenuSettings:
        _resumeEngine();
        break;
      default:
        break;
    }
  }

  void _onStateEnter(GlobalState state) {
    switch (state) {
      case GlobalState.gameplayResumed:
        _resumeEngine();
        break;

      case GlobalState.gameplayPaused:
      case GlobalState.uiMenuInventory:
      case GlobalState.uiOverlayMarket:
      case GlobalState.uiMenuMap:
      case GlobalState.uiMenuSettings:
        _pauseEngine();
        break;

      case GlobalState.uiOverlayConversation:
        _stopPlayerMovement();
        break;

      case GlobalState.gameCutscene:
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
      debugPrint('[GlobalState] ⏸️ Engine paused');
    }
  }

  void _resumeEngine() {
    if (_gameRef != null) {
      _gameRef!.resumeEngine();
      debugPrint('[GlobalState] ▶️ Engine resumed');
    }
  }

  void _stopPlayerMovement() {
    debugPrint('[GlobalState] 🛑 Player movement stopped');
  }

  bool get isGameLoading => _rxCurrentState.value == GlobalState.gameLoading;
  bool get isGameCutscene => _rxCurrentState.value == GlobalState.gameCutscene;
  bool get isGameTransitioning =>
      _rxCurrentState.value == GlobalState.gameTransitioning;
  bool get isGamePlaying =>
      _rxCurrentState.value == GlobalState.gameplayResumed;
  bool get isPausedInGamePlaying =>
      _rxCurrentState.value == GlobalState.gameplayPaused;
  bool get isUiMenuInventory =>
      _rxCurrentState.value == GlobalState.uiMenuInventory;
  bool get isUiMenuQuest => _rxCurrentState.value == GlobalState.uiMenuQuest;
  bool get isUiMenuMap => _rxCurrentState.value == GlobalState.uiMenuMap;
  bool get isUiMenuSettings =>
      _rxCurrentState.value == GlobalState.uiMenuSettings;
  bool get isUiOverlayCrafting =>
      _rxCurrentState.value == GlobalState.uiOverlayCrafting;
  bool get isUiOverlayCooking =>
      _rxCurrentState.value == GlobalState.uiOverlayCooking;
  bool get isUiOverlayChoiceDialog =>
      _rxCurrentState.value == GlobalState.uiOverlayChoiceDialog;
  bool get isUiOverlayConversation =>
      _rxCurrentState.value == GlobalState.uiOverlayConversation;
  bool get isUiOverlayMarket =>
      _rxCurrentState.value == GlobalState.uiOverlayMarket;
  bool get isUiOverlayFishing =>
      _rxCurrentState.value == GlobalState.uiOverlayMinigameFishing;
  bool get isUiOverlayGameover =>
      _rxCurrentState.value == GlobalState.uiOverlayGameover;

  bool get isTimePlaying =>
      _rxCurrentState.value == GlobalState.gameplayResumed;

  bool get isTimePaused =>
      _rxCurrentState.value == GlobalState.gameLoading ||
      _rxCurrentState.value == GlobalState.gameCutscene ||
      _rxCurrentState.value == GlobalState.gameTransitioning ||
      _rxCurrentState.value == GlobalState.gameplayPaused ||
      _rxCurrentState.value == GlobalState.uiMenuInventory ||
      _rxCurrentState.value == GlobalState.uiMenuQuest ||
      _rxCurrentState.value == GlobalState.uiMenuMap ||
      _rxCurrentState.value == GlobalState.uiMenuSettings ||
      _rxCurrentState.value == GlobalState.uiOverlayCrafting ||
      _rxCurrentState.value == GlobalState.uiOverlayCooking ||
      _rxCurrentState.value == GlobalState.uiOverlayChoiceDialog ||
      _rxCurrentState.value == GlobalState.uiOverlayConversation ||
      _rxCurrentState.value == GlobalState.uiOverlayMarket ||
      _rxCurrentState.value == GlobalState.uiOverlayMinigameFishing ||
      _rxCurrentState.value == GlobalState.uiOverlayGameover;

  // bool get canPlayerMove => isTimePlaying;

  // bool get canPlayerAttack => isTimePlaying;

  // bool get canPlayerInteract =>
  //     rxCurrentState.value == GlobalState.playing ||
  //     rxCurrentState.value == GlobalState.conversation;

  // bool get canOpenInventory =>
  //     rxCurrentState.value == GlobalState.playing ||
  //     rxCurrentState.value == GlobalState.pausedInPlayingMode;

  bool get shouldShowHUD => isTimePlaying;

  // bool get shouldPauseGameLogic =>
  //     rxCurrentState.value == GlobalState.pausedInPlayingMode ||
  //     rxCurrentState.value == GlobalState.inventory ||
  //     rxCurrentState.value == GlobalState.uiOverlayMarket ||
  //     rxCurrentState.value == GlobalState.map ||
  //     rxCurrentState.value == GlobalState.settings;

  // bool shouldShowOverlay(GlobalState state) => rxCurrentState.value == state;

  // Helpers para transições comuns
  void openInventory() => _changeState(GlobalState.uiMenuInventory);
  void closeInventory() => _changeState(GlobalState.gameplayResumed);

  void openMarket() => _changeState(GlobalState.uiOverlayMarket);
  void closeMarket() => _changeState(GlobalState.gameplayResumed);

  void startConversation() => _changeState(GlobalState.uiOverlayConversation);
  void endConversation() => _changeState(GlobalState.gameplayResumed);

  void pauseGame() => _changeState(GlobalState.gameplayPaused);
  void resumeGame() => _changeState(GlobalState.gameplayResumed);

  void openQuest() => _changeState(GlobalState.uiMenuQuest);
  void closeQuest() => _changeState(GlobalState.gameplayResumed);

  void openMap() => _changeState(GlobalState.uiMenuMap);
  void closeMap() => _changeState(GlobalState.gameplayResumed);

  void openSettings() => _changeState(GlobalState.uiMenuSettings);
  void closeSettings() => _returnToPreviousState();

  void openCrafting() => _changeState(GlobalState.uiOverlayCrafting);
  void closeCrafting() => _changeState(GlobalState.gameplayResumed);

  void openCooking() => _changeState(GlobalState.uiOverlayCooking);
  void closeCooking() => _changeState(GlobalState.gameplayResumed);

  // Debug
  void printStateHistory() {
    debugPrint(
      '[GlobalState] History: ${_stateHistory.map((s) => s.name).join(" → ")}',
    );
  }

  void dispose() {
    _rxCurrentState.dispose();
  }
}
