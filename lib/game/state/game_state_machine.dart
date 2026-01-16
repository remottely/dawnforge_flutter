// lib/core/state/game_state_machine.dart (VERSÃO LIMPA)
import 'package:flutter/foundation.dart';
import 'package:bonfire/bonfire.dart';

enum GameState {
  loading,
  playing,
  paused,
  inventory,
  crafting,
  cooking,
  choiceDialog,
  conversation,
  trading,
  fishing,
  questLog,
  map,
  settings,
  cutscene,
  transitioning,
  gameover,
}

class GameStateMachine {
  static final GameStateMachine instance = GameStateMachine._();
  GameStateMachine._();

  // ✅ ÚNICA FONTE DA VERDADE
  final ValueNotifier<GameState> rxCurrentState = ValueNotifier(
    // GameState.loading, // TODO(Kevin): NOW NOW - put it back
    GameState.playing, // TODO(Kevin): NOW NOW - remove it
  );

  GameState? _previousState;
  final List<GameState> _stateHistory = [];

  BonfireGame? _gameRef;

  // Propriedades derivadas
  bool get isPlaying => rxCurrentState.value == GameState.playing;

  bool get canPlayerMove => rxCurrentState.value == GameState.playing;

  bool get canPlayerAttack => rxCurrentState.value == GameState.playing;

  bool get canPlayerInteract =>
      rxCurrentState.value == GameState.playing ||
      rxCurrentState.value == GameState.conversation;

  bool get canOpenInventory =>
      rxCurrentState.value == GameState.playing ||
      rxCurrentState.value == GameState.paused;

  bool get shouldShowHUD =>
      rxCurrentState.value == GameState.playing ||
      rxCurrentState.value == GameState.conversation;

  bool get shouldPauseGameLogic =>
      rxCurrentState.value == GameState.paused ||
      rxCurrentState.value == GameState.inventory ||
      rxCurrentState.value == GameState.trading ||
      rxCurrentState.value == GameState.map ||
      rxCurrentState.value == GameState.settings;

  bool shouldShowOverlay(GameState state) => rxCurrentState.value == state;

  void initialize(BonfireGame gameRef) {
    _gameRef = gameRef;
    debugPrint('[GameState] Initialized');
  }

  void _changeState(GameState newState) {
    if (rxCurrentState.value == newState) {
      debugPrint('[GameState] Already in ${newState.name}');
      return;
    }

    debugPrint('[GameState] ${rxCurrentState.value.name} → ${newState.name}');

    _previousState = rxCurrentState.value;
    _stateHistory.add(rxCurrentState.value);

    _onStateExit(rxCurrentState.value);

    // ✅ ÚNICA MUDANÇA DE ESTADO
    rxCurrentState.value = newState;

    _onStateEnter(newState);
  }

  void returnToPreviousState() {
    if (_previousState != null) {
      _changeState(_previousState!);
    } else {
      _changeState(GameState.playing);
    }
  }

  void _onStateExit(GameState state) {
    switch (state) {
      case GameState.paused:
      case GameState.inventory:
      case GameState.trading:
      case GameState.map:
      case GameState.settings:
        _resumeEngine();
        break;
      default:
        break;
    }
  }

  void _onStateEnter(GameState state) {
    switch (state) {
      case GameState.playing:
        _resumeEngine();
        break;

      case GameState.paused:
      case GameState.inventory:
      case GameState.trading:
      case GameState.map:
      case GameState.settings:
        _pauseEngine();
        break;

      case GameState.conversation:
        _stopPlayerMovement();
        break;

      case GameState.cutscene:
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
  void openInventory() => _changeState(GameState.inventory);
  void closeInventory() => _changeState(GameState.playing);

  void openMarket() => _changeState(GameState.trading);
  void closeMarket() => _changeState(GameState.playing);

  void startDialogue() => _changeState(GameState.conversation);
  void endDialogue() => _changeState(GameState.playing);

  void pauseGame() => _changeState(GameState.paused);
  void resumeGame() => _changeState(GameState.playing);

  void openQuestLog() => _changeState(GameState.questLog);
  void closeQuestLog() => _changeState(GameState.playing);

  void openMap() => _changeState(GameState.map);
  void closeMap() => _changeState(GameState.playing);

  void openSettings() => _changeState(GameState.settings);
  void closeSettings() => returnToPreviousState();

  // Debug
  void printStateHistory() {
    debugPrint(
      '[GameState] History: ${_stateHistory.map((s) => s.name).join(" → ")}',
    );
  }

  void dispose() {
    rxCurrentState.dispose();
  }
}
