import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_ui_config.dart';
import 'package:flutter/material.dart';

class PlayerVitalStatsHUD extends InterfaceComponent {
  var _vMaxLife = 0.0;
  var _vCurrentLife = 0.0;
  var _vCurrentStamina = 0.0;

  PlayerVitalStatsHUD()
    : super(
        id: GameplayUIConfig.kComponentId,
        position: Vector2(
          GameplayUIConfig.kHUDPadding,
          GameplayUIConfig.kHUDPadding,
        ),
        spriteUnselected: Sprite.load(GameplayUIConfig.kHealthUIAsset),
        size: Vector2(GameplayUIConfig.kHUDWidth, GameplayUIConfig.kHUDHeight),
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
      _vCurrentLife = gameRef.player!.life;
      _vMaxLife = gameRef.player!.maxLife;

      if (gameRef.player is KnightPlayerView) {
        _vCurrentStamina = (gameRef.player as KnightPlayerView)
            .controller
            .model
            .currentStamina;
      }
    }
  }

  void _drawHealthBar(Canvas canvas) {
    _drawBarBackground(canvas, GameplayUIConfig.kHealthBarYPosition);

    final double healthBarWidth = _calculateHealthBarWidth();
    _drawHealthBarFill(canvas, healthBarWidth);
  }

  void _drawStaminaBar(Canvas canvas) {
    final double staminaBarWidth = _calculateStaminaBarWidth();

    canvas.drawLine(
      Offset(
        GameplayUIConfig.kBarXPosition,
        GameplayUIConfig.kStaminaBarYPosition,
      ),
      Offset(
        GameplayUIConfig.kBarXPosition + staminaBarWidth,
        GameplayUIConfig.kStaminaBarYPosition,
      ),
      Paint()
        ..color = GameplayUIConfig.kStaminaBarColor
        ..strokeWidth = GameplayUIConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawBarBackground(Canvas canvas, double yPosition) {
    canvas.drawLine(
      Offset(GameplayUIConfig.kBarXPosition, yPosition),
      Offset(
        GameplayUIConfig.kBarXPosition + GameplayUIConfig.kBarWidth,
        yPosition,
      ),
      Paint()
        ..color = GameplayUIConfig.kHealthBarBackgroundColor
        ..strokeWidth = GameplayUIConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawHealthBarFill(Canvas canvas, double barWidth) {
    canvas.drawLine(
      Offset(
        GameplayUIConfig.kBarXPosition,
        GameplayUIConfig.kHealthBarYPosition,
      ),
      Offset(
        GameplayUIConfig.kBarXPosition + barWidth,
        GameplayUIConfig.kHealthBarYPosition,
      ),
      Paint()
        ..color = _getHealthBarColor(barWidth)
        ..strokeWidth = GameplayUIConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  double _calculateHealthBarWidth() {
    if (_vMaxLife <= 0) return 0.0;
    return (_vCurrentLife * GameplayUIConfig.kBarWidth) / _vMaxLife;
  }

  double _calculateStaminaBarWidth() {
    return (_vCurrentStamina * GameplayUIConfig.kBarWidth) /
        GameplayUIConfig.kMaxStamina;
  }

  Color _getHealthBarColor(double currentHealthBarWidth) {
    final double healthPercentage =
        currentHealthBarWidth / GameplayUIConfig.kBarWidth;

    if (healthPercentage > GameplayUIConfig.kHealthWarningThreshold) {
      return GameplayUIConfig.kHealthBarGoodColor;
    } else if (healthPercentage > GameplayUIConfig.kHealthCriticalThreshold) {
      return GameplayUIConfig.kHealthBarWarningColor;
    } else {
      return GameplayUIConfig.kHealthBarCriticalColor;
    }
  }
}
