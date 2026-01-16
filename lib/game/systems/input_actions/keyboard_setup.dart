import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

final class KeyboardSetup {
  KeyboardSetup._();

  // TODO(Kevin): Review key mappings to better match SV
  // Access Menu: keyE
  // Access Journal: keyF
  // Access Map: keyM
  // Chat Box: Question, keyT
  // Emote Menu: keyY
  // Shift Toolbar: tab

  static const LogicalKeyboardKey kPrimaryActionKey = LogicalKeyboardKey.keyC;

  static const LogicalKeyboardKey kInteractionKey = LogicalKeyboardKey.keyX;

  static const LogicalKeyboardKey kRunKey = LogicalKeyboardKey.shiftLeft;

  static const LogicalKeyboardKey kSlotNavNextKey = LogicalKeyboardKey.keyE;

  static const LogicalKeyboardKey kSlotNavPrevKey = LogicalKeyboardKey.keyQ;

  static const LogicalKeyboardKey kSlot1Key = LogicalKeyboardKey.digit1;

  static const LogicalKeyboardKey kSlot2Key = LogicalKeyboardKey.digit2;

  static const LogicalKeyboardKey kSlot3Key = LogicalKeyboardKey.digit3;

  static const LogicalKeyboardKey kSlot4Key = LogicalKeyboardKey.digit4;

  static const LogicalKeyboardKey kSlot5Key = LogicalKeyboardKey.digit5;

  static const LogicalKeyboardKey kSlot6Key = LogicalKeyboardKey.digit6;

  static const LogicalKeyboardKey kSlot7Key = LogicalKeyboardKey.digit7;

  static const LogicalKeyboardKey kSlot8Key = LogicalKeyboardKey.digit8;

  static const LogicalKeyboardKey kSlot9Key = LogicalKeyboardKey.digit9;

  static const LogicalKeyboardKey kSlot10Key = LogicalKeyboardKey.digit0;

  static const LogicalKeyboardKey kSlot11Key = LogicalKeyboardKey.minus;

  static const LogicalKeyboardKey kSlot12Key = LogicalKeyboardKey.equal;

  static const LogicalKeyboardKey kToggleInventoryKey = LogicalKeyboardKey.keyI;

  static const LogicalKeyboardKey kCraftingKey = LogicalKeyboardKey.keyV;

  static const LogicalKeyboardKey kToggleInputsKey = LogicalKeyboardKey.escape;

  static const LogicalKeyboardKey kAdvanceDayKey = LogicalKeyboardKey.keyN;

  static const LogicalKeyboardKey kClearSaveKey = LogicalKeyboardKey.keyG;

  static const LogicalKeyboardKey kAddTestItemsKey = LogicalKeyboardKey.keyT;

  static List<KeyboardDirectionalKeys> keyboardDirectionalKeys() => [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];

  static List<LogicalKeyboardKey> keyboardAcceptedKeys() => [
    kPrimaryActionKey,
    kInteractionKey,
    kRunKey,

    kSlotNavNextKey,
    kSlotNavPrevKey,

    kSlot1Key,
    kSlot2Key,
    kSlot3Key,
    kSlot4Key,
    kSlot5Key,
    kSlot6Key,
    kSlot7Key,
    kSlot8Key,
    kSlot9Key,
    kSlot10Key,
    kSlot11Key,
    kSlot12Key,

    kToggleInventoryKey,
    kCraftingKey,
    kToggleInputsKey,

    kAdvanceDayKey,
    kClearSaveKey,
    kAddTestItemsKey,
  ];

  static PlayerController createInput() => Keyboard(
    config: KeyboardConfig(
      directionalKeys: keyboardDirectionalKeys(),
      acceptedKeys: keyboardAcceptedKeys(),
    ),
  );
}
