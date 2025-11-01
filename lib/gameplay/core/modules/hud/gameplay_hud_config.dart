import 'package:flutter/material.dart';

final class GameplayHUDConfig {
  GameplayHUDConfig._();

  static const double kKeyIconWidth = 35.0;
  static const double kKeyIconHeight = 30.0;
  static const double kKeyIconX = 150.0;
  static const double kKeyIconY = 20.0;

  static const double kHUDPadding = 20.0;
  static const double kStrokeWidth = 12.0;
  static const double kHealthBarYPosition = 10.0;
  static const double kStaminaBarYPosition = 27.0;
  static const double kBarWidth = 90.0;
  static const double kBarXPosition = 29.0;
  static const double kMaxStamina = 100.0;
  static const double kHUDWidth = 120.0;
  static const double kHUDHeight = 40.0;
  static const int kComponentId = 1;
  static const double kHealthCriticalThreshold = 1.0 / 3.0;
  static const double kHealthWarningThreshold = 2.0 / 3.0;
  static const String kHealthUIAsset = 'health_ui.png';
  static const Color kHealthBarBackgroundColor = Color(0xFF455A64);
  static const Color kStaminaBarColor = Colors.yellow;
  static const Color kHealthBarGoodColor = Colors.green;
  static const Color kHealthBarWarningColor = Colors.yellow;
  static const Color kHealthBarCriticalColor = Colors.red;
}
