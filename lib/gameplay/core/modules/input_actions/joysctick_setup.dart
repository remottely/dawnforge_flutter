import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

final class JoystickSetup {
  JoystickSetup._();

  /// Assets
  static const String _kBasePath = 'joystick/';
  static const String _kBackgroundAsset =
      '${_kBasePath}joystick_background.png';
  static const String _kKnobAsset = '${_kBasePath}joystick_knob.png';
  // static const String _kMeleeAttackDefaultAsset =
  //     '${_kBasePath}joystick_melee_attack_default.png';
  // static const String _kMeleeAttackPressedAsset =
  //     '${_kBasePath}joystick_melee_attack_pressed.png';
  // static const String _kRangedAttackDefaultAsset =
  //     '${_kBasePath}joystick_ranged_attack_default.png';
  // static const String _kRangedAttackPressedAsset =
  //     '${_kBasePath}joystick_ranged_attack_pressed.png';

  /// Asset Loaders
  static final Future<Sprite> _loadBackground = Sprite.load(_kBackgroundAsset);
  static final Future<Sprite> _loadKnob = Sprite.load(_kKnobAsset);
  // static final Future<Sprite> _loadMeleeAttackDefault = Sprite.load(
  //   _kMeleeAttackDefaultAsset,
  // );
  // static final Future<Sprite> _loadMeleeAttackPressed = Sprite.load(
  //   _kMeleeAttackPressedAsset,
  // );
  // static final Future<Sprite> _loadRangedAttackDefault = Sprite.load(
  //   _kRangedAttackDefaultAsset,
  // );
  // static final Future<Sprite> _loadRangedAttackPressed = Sprite.load(
  //   _kRangedAttackPressedAsset,
  // );

  /// Identifiers
  static const String kPrimaryActionId = 'primaryActionId';
  static const String kInteractionId = 'interactionId';
  static const String kRunId = 'runId';
  static const String kSlotNavNextId = 'equipMainHandId';
  static const String kSlotNavPrevId = 'equipMainHandReverseId';
  static const String kToggleInventoryId = 'toggleInventoryId';
  static const String kToggleTutorialInputsId = 'toggleTutorialInputsId';

  /// Testing Identifiers
  // static const String kAdvanceDayId = 'advanceDayId';
  static const String kClearSaveId = 'clearSaveId';
  static const String kAddTestItemsId = 'addTestItemsId';

  /// Factories
  static const double _kJoystickComponentSize = 100.0;
  static const double kActionButtonSize = 80.0;
  // static const double kActionButtonMarginBottom = 50.0;
  static const double kDirectionalMargin = 0.0;
  static const double kActionButtonMarginBottom = 4.0;
  static const double kPrimaryActionMarginRight = 4.0;
  static const double kSecondaryActionMarginRight = 100.0;

  static PlayerController createJoystickInput() => Joystick(
    directional: JoystickDirectional(
      spriteBackgroundDirectional: _loadBackground,
      spriteKnobDirectional: _loadKnob,
      size: _kJoystickComponentSize,
      isFixed: false,
      margin: EdgeInsets.all(kDirectionalMargin),
      alignment: Alignment.center, // Permite uso em toda a tela
    ),
    // actions: [_createPrimaryAttackAction(), _createRangedAttackAction()],
  );

  // static JoystickAction _createPrimaryAttackAction() {
  //   return JoystickAction(
  //     actionId: kPrimaryActionId,
  //     sprite: _loadMeleeAttackDefault,
  //     spritePressed: _loadMeleeAttackPressed,
  //     size: kActionButtonSize,
  //     margin: const EdgeInsets.only(
  //       bottom: kActionButtonMarginBottom,
  //       right: kPrimaryActionMarginRight,
  //     ),
  //   );
  // }

  // static JoystickAction _createRangedAttackAction() {
  //   return JoystickAction(
  //     actionId: kSecondaryActionId,
  //     sprite: _loadRangedAttackDefault,
  //     spritePressed: _loadRangedAttackPressed,
  //     size: kActionButtonSize,
  //     margin: const EdgeInsets.only(
  //       bottom: kActionButtonMarginBottom,
  //       right: kSecondaryActionMarginRight,
  //     ),
  //   );
  // }
}
