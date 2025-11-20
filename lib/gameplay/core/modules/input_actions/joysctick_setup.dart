import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

final class JoystickSetup {
  JoystickSetup._();

  /// Assets
  static const String _kBasePath = 'joystick/';
  static const String _kBackgroundAsset =
      '${_kBasePath}joystick_background.png';
  static const String _kKnobAsset = '${_kBasePath}joystick_knob.png';
  static const String _kMeleeAttackUpAsset =
      '${_kBasePath}joystick_melee_attack_up.png';
  static const String _kMeleeAttackDownAsset =
      '${_kBasePath}joystick_melee_attack_down.png';
  static const String _kRangedAttackUpAsset =
      '${_kBasePath}joystick_ranged_attack_up.png';
  static const String _kRangedAttackDownAsset =
      '${_kBasePath}joystick_ranged_attack_down.png';

  /// Asset Loaders
  static Future<Sprite> _loadBackground() => Sprite.load(_kBackgroundAsset);
  static Future<Sprite> _loadKnob() => Sprite.load(_kKnobAsset);
  static Future<Sprite> _loadMeleeAttackUp() =>
      Sprite.load(_kMeleeAttackUpAsset);
  static Future<Sprite> _loadMeleeAttackDown() =>
      Sprite.load(_kMeleeAttackDownAsset);
  static Future<Sprite> _loadRangedAttackUp() =>
      Sprite.load(_kRangedAttackUpAsset);
  static Future<Sprite> _loadRangedAttackDown() =>
      Sprite.load(_kRangedAttackDownAsset);

  /// Identifiers
  static const String kPrimaryAttackId = 'primaryAttackId';
  static const String kFireballAttackId = 'fireballAttackId';
  static const String kRunId = 'runId';

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
      actionId: kPrimaryAttackId,
      sprite: _loadMeleeAttackUp(),
      spritePressed: _loadMeleeAttackDown(),
      size: kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: kActionButtonMarginBottom,
        right: kPrimaryActionMarginRight,
      ),
    );
  }

  static JoystickAction _createRangedAttackAction() {
    return JoystickAction(
      actionId: kFireballAttackId,
      sprite: _loadRangedAttackUp(),
      spritePressed: _loadRangedAttackDown(),
      size: kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: kActionButtonMarginBottom,
        right: kSecondaryActionMarginRight,
      ),
    );
  }
}
