import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_hud_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

class PlayerVitalStatsHUDView extends InterfaceComponent {
  double _vMaxLife = 0.0;
  double _vCurrentLife = 0.0;
  double _vCurrentStamina = 0.0;

  PlayerVitalStatsHUDView()
    : super(
        id: PlayerVitalStatsHUDConfig.kComponentId,
        size: PlayerVitalStatsHUDConfig.componentSize,
        position: PlayerVitalStatsHUDConfig.componentPosition,
        spriteUnselected: PlayerVitalStatsHUDConfig.loadHealthUISprite(),
      );

  @override
  void update(double deltaTime) {
    _updatePlayerStats();
    super.update(deltaTime);
  }

  @override
  void render(Canvas canvas) {
    _drawHealthBar(canvas);
    _drawStaminaBar(canvas);
    super.render(canvas);
  }

  void _updatePlayerStats() {
    if (gameRef.player != null) {
      _vCurrentLife = gameRef.player!.life;
      _vMaxLife = gameRef.player!.maxLife;

      if (gameRef.player is DDBasePlayerView) {
        _vCurrentStamina = (gameRef.player as DDBasePlayerView)
            .controller
            .model
            .currentStamina;
      }
    }
  }

  void _drawHealthBar(Canvas canvas) {
    _drawBarBackground(canvas, PlayerVitalStatsHUDConfig.kHealthBarYPosition);

    final double healthBarWidth = _calculateHealthBarWidth();
    _drawHealthBarFill(canvas, healthBarWidth);
  }

  void _drawStaminaBar(Canvas canvas) {
    final double staminaBarWidth = _calculateStaminaBarWidth();

    canvas.drawLine(
      Offset(
        PlayerVitalStatsHUDConfig.kBarXPosition,
        PlayerVitalStatsHUDConfig.kStaminaBarYPosition,
      ),
      Offset(
        PlayerVitalStatsHUDConfig.kBarXPosition + staminaBarWidth,
        PlayerVitalStatsHUDConfig.kStaminaBarYPosition,
      ),
      Paint()
        ..color = PlayerVitalStatsHUDConfig.kStaminaBarColor
        ..strokeWidth = PlayerVitalStatsHUDConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawBarBackground(Canvas canvas, double yPosition) {
    canvas.drawLine(
      Offset(PlayerVitalStatsHUDConfig.kBarXPosition, yPosition),
      Offset(
        PlayerVitalStatsHUDConfig.kBarXPosition +
            PlayerVitalStatsHUDConfig.kBarWidth,
        yPosition,
      ),
      Paint()
        ..color = PlayerVitalStatsHUDConfig.kHealthBarBackgroundColor
        ..strokeWidth = PlayerVitalStatsHUDConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawHealthBarFill(Canvas canvas, double barWidth) {
    canvas.drawLine(
      Offset(
        PlayerVitalStatsHUDConfig.kBarXPosition,
        PlayerVitalStatsHUDConfig.kHealthBarYPosition,
      ),
      Offset(
        PlayerVitalStatsHUDConfig.kBarXPosition + barWidth,
        PlayerVitalStatsHUDConfig.kHealthBarYPosition,
      ),
      Paint()
        ..color = _getHealthBarColor(barWidth)
        ..strokeWidth = PlayerVitalStatsHUDConfig.kStrokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  double _calculateHealthBarWidth() {
    if (_vMaxLife <= 0) return 0.0;
    return (_vCurrentLife * PlayerVitalStatsHUDConfig.kBarWidth) / _vMaxLife;
  }

  double _calculateStaminaBarWidth() {
    return (_vCurrentStamina * PlayerVitalStatsHUDConfig.kBarWidth) /
        PlayerVitalStatsHUDConfig.kMaxStamina;
  }

  Color _getHealthBarColor(double currentHealthBarWidth) {
    final double _healthPercentage =
        currentHealthBarWidth / PlayerVitalStatsHUDConfig.kBarWidth;

    if (_healthPercentage > PlayerVitalStatsHUDConfig.kHealthWarningThreshold) {
      return PlayerVitalStatsHUDConfig.kHealthBarGoodColor;
    } else if (_healthPercentage >
        PlayerVitalStatsHUDConfig.kHealthCriticalThreshold) {
      return PlayerVitalStatsHUDConfig.kHealthBarWarningColor;
    } else {
      return PlayerVitalStatsHUDConfig.kHealthBarCriticalColor;
    }
  }
}
