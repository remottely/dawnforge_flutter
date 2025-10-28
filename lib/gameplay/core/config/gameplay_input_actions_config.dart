import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// enum PlayerActions { meleeAttack, rangedAttack }

class GameplayInputActionsConfig {
  static var isJoystickInputSelected =
      false; // TODO(Kevin): now, change this logic

  static PlayerController createPlayerInput() {
    return isJoystickInputSelected
        ? _createJoystickInput()
        : _createKeyboardInput();
  }

  /// Joystick
  static const joystickMeleeAttack = 'space';
  static const joystickFireballAttack = 'keyZ';

  static const _kJoystickComponentSize = 100.0;
  static const _kActionButtonSize = 80.0;
  static const _kActionButtonMarginBottom = 50.0;
  static const _kPrimaryActionMarginRight = 50.0;
  static const _kSecondaryActionMarginRight = 160.0;

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
      actionId: joystickMeleeAttack,
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
      actionId: joystickFireballAttack,
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
  static const keyboardMeleeAttack = LogicalKeyboardKey.space;
  static const keyboardFireballAttack = LogicalKeyboardKey.keyZ;

  static final _keyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final _keyboardAcceptedKeys = [
    keyboardMeleeAttack,
    keyboardFireballAttack,
  ];

  static PlayerController _createKeyboardInput() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: _keyboardDirectionalKeys,
        acceptedKeys: _keyboardAcceptedKeys,
      ),
    );
  }
}
