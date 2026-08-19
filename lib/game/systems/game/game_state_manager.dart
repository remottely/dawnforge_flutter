import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/features/gameplay_screen.dart';
import 'package:dawnforge/game/systems/save/game_save_controller.dart';
import 'package:dawnforge/game/systems/ui/ui_state_manager.dart';
import 'package:flutter/material.dart';

class GameStateManager extends GameComponent {
  @override
  void update(double dt) {
    _processGameState(dt);
    super.update(dt);
  }

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
    GameLogger.info('[GameStateManager] Displaying game over dialog');
    _vIsGameOverDisplayed = true;
    UIStateManager.instance.displayGameOverDialog(context, _onPressRestartGame);
  }

  void _onPressRestartGame(BuildContext dialogContext) async {
    GameLogger.info('[GameStateManager] Restart button pressed');

    Navigator.of(dialogContext).pop();

    // Verifica se existe save
    final hasSave = await GameSaveController.instance.hasSave();

    if (hasSave) {
      GameLogger.info('[GameStateManager] Save found - Loading last save...');
      await GameSaveController.instance.loadGame();
    } else {
      GameLogger.info(
        '[GameStateManager] No save found - Resetting to initial state...',
      );
      await GameSaveController.instance.clearGameAndSave();
    }

    _resetGameState();

    Future.delayed(const Duration(milliseconds: 100), () {
      GameLogger.info('[GameStateManager] Restarting game...');
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

  static void stopPlayerMovement(Player player) {
    player.idle();
  }
}
