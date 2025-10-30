import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// enum PlayerActions { meleeAttack, rangedAttack }

class GameplayInputActionsConfig {
  static var isJoystickInputSelected =
      false; // TODO(Kevin): now, change this logic

  static PlayerController createPlayerInput() =>
      isJoystickInputSelected ? _createJoystickInput() : _createKeyboardInput();

  /// Identifiers
  static const String kJoystickMeleeAttackId = 'meleeAttackId';
  static const String kJoystickFireballAttackId = 'fireballAttackId';
  static const LogicalKeyboardKey kKeyboardMeleeAttack =
      LogicalKeyboardKey.space;
  static const LogicalKeyboardKey kKeyboardFireballAttack =
      LogicalKeyboardKey.keyZ;

  /// Joystick
  static const double _kJoystickComponentSize = 100.0;
  static const double _kActionButtonSize = 80.0;
  static const double _kActionButtonMarginBottom = 50.0;
  static const double _kPrimaryActionMarginRight = 50.0;
  static const double _kSecondaryActionMarginRight = 160.0;

  static PlayerController _createJoystickInput() {
    return Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: _kJoystickComponentSize,
        isFixed: false,
      ),
      actions: [_createPrimaryAttackAction(), _createRangedAttackAction()],
    );
  }

  static JoystickAction _createPrimaryAttackAction() {
    return JoystickAction(
      actionId: kJoystickMeleeAttackId,
      sprite: Sprite.load('joystick_attack.png'),
      spritePressed: Sprite.load('joystick_attack_selected.png'),
      size: _kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: _kActionButtonMarginBottom,
        right: _kPrimaryActionMarginRight,
      ),
    );
  }

  static JoystickAction _createRangedAttackAction() {
    return JoystickAction(
      actionId: kJoystickFireballAttackId,
      sprite: Sprite.load('joystick_attack_range.png'),
      spritePressed: Sprite.load('joystick_attack_range_selected.png'),
      size: _kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: _kActionButtonMarginBottom,
        right: _kSecondaryActionMarginRight,
      ),
    );
  }

  /// Keyboard
  static final List<KeyboardDirectionalKeys> _fKeyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final List<LogicalKeyboardKey> _fKeyboardAcceptedKeys = [
    kKeyboardMeleeAttack,
    kKeyboardFireballAttack,
  ];

  static PlayerController _createKeyboardInput() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: _fKeyboardDirectionalKeys,
        acceptedKeys: _fKeyboardAcceptedKeys,
      ),
    );
  }
}
