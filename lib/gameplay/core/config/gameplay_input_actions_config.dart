import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// enum PlayerActions { meleeAttack, rangedAttack }

class GameplayInputActionsConfig {
  static var isJoystickInputSelected =
      false; // TODO(Kevin): now, change this logic

  static PlayerController buildPlayerInput() =>
      isJoystickInputSelected ? _fJoystickInput : _fKeyboardInput;

  /// Identifiers
  static const kJoystickMeleeAttackId = 'meleeAttackId';
  static const kJoystickFireballAttackId = 'fireballAttackId';
  static const kKeyboardMeleeAttack = LogicalKeyboardKey.space;
  static const kKeyboardFireballAttack = LogicalKeyboardKey.keyZ;

  /// Joystick
  static const _kJoystickComponentSize = 100.0;
  static const _kActionButtonSize = 80.0;
  static const _kActionButtonMarginBottom = 50.0;
  static const _kPrimaryActionMarginRight = 50.0;
  static const _kSecondaryActionMarginRight = 160.0;

  static final _fJoystickInput = Joystick(
    directional: JoystickDirectional(
      spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
      spriteKnobDirectional: Sprite.load('joystick_knob.png'),
      size: _kJoystickComponentSize,
      isFixed: false,
    ),
    actions: [_fPrimaryAttackAction, _fRangedAttackAction],
  );

  static final _fPrimaryAttackAction = JoystickAction(
    actionId: kJoystickMeleeAttackId,
    sprite: Sprite.load('joystick_attack.png'),
    spritePressed: Sprite.load('joystick_attack_selected.png'),
    size: _kActionButtonSize,
    margin: const EdgeInsets.only(
      bottom: _kActionButtonMarginBottom,
      right: _kPrimaryActionMarginRight,
    ),
  );

  static final _fRangedAttackAction = JoystickAction(
    actionId: kJoystickFireballAttackId,
    sprite: Sprite.load('joystick_attack_range.png'),
    spritePressed: Sprite.load('joystick_attack_range_selected.png'),
    size: _kActionButtonSize,
    margin: const EdgeInsets.only(
      bottom: _kActionButtonMarginBottom,
      right: _kSecondaryActionMarginRight,
    ),
  );

  /// Keyboard
  static final _fKeyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final _fKeyboardAcceptedKeys = [
    kKeyboardMeleeAttack,
    kKeyboardFireballAttack,
  ];

  static final _fKeyboardInput = Keyboard(
    config: KeyboardConfig(
      directionalKeys: _fKeyboardDirectionalKeys,
      acceptedKeys: _fKeyboardAcceptedKeys,
    ),
  );
}
