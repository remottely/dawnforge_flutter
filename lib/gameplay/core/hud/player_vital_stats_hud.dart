import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_ui_constants.dart';
import 'package:flutter/material.dart';

class PlayerVitalStatsHUD extends InterfaceComponent {
  double _maxLife = 0.0;
  double _currentLife = 0.0;
  double _currentStamina = 0.0;

  PlayerVitalStatsHUD()
    : super(
        id: GameplayUIConstants.kComponentId,
        position: Vector2(
          GameplayUIConstants.kHUDPadding,
          GameplayUIConstants.kHUDPadding,
        ),
        spriteUnselected: Sprite.load(GameplayUIConstants.kHealthUIAsset),
        size: Vector2(
          GameplayUIConstants.kHUDWidth,
          GameplayUIConstants.kHUDHeight,
        ),
      );

  @override
  void update(double deltaTime) {
    _updatePlayerStats();
    super.update(deltaTime);
  }

  @override
  void render(Canvas canvas) {
    try {
      _drawHealthBar(canvas);
      _drawStaminaBar(canvas);
    } catch (e) {}
    super.render(canvas);
  }

  void _updatePlayerStats() {
    if (gameRef.player != null) {
      _currentLife = gameRef.player!.life;
      _maxLife = gameRef.player!.maxLife;

      if (gameRef.player is KnightPlayerView) {
        _currentStamina = (gameRef.player as KnightPlayerView)
            .controller
            .model
            .currentStamina;
      }
    }
  }

  void _drawHealthBar(Canvas canvas) {
    _drawBarBackground(canvas, GameplayUIConstants.kHealthBarYPosition);

    final double healthBarWidth = _calculateHealthBarWidth();
    _drawHealthBarFill(canvas, healthBarWidth);
  }

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

  double _calculateHealthBarWidth() {
    if (_maxLife <= 0) return 0.0;
    return (_currentLife * GameplayUIConstants.kBarWidth) / _maxLife;
  }

  double _calculateStaminaBarWidth() {
    return (_currentStamina * GameplayUIConstants.kBarWidth) /
        GameplayUIConstants.kMaxStamina;
  }

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
