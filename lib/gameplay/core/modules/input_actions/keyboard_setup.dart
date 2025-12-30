import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

final class KeyboardSetup {
  KeyboardSetup._();

  static const LogicalKeyboardKey kPrimaryActionKey = LogicalKeyboardKey.space;
  static const LogicalKeyboardKey kSecondaryActionKey = LogicalKeyboardKey.keyZ;
  static const LogicalKeyboardKey kInteractionKey = LogicalKeyboardKey.keyX;
  static const LogicalKeyboardKey kRunKey = LogicalKeyboardKey.shiftLeft;
  static const LogicalKeyboardKey kEquipMainHandKey = LogicalKeyboardKey.keyE;
  static const LogicalKeyboardKey kEquipMainHandReverseKey =
      LogicalKeyboardKey.keyQ;

  static final List<KeyboardDirectionalKeys> keyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final List<LogicalKeyboardKey> keyboardAcceptedKeys = [
    kPrimaryActionKey,
    kSecondaryActionKey,
    kInteractionKey,
    kRunKey,
    kEquipMainHandKey,
    kEquipMainHandReverseKey,
    kUnequipMainHandKey,
    kAdvanceDayKey,
    kClearSaveKey,
    kToggleInputsKey,
    kToggleInventoryKey,
    kAddTestItemsKey,
  ];

  static PlayerController createKeyboardInput() => Keyboard(
    config: KeyboardConfig(
      directionalKeys: keyboardDirectionalKeys,
      acceptedKeys: keyboardAcceptedKeys,
    ),
  );

  /// TESTING KEYS
  static const LogicalKeyboardKey kAdvanceDayKey = LogicalKeyboardKey.keyN;

  static const LogicalKeyboardKey kClearSaveKey = LogicalKeyboardKey.keyG;

  static const LogicalKeyboardKey kToggleInputsKey = LogicalKeyboardKey.escape;

  static const LogicalKeyboardKey kToggleInventoryKey = LogicalKeyboardKey.keyI;

  static const LogicalKeyboardKey kAddTestItemsKey = LogicalKeyboardKey.keyT;

  static const LogicalKeyboardKey kUnequipMainHandKey = LogicalKeyboardKey.keyU;
}
