import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
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
    print('[GameStateManager] Displaying game over dialog');
    _vIsGameOverDisplayed = true;
    UIStateManager.instance.displayGameOverDialog(context, _onPressRestartGame);
  }

  void _onPressRestartGame(BuildContext dialogContext) async {
    print('[GameStateManager] Restart button pressed');
    
    Navigator.of(dialogContext).pop();
    
    // Verifica se existe save
    final hasSave = await GameSaveController.instance.hasSave();
    
    if (hasSave) {
      print('[GameStateManager] Save found - Loading last save...');
      await GameSaveController.instance.loadGame();
    } else {
      print('[GameStateManager] No save found - Resetting to initial state...');
      await GameSaveController.instance.clearGameAndSave();
    }
    
    _resetGameState();
    
    Future.delayed(const Duration(milliseconds: 100), () {
      print('[GameStateManager] Restarting game...');
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
