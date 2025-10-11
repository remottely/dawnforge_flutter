import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/managers/ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Game State Manager responsible for handling game state changes and UI transitions
/// Following Flutter naming conventions for game management systems
class GameStateManager extends GameComponent {
  // Flutter-style constants for game state management
  static const String _kGameOverCheckInterval = 'gameOver';
  static const int _kGameOverCheckRate = 100;

  // Flutter-style constants for game events
  static const String _kPlayerDeadState = 'playerDead';
  static const String _kGameRestartEvent = 'gameRestart';

  // Private state variables following Flutter naming conventions
  bool _isGameOverDisplayed = false;
  bool _isProcessingGameOver = false;

  @override
  void update(double dt) {
    _processGameStateChecks(dt);
    super.update(dt);
  }

  /// Processes all game state checks in a centralized manner
  /// Following Flutter pattern of organizing update logic
  void _processGameStateChecks(double dt) {
    if (checkInterval(_kGameOverCheckInterval, _kGameOverCheckRate, dt)) {
      _checkForGameOverCondition();
    }
  }

  /// Checks for game over condition and handles state transition
  /// Following Flutter pattern of breaking down complex update logic
  void _checkForGameOverCondition() {
    if (_shouldDisplayGameOver() && !_isProcessingGameOver) {
      _isProcessingGameOver = true;
      _handleGameOverState();
    }
  }

  /// Handles the game over state transition
  /// Following Flutter state management patterns
  void _handleGameOverState() {
    if (!_isGameOverDisplayed) {
      _isGameOverDisplayed = true;
      _displayGameOverDialog();
      _logGameEvent(_kPlayerDeadState);
    }
  }

  /// Checks if the game over condition is met
  /// Following Flutter pattern of breaking complex conditions into readable methods
  bool _shouldDisplayGameOver() {
    return _hasValidPlayer() && _isPlayerDead();
  }

  /// Checks if player reference is valid
  /// Following Flutter pattern of null checking
  bool _hasValidPlayer() {
    return gameRef.player != null;
  }

  /// Checks if player is in dead state
  /// Following Flutter pattern of state checking
  bool _isPlayerDead() {
    return gameRef.player?.isDead == true;
  }

  /// Public method to manually trigger game over (for external systems)
  /// Following Flutter pattern of public API methods
  void triggerGameOver() {
    if (!_isGameOverDisplayed && !_isProcessingGameOver) {
      _isProcessingGameOver = true;
      _handleGameOverState();
    }
  }

  /// Displays the game over dialog and handles retry functionality
  /// Following Flutter naming convention for private UI methods
  void _displayGameOverDialog() {
    _isGameOverDisplayed = true;
    UIStateManager.displayGameOverDialog(context, _onRetryGamePressed);
  }

  /// Handles the retry game button press
  /// Following Flutter event handler naming convention
  void _onRetryGamePressed(BuildContext dialogContext) {
    _logGameEvent(_kGameRestartEvent);
    _resetGameState();
    // Close the dialog using the dialog's context
    Navigator.of(dialogContext).pop();
    // Add a small delay to ensure dialog is closed before navigating
    Future.delayed(const Duration(milliseconds: 100), () {
      _restartGame();
    });
  }

  /// Resets internal game state variables
  /// Following Flutter pattern of state cleanup
  void _resetGameState() {
    _isGameOverDisplayed = false;
    _isProcessingGameOver = false;
  }

  /// Restarts the game by navigating to a new game instance
  /// Following Flutter pattern of separating navigation logic
  void _restartGame() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Gameplay()),
      (Route<dynamic> route) => false,
    );
  }

  /// Logs game events for debugging and analytics
  /// Following Flutter pattern of centralized logging
  void _logGameEvent(String eventName) {
    // In a real Flutter project, this would integrate with analytics
    // For now, we'll use debug print following Flutter conventions
    if (kDebugMode) {
      print('[GameStateManager] Event: $eventName at ${DateTime.now()}');
    }
  }
}
