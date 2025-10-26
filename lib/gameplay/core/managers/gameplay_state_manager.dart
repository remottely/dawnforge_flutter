import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GameplayStateManager extends GameComponent {
  static const _kGameOverCheckInterval = 'gameOver';
  static const _kGameOverCheckRate = 100;
  static const _kPlayerDeadState = 'playerDead';
  static const _kGameRestartEvent = 'gameRestart';

  bool _isGameOverDisplayed = false;
  bool _isProcessingGameOver = false;

  @override
  void update(double dt) {
    _processGameState(dt);
    super.update(dt);
  }

  void triggerGameOver() {
    if (!_isGameOverDisplayed && !_isProcessingGameOver) {
      _isProcessingGameOver = true;
      _handleGameOver();
    }
  }

  void _processGameState(double dt) {
    if (checkInterval(_kGameOverCheckInterval, _kGameOverCheckRate, dt)) {
      _checkForGameOverCondition();
    }
  }

  void _checkForGameOverCondition() {
    if (_shouldDisplayGameOver() && !_isProcessingGameOver) {
      _isProcessingGameOver = true;
      _handleGameOver();
    }
  }

  void _handleGameOver() {
    if (!_isGameOverDisplayed) {
      _isGameOverDisplayed = true;
      _displayGameOverDialog();
      _logGameEvent(_kPlayerDeadState);
    }
  }

  void _displayGameOverDialog() {
    _isGameOverDisplayed = true;
    GameplayUIManager.displayGameOverDialog(context, _onRetryGamePressed);
  }

  void _onRetryGamePressed(BuildContext dialogContext) {
    _logGameEvent(_kGameRestartEvent);
    _resetGameState();

    Navigator.of(dialogContext).pop();

    Future.delayed(const Duration(milliseconds: 100), () {
      _restartGame();
    });
  }

  bool _shouldDisplayGameOver() {
    return _hasValidPlayer() && _isPlayerDead();
  }

  bool _hasValidPlayer() {
    return gameRef.player != null;
  }

  bool _isPlayerDead() {
    return gameRef.player?.isDead == true;
  }

  void _resetGameState() {
    _isGameOverDisplayed = false;
    _isProcessingGameOver = false;
  }

  void _restartGame() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Gameplay()),
      (Route<dynamic> route) => false,
    );
  }

  void _logGameEvent(String eventName) {
    if (kDebugMode) {
      print('[GameplayStateManager] Event: $eventName at ${DateTime.now()}');
    }
  }
}
