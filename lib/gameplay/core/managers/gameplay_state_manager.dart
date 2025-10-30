import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:flutter/material.dart';

class GameplayStateManager extends GameComponent {
  @override
  void update(double dt) {
    _processGameState(dt);
    super.update(dt);
  }

  /// >>> Start Game Over Handling
  static const _kGameOverCheckIntervalKey = 'gameOver';
  static const _kGameOverCheckRate = 100;

  var _vIsGameOverDisplayed = false;
  var _vIsProcessingGameOver = false;

  void _processGameState(double dt) {
    if (checkInterval(_kGameOverCheckIntervalKey, _kGameOverCheckRate, dt)) {
      _checkForGameOverCondition();
    }
  }

  void _checkForGameOverCondition() {
    if (_shouldDisplayGameOver() && !_vIsProcessingGameOver) {
      _vIsProcessingGameOver = true;
      _handleGameOver();
    }
  }

  void _handleGameOver() {
    if (!_vIsGameOverDisplayed) {
      _displayGameOverDialog();
    }
  }

  void _displayGameOverDialog() {
    _vIsGameOverDisplayed = true;
    GameplayUIManager.instance.displayGameOverDialog(
      context,
      _onRestartGamePressed,
    );
  }

  void _onRestartGamePressed(BuildContext dialogContext) {
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
    _vIsGameOverDisplayed = false;
    _vIsProcessingGameOver = false;
  }

  void _restartGame() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Gameplay()),
      (Route<dynamic> route) => false,
    );
  }

  /// <<< End Game Over Handling
}
