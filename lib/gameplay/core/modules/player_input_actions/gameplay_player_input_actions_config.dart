import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

final class GameplayPlayerInputActionsConfig {
  GameplayPlayerInputActionsConfig._();

  /// Identifiers
  static const String kJoystickPrimaryAttackId = 'primaryAttackId';
  static const String kJoystickFireballAttackId = 'fireballAttackId';
  static const LogicalKeyboardKey kKeyboardPrimaryAttack =
      LogicalKeyboardKey.space;
  static const LogicalKeyboardKey kKeyboardFireballAttack =
      LogicalKeyboardKey.keyZ;

  /// Joystick
  static const double kJoystickComponentSize = 100.0;
  static const double kActionButtonSize = 80.0;
  static const double kActionButtonMarginBottom = 50.0;
  static const double kPrimaryActionMarginRight = 50.0;
  static const double kSecondaryActionMarginRight = 160.0;

  /// Keyboard
  static final List<KeyboardDirectionalKeys> fKeyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final List<LogicalKeyboardKey> fKeyboardAcceptedKeys = [
    kKeyboardPrimaryAttack,
    kKeyboardFireballAttack,
  ];
}
