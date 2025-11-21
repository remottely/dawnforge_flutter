import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

final class PlayerVitalStatsHUDConfig {
  PlayerVitalStatsHUDConfig._();

  /// Component settings
  static const double _kHUDPadding = 20.0;
  static const double _kHUDWidth = 120.0;
  static const double _kHUDHeight = 40.0;

  /// Bar dimensions
  static const double kBarXPosition = 29.0;
  static const double kBarWidth = 90.0;
  static const double kStrokeWidth = 12.0;

  /// Health bar
  static const double kHealthBarYPosition = 10.0;
  static const Color kHealthBarBackgroundColor = Color(0xFF455A64);
  static const Color kHealthBarGoodColor = Colors.green;
  static const Color kHealthBarWarningColor = Colors.yellow;
  static const Color kHealthBarCriticalColor = Colors.red;
  static const double kHealthCriticalThreshold = 1.0 / 3.0;
  static const double kHealthWarningThreshold = 2.0 / 3.0;

  /// Stamina bar
  static const double kStaminaBarYPosition = 27.0;
  static const Color kStaminaBarColor = Colors.yellow;
  static const double kMaxStamina = 100.0;

  /// Component
  static const int kComponentId = 1;
  static final Vector2 componentSize = Vector2(_kHUDWidth, _kHUDHeight);
  static final Vector2 componentPosition = Vector2.all(_kHUDPadding);

  /// Factory methods
  static Future<Sprite> loadHealthUISprite() =>
      Sprite.load('hud/health_ui.png');
}
