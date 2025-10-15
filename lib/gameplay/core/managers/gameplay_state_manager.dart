import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/gameplay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Game State Manager responsible for handling game state changes and UI transitions
/// Following Flutter naming conventions for game management systems
///
/// This class handles:
/// - Game over condition detection and state management
/// - Dialog display coordination with GameplayUIManager
/// - Game restart functionality and navigation
/// - Centralized logging for game state events
class GameplayStateManager extends GameComponent {
  // 1. Constantes (agrupadas por tipo)
  static const String kGameOverCheckInterval = 'gameOver';
  static const int kGameOverCheckRate = 100;
  static const String kPlayerDeadState = 'playerDead';
  static const String kGameRestartEvent = 'gameRestart';

  // 2. Variáveis de instância privadas
  bool _isGameOverDisplayed = false;
  bool _isProcessingGameOver = false;

  // 3. Métodos públicos principais
  @override
  void update(double dt) {
    _processGameState(dt);
    super.update(dt);
  }

  /// Public method to manually trigger game over (for external systems)
  /// Following Flutter pattern of public API methods
  void triggerGameOver() {
    if (!_isGameOverDisplayed && !_isProcessingGameOver) {
      _isProcessingGameOver = true;
      _handleGameOver();
    }
  }

  // 4. Métodos privados auxiliares (organizados por funcionalidade)
  /// Processes all game state checks in a centralized manner
  /// Following Flutter pattern of organizing update logic
  void _processGameState(double dt) {
    if (checkInterval(kGameOverCheckInterval, kGameOverCheckRate, dt)) {
      _checkForGameOverCondition();
    }
  }

  /// Checks for game over condition and handles state transition
  /// Following Flutter pattern of breaking down complex update logic
  void _checkForGameOverCondition() {
    if (_shouldDisplayGameOver() && !_isProcessingGameOver) {
      _isProcessingGameOver = true;
      _handleGameOver();
    }
  }

  /// Handles the game over state transition
  /// Following Flutter state management patterns
  void _handleGameOver() {
    if (!_isGameOverDisplayed) {
      _isGameOverDisplayed = true;
      _displayGameOverDialog();
      _logGameEvent(kPlayerDeadState);
    }
  }

  /// Displays the game over dialog and handles retry functionality
  /// Following Flutter naming convention for private UI methods
  void _displayGameOverDialog() {
    _isGameOverDisplayed = true;
    GameplayUIManager.displayGameOverDialog(context, _onRetryGamePressed);
  }

  /// Handles the retry game button press
  /// Following Flutter event handler naming convention
  void _onRetryGamePressed(BuildContext dialogContext) {
    _logGameEvent(kGameRestartEvent);
    _resetGameState();
    // Close the dialog using the dialog's context
    Navigator.of(dialogContext).pop();
    // Add a small delay to ensure dialog is closed before navigating
    Future.delayed(const Duration(milliseconds: 100), () {
      _restartGame();
    });
  }

  // 5. Métodos utilitários
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
      print('[GameplayStateManager] Event: $eventName at ${DateTime.now()}');
    }
  }
}
