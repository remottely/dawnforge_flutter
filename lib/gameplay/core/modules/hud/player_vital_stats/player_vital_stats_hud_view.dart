// import 'package:bonfire/bonfire.dart';
// import 'package:dawnforge/gameplay/core/modules/hud/player_vital_stats/player_vital_stats_hud_def.dart';
// import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
// import 'package:flutter/material.dart';

// class PlayerVitalStatsHUDView extends InterfaceComponent {
//   double _vMaxLife = 0.0;
//   double _vCurrentLife = 0.0;
//   double _vCurrentStamina = 0.0;

//   PlayerVitalStatsHUDView()
//     : super(
//         id: PlayerVitalStatsHUDDef.kComponentId,
//         size: PlayerVitalStatsHUDDef.componentSize,
//         position: PlayerVitalStatsHUDDef.componentPosition,
//         spriteUnselected: PlayerVitalStatsHUDDef.loadHealthUISprite(),
//       );

//   @override
//   void update(double deltaTime) {
//     _updatePlayerStats();
//     super.update(deltaTime);
//   }

//   @override
//   void render(Canvas canvas) {
//     _drawHealthBar(canvas);
//     _drawStaminaBar(canvas);
//     super.render(canvas);
//   }

//   void _updatePlayerStats() {
//     if (gameRef.player != null) {
//       _vCurrentLife = gameRef.player!.life;
//       _vMaxLife = gameRef.player!.maxLife;

//       if (gameRef.player is DemoPlayer) {
//         _vCurrentStamina =
//             (gameRef.player as DemoPlayer).data.stamina;
//       }
//     }
//   }

//   void _drawHealthBar(Canvas canvas) {
//     _drawBarBackground(canvas, PlayerVitalStatsHUDDef.kHealthBarYPosition);

//     final double healthBarWidth = _calculateHealthBarWidth();
//     _drawHealthBarFill(canvas, healthBarWidth);
//   }

//   void _drawStaminaBar(Canvas canvas) {
//     final double staminaBarWidth = _calculateStaminaBarWidth();

//     canvas.drawLine(
//       Offset(
//         PlayerVitalStatsHUDDef.kBarXPosition,
//         PlayerVitalStatsHUDDef.kStaminaBarYPosition,
//       ),
//       Offset(
//         PlayerVitalStatsHUDDef.kBarXPosition + staminaBarWidth,
//         PlayerVitalStatsHUDDef.kStaminaBarYPosition,
//       ),
//       Paint()
//         ..color = PlayerVitalStatsHUDDef.kStaminaBarColor
//         ..strokeWidth = PlayerVitalStatsHUDDef.kStrokeWidth
//         ..style = PaintingStyle.fill,
//     );
//   }

//   void _drawBarBackground(Canvas canvas, double yPosition) {
//     canvas.drawLine(
//       Offset(PlayerVitalStatsHUDDef.kBarXPosition, yPosition),
//       Offset(
//         PlayerVitalStatsHUDDef.kBarXPosition + PlayerVitalStatsHUDDef.kBarWidth,
//         yPosition,
//       ),
//       Paint()
//         ..color = PlayerVitalStatsHUDDef.kHealthBarBackgroundColor
//         ..strokeWidth = PlayerVitalStatsHUDDef.kStrokeWidth
//         ..style = PaintingStyle.fill,
//     );
//   }

//   void _drawHealthBarFill(Canvas canvas, double barWidth) {
//     canvas.drawLine(
//       Offset(
//         PlayerVitalStatsHUDDef.kBarXPosition,
//         PlayerVitalStatsHUDDef.kHealthBarYPosition,
//       ),
//       Offset(
//         PlayerVitalStatsHUDDef.kBarXPosition + barWidth,
//         PlayerVitalStatsHUDDef.kHealthBarYPosition,
//       ),
//       Paint()
//         ..color = _getHealthBarColor(barWidth)
//         ..strokeWidth = PlayerVitalStatsHUDDef.kStrokeWidth
//         ..style = PaintingStyle.fill,
//     );
//   }

//   double _calculateHealthBarWidth() {
//     if (_vMaxLife <= 0) return 0.0;
//     return (_vCurrentLife * PlayerVitalStatsHUDDef.kBarWidth) / _vMaxLife;
//   }

//   double _calculateStaminaBarWidth() {
//     return (_vCurrentStamina * PlayerVitalStatsHUDDef.kBarWidth) /
//         PlayerVitalStatsHUDDef.kMaxStamina;
//   }

//   Color _getHealthBarColor(double currentHealthBarWidth) {
//     final double _healthPercentage =
//         currentHealthBarWidth / PlayerVitalStatsHUDDef.kBarWidth;

//     if (_healthPercentage > PlayerVitalStatsHUDDef.kHealthWarningThreshold) {
//       return PlayerVitalStatsHUDDef.kHealthBarGoodColor;
//     } else if (_healthPercentage >
//         PlayerVitalStatsHUDDef.kHealthCriticalThreshold) {
//       return PlayerVitalStatsHUDDef.kHealthBarWarningColor;
//     } else {
//       return PlayerVitalStatsHUDDef.kHealthBarCriticalColor;
//     }
//   }
// }
