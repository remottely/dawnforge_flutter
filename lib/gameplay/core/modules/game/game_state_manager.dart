import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
import 'package:flutter/material.dart';

class GameStateManager extends GameComponent {
  @override
  void update(double dt) {
    _processGameState(dt);
    super.update(dt);
  }

  /// Game Over Handling
  static const String _kGameOverCheckIntervalKey = 'gameOver';
  static const int _kGameOverCheckRate = 100;

  bool _vIsGameOverDisplayed = false;
  bool _vIsProcessingGameOver = false;

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
    UIStateManager.instance.displayGameOverDialog(context, _onPressRestartGame);
  }

  void _onPressRestartGame(BuildContext dialogContext) {
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
      MaterialPageRoute(builder: (context) => const GameplayScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Utility Methods
  static void stopPlayerMovement(Player player) {
    player.idle();
  }
}
