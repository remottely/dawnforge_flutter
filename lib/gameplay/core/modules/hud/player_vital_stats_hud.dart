import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay_hud_config.dart';
import 'package:flutter/material.dart';

class PlayerVitalStatsHUD extends InterfaceComponent {
  double _vMaxLife = 0.0;
  double _vCurrentLife = 0.0;
  double _vCurrentStamina = 0.0;

  PlayerVitalStatsHUD()
    : super(
        id: GameplayHUDConfig.kComponentId,
        position: Vector2(
          GameplayHUDConfig.kHUDPadding,
          GameplayHUDConfig.kHUDPadding,
        ),
        spriteUnselected: Sprite.load(GameplayHUDConfig.kHealthUIAsset),
        size: Vector2(
          GameplayHUDConfig.kHUDWidth,
          GameplayHUDConfig.kHUDHeight,
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
    _drawBarBackground(canvas, GameplayHUDConfig.kHealthBarYPosition);

    final double healthBarWidth = _calculateHealthBarWidth();
    _drawHealthBarFill(canvas, healthBarWidth);
  }

  void _drawStaminaBar(Canvas canvas) {
    final double staminaBarWidth = _calculateStaminaBarWidth();

    canvas.drawLine(
      Offset(
        GameplayHUDConfig.kBarXPosition,
        GameplayHUDConfig.kStaminaBarYPosition,
      ),
      Offset(
        GameplayHUDConfig.kBarXPosition + staminaBarWidth,
        GameplayHUDConfig.kStaminaBarYPosition,
      ),
      Paint()
        ..color = GameplayHUDConfig.kStaminaBarColor
        ..strokeWidth = GameplayHUDConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawBarBackground(Canvas canvas, double yPosition) {
    canvas.drawLine(
      Offset(GameplayHUDConfig.kBarXPosition, yPosition),
      Offset(
        GameplayHUDConfig.kBarXPosition + GameplayHUDConfig.kBarWidth,
        yPosition,
      ),
      Paint()
        ..color = GameplayHUDConfig.kHealthBarBackgroundColor
        ..strokeWidth = GameplayHUDConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawHealthBarFill(Canvas canvas, double barWidth) {
    canvas.drawLine(
      Offset(
        GameplayHUDConfig.kBarXPosition,
        GameplayHUDConfig.kHealthBarYPosition,
      ),
      Offset(
        GameplayHUDConfig.kBarXPosition + barWidth,
        GameplayHUDConfig.kHealthBarYPosition,
      ),
      Paint()
        ..color = _getHealthBarColor(barWidth)
        ..strokeWidth = GameplayHUDConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  double _calculateHealthBarWidth() {
    if (_vMaxLife <= 0) return 0.0;
    return (_vCurrentLife * GameplayHUDConfig.kBarWidth) / _vMaxLife;
  }

  double _calculateStaminaBarWidth() {
    return (_vCurrentStamina * GameplayHUDConfig.kBarWidth) /
        GameplayHUDConfig.kMaxStamina;
  }

  Color _getHealthBarColor(double currentHealthBarWidth) {
    final double healthPercentage =
        currentHealthBarWidth / GameplayHUDConfig.kBarWidth;

    if (healthPercentage > GameplayHUDConfig.kHealthWarningThreshold) {
      return GameplayHUDConfig.kHealthBarGoodColor;
    } else if (healthPercentage > GameplayHUDConfig.kHealthCriticalThreshold) {
      return GameplayHUDConfig.kHealthBarWarningColor;
    } else {
      return GameplayHUDConfig.kHealthBarCriticalColor;
    }
  }
}
