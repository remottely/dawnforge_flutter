import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

final class GameplayJoystickConfig {
  GameplayJoystickConfig._();

  /// Assets
  static const String _kBaseAsset = 'joystick/';
  static const String _kBackgroundAsset =
      '${_kBaseAsset}joystick_background.png';
  static const String _kKnobAsset = '${_kBaseAsset}joystick_knob.png';
  static const String _kAttackAsset = '${_kBaseAsset}joystick_attack.png';
  static const String _kAttackPressedAsset =
      '${_kBaseAsset}joystick_attack_selected.png';
  static const String _kRangeAttackAsset =
      '${_kBaseAsset}joystick_attack_range.png';
  static const String _kRangeAttackPressedAsset =
      '${_kBaseAsset}joystick_attack_range_selected.png';

  /// Asset Loaders
  static Future<Sprite> _loadBackground() => Sprite.load(_kBackgroundAsset);
  static Future<Sprite> _loadKnob() => Sprite.load(_kKnobAsset);
  static Future<Sprite> _loadAttack() => Sprite.load(_kAttackAsset);
  static Future<Sprite> _loadAttackPressed() =>
      Sprite.load(_kAttackPressedAsset);
  static Future<Sprite> _loadRangeAttack() => Sprite.load(_kRangeAttackAsset);
  static Future<Sprite> _loadRangeAttackPressed() =>
      Sprite.load(_kRangeAttackPressedAsset);

  /// Identifiers
  static const String kJoystickPrimaryAttackId = 'joystickPrimaryAttackId';
  static const String kJoystickFireballAttackId = 'joystickFireballAttackId';

  /// Factories
  static const double _kJoystickComponentSize = 100.0;
  static const double kActionButtonSize = 80.0;
  static const double kActionButtonMarginBottom = 50.0;
  static const double kPrimaryActionMarginRight = 50.0;
  static const double kSecondaryActionMarginRight = 160.0;

  static PlayerController createJoystickInput() {
    return Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: _loadBackground(),
        spriteKnobDirectional: _loadKnob(),
        size: _kJoystickComponentSize,
        isFixed: false,
      ),
      actions: [_createPrimaryAttackAction(), _createRangedAttackAction()],
    );
  }

  static JoystickAction _createPrimaryAttackAction() {
    return JoystickAction(
      actionId: kJoystickPrimaryAttackId,
      sprite: _loadAttack(),
      spritePressed: _loadAttackPressed(),
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
      sprite: _loadRangeAttack(),
      spritePressed: _loadRangeAttackPressed(),
      size: kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: kActionButtonMarginBottom,
        right: kSecondaryActionMarginRight,
      ),
    );
  }
}

final class GameplayKeyboardConfig {
  GameplayKeyboardConfig._();

  /// Keyboard
  static const LogicalKeyboardKey kPrimaryAttackKey = LogicalKeyboardKey.space;
  static const LogicalKeyboardKey kFireballAttackKey = LogicalKeyboardKey.keyZ;
  static const LogicalKeyboardKey kInteractionKey = LogicalKeyboardKey.keyX;

  static final List<KeyboardDirectionalKeys> keyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final List<LogicalKeyboardKey> keyboardAcceptedKeys = [
    kPrimaryAttackKey,
    kFireballAttackKey,
  ];

  static PlayerController createKeyboardInput() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: keyboardDirectionalKeys,
        acceptedKeys: keyboardAcceptedKeys,
      ),
    );
  }
}
