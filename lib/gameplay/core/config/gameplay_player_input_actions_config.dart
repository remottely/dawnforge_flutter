import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

final class GameplayPlayerInputActionsConfig {
  GameplayPlayerInputActionsConfig._();

  /// Identifiers
  static const String kJoystickPrimaryAttackId = 'joystickPrimaryAttackId';
  static const String kJoystickFireballAttackId = 'joystickFireballAttackId';
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

  /// Factories
  static PlayerController createPlayerInput(
    InputActionsType isJoystickInputSelected,
  ) {
    return switch (SettingsManager.instance.vIsJoystickInputSelected) {
      InputActionsType.keyboard => _createKeyboardInput(),
      InputActionsType.joystick => _createJoystickInput(),
    };
  }

  static PlayerController _createJoystickInput() {
    return Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: kJoystickComponentSize,
        isFixed: false,
      ),
      actions: [_createPrimaryAttackAction(), _createRangedAttackAction()],
    );
  }

  static JoystickAction _createPrimaryAttackAction() {
    return JoystickAction(
      actionId: kJoystickPrimaryAttackId,
      sprite: Sprite.load('joystick_attack.png'),
      spritePressed: Sprite.load('joystick_attack_selected.png'),
      size: kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: kActionButtonMarginBottom,
        right: kPrimaryActionMarginRight,
      ),
    );
  }

  static JoystickAction _createRangedAttackAction() {
    return JoystickAction(
      actionId: kJoystickFireballAttackId,
      sprite: Sprite.load('joystick_attack_range.png'),
      spritePressed: Sprite.load('joystick_attack_range_selected.png'),
      size: kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: kActionButtonMarginBottom,
        right: kSecondaryActionMarginRight,
      ),
    );
  }

  static PlayerController _createKeyboardInput() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: fKeyboardDirectionalKeys,
        acceptedKeys: fKeyboardAcceptedKeys,
      ),
    );
  }
}
