import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

/// [PlayerVitalStatsHUD] responsible for displaying player's health and stamina bars
/// Following Flutter naming conventions for HUD component systems
///
/// This class handles:
/// - Real-time health bar visualization with color coding
/// - Stamina bar display for player actions
/// - Dynamic updates based on player state changes
class PlayerVitalStatsHUD extends InterfaceComponent {
  // Private state variables
  double _maxLife = 0.0;
  double _currentLife = 0.0;
  double _currentStamina = 0.0;

  /// Creates a player vital stats HUD component
  /// Following Flutter pattern of component initialization
  PlayerVitalStatsHUD()
    : super(
        id: GameplayUIConstants.kComponentId,
        position: Vector2(
          GameplayUIConstants.kHUDPadding,
          GameplayUIConstants.kHUDPadding,
        ),
        spriteUnselected: Sprite.load(GameplayUIConstants.kHealthUIAssetPath),
        size: Vector2(
          GameplayUIConstants.kHUDWidth,
          GameplayUIConstants.kHUDHeight,
        ),
      );

  // Lifecycle methods

  /// Updates the HUD with current player vital statistics
  /// Following Flutter pattern of state update methods
  @override
  void update(double deltaTime) {
    _updatePlayerStats();
    super.update(deltaTime);
  }

  /// Renders the health and stamina bars on the game canvas
  /// Following Flutter pattern of render lifecycle methods
  @override
  void render(Canvas canvas) {
    try {
      _drawHealthBar(canvas);
      _drawStaminaBar(canvas);
    } catch (e) {
      // Silent catch to prevent render crashes
    }
    super.render(canvas);
  }

  // Private helper methods

  /// Updates internal player statistics from game reference
  /// Following Flutter pattern of private utility methods with underscore prefix
  void _updatePlayerStats() {
    if (gameRef.player != null) {
      _currentLife = gameRef.player!.life;
      _maxLife = gameRef.player!.maxLife;

      // Update stamina if player is a KnightPlayerView
      if (gameRef.player is KnightPlayerView) {
        _currentStamina = (gameRef.player as KnightPlayerView)
            .controller
            .model
            .currentStamina;
      }
    }
  }

  /// Draws the player's health bar with color-coded status indication
  /// Following Flutter pattern of private rendering methods
  void _drawHealthBar(Canvas canvas) {
    // Draw background bar (empty health)
    _drawBarBackground(canvas, GameplayUIConstants.kHealthBarYPosition);

    // Calculate and draw current health bar
    final double healthBarWidth = _calculateHealthBarWidth();
    _drawHealthBarFill(canvas, healthBarWidth);
  }

  /// Draws the player's stamina bar in yellow
  /// Following Flutter pattern of private rendering methods
  void _drawStaminaBar(Canvas canvas) {
    final double staminaBarWidth = _calculateStaminaBarWidth();

    canvas.drawLine(
      Offset(
        GameplayUIConstants.kBarXPosition,
        GameplayUIConstants.kStaminaBarYPosition,
      ),
      Offset(
        GameplayUIConstants.kBarXPosition + staminaBarWidth,
        GameplayUIConstants.kStaminaBarYPosition,
      ),
      Paint()
        ..color = GameplayUIConstants.kStaminaBarColor
        ..strokeWidth = GameplayUIConstants.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  /// Draws the background for health bar
  /// Following Flutter pattern of helper rendering methods
  void _drawBarBackground(Canvas canvas, double yPosition) {
    canvas.drawLine(
      Offset(GameplayUIConstants.kBarXPosition, yPosition),
      Offset(
        GameplayUIConstants.kBarXPosition + GameplayUIConstants.kBarWidth,
        yPosition,
      ),
      Paint()
        ..color = GameplayUIConstants.kHealthBarBackgroundColor
        ..strokeWidth = GameplayUIConstants.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  /// Draws the filled portion of the health bar with appropriate color
  /// Following Flutter pattern of specialized rendering methods
  void _drawHealthBarFill(Canvas canvas, double barWidth) {
    canvas.drawLine(
      Offset(
        GameplayUIConstants.kBarXPosition,
        GameplayUIConstants.kHealthBarYPosition,
      ),
      Offset(
        GameplayUIConstants.kBarXPosition + barWidth,
        GameplayUIConstants.kHealthBarYPosition,
      ),
      Paint()
        ..color = _getHealthBarColor(barWidth)
        ..strokeWidth = GameplayUIConstants.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  // Utility methods

  /// Calculates the current health bar width based on player's life ratio
  /// Following Flutter pattern of calculation utility methods
  double _calculateHealthBarWidth() {
    if (_maxLife <= 0) return 0.0;
    return (_currentLife * GameplayUIConstants.kBarWidth) / _maxLife;
  }

  /// Calculates the current stamina bar width based on player's stamina ratio
  /// Following Flutter pattern of calculation utility methods
  double _calculateStaminaBarWidth() {
    return (_currentStamina * GameplayUIConstants.kBarWidth) /
        GameplayUIConstants.kMaxStamina;
  }

  /// Determines the appropriate color for the health bar based on current health level
  /// Following Flutter pattern of color utility methods
  ///
  /// Returns:
  /// - Green: Health > 66%
  /// - Yellow: Health 33% - 66%
  /// - Red: Health < 33%
  Color _getHealthBarColor(double currentHealthBarWidth) {
    final double healthPercentage =
        currentHealthBarWidth / GameplayUIConstants.kBarWidth;

    if (healthPercentage > GameplayUIConstants.kHealthWarningThreshold) {
      return GameplayUIConstants.kHealthBarGoodColor;
    } else if (healthPercentage >
        GameplayUIConstants.kHealthCriticalThreshold) {
      return GameplayUIConstants.kHealthBarWarningColor;
    } else {
      return GameplayUIConstants.kHealthBarCriticalColor;
    }
  }
}
