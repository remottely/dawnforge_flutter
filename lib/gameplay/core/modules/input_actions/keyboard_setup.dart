import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

final class KeyboardSetup {
  KeyboardSetup._();

  // ========== CORE ACTIONS (Stardew Valley style) ==========
  /// Use tool/weapon (Space in Stardew)
  static const LogicalKeyboardKey kPrimaryActionKey = LogicalKeyboardKey.space;

  /// Secondary action (Z)
  static const LogicalKeyboardKey kSecondaryActionKey = LogicalKeyboardKey.keyV;

  /// Interact/Check/Pickup (E in Stardew, but we use for slot cycling - X for interaction)
  static const LogicalKeyboardKey kInteractionKey = LogicalKeyboardKey.keyF;

  /// Run (Shift in Stardew)
  static const LogicalKeyboardKey kRunKey = LogicalKeyboardKey.shiftLeft;

  // ========== TOOLBAR/INVENTORY (Stardew Valley style) ==========
  /// Next toolbar slot (E in Stardew)
  static const LogicalKeyboardKey kEquipMainHandKey = LogicalKeyboardKey.keyE;

  /// Previous toolbar slot (Q in Stardew)
  static const LogicalKeyboardKey kEquipMainHandReverseKey =
      LogicalKeyboardKey.keyQ;

  /// Unequip hand (U - custom)
  static const LogicalKeyboardKey kUnequipMainHandKey = LogicalKeyboardKey.keyU;

  // ========== NUMBER KEYS FOR SLOTS (Stardew Valley style) ==========
  /// Toolbar slot 1
  static const LogicalKeyboardKey kSlot1Key = LogicalKeyboardKey.digit1;

  /// Toolbar slot 2
  static const LogicalKeyboardKey kSlot2Key = LogicalKeyboardKey.digit2;

  /// Toolbar slot 3
  static const LogicalKeyboardKey kSlot3Key = LogicalKeyboardKey.digit3;

  /// Toolbar slot 4
  static const LogicalKeyboardKey kSlot4Key = LogicalKeyboardKey.digit4;

  /// Toolbar slot 5
  static const LogicalKeyboardKey kSlot5Key = LogicalKeyboardKey.digit5;

  /// Toolbar slot 6
  static const LogicalKeyboardKey kSlot6Key = LogicalKeyboardKey.digit6;

  /// Toolbar slot 7
  static const LogicalKeyboardKey kSlot7Key = LogicalKeyboardKey.digit7;

  /// Toolbar slot 8
  static const LogicalKeyboardKey kSlot8Key = LogicalKeyboardKey.digit8;

  /// Toolbar slot 9
  static const LogicalKeyboardKey kSlot9Key = LogicalKeyboardKey.digit9;

  /// Toolbar slot 10
  static const LogicalKeyboardKey kSlot10Key = LogicalKeyboardKey.digit0;

  /// Toolbar slot 11 (minus key)
  static const LogicalKeyboardKey kSlot11Key = LogicalKeyboardKey.minus;

  /// Toolbar slot 12 (equal key, shows as + on keyboard)
  static const LogicalKeyboardKey kSlot12Key = LogicalKeyboardKey.equal;

  // ========== MENUS (Stardew Valley style) ==========
  /// Open/close inventory (Tab in Stardew, E also works)
  static const LogicalKeyboardKey kToggleInventoryKey = LogicalKeyboardKey.keyI;

  /// Open crafting menu (C in Stardew - future)
  static const LogicalKeyboardKey kCraftingKey = LogicalKeyboardKey.keyC;

  /// Pause/Menu (Esc in Stardew)
  static const LogicalKeyboardKey kToggleInputsKey = LogicalKeyboardKey.escape;

  // ========== DEBUG/TESTING KEYS ==========
  /// Advance day (N - debug)
  static const LogicalKeyboardKey kAdvanceDayKey = LogicalKeyboardKey.keyN;

  /// Clear save (G - debug)
  static const LogicalKeyboardKey kClearSaveKey = LogicalKeyboardKey.keyG;

  /// Add test items (T - debug)
  static const LogicalKeyboardKey kAddTestItemsKey = LogicalKeyboardKey.keyT;

  // ========== MOVEMENT ==========
  static List<KeyboardDirectionalKeys> keyboardDirectionalKeys() => [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];

  // ========== ALL ACCEPTED KEYS ==========
  static List<LogicalKeyboardKey> keyboardAcceptedKeys() => [
    // Core actions
    kPrimaryActionKey,
    kSecondaryActionKey,
    kInteractionKey,
    kRunKey,
    // Toolbar
    kEquipMainHandKey,
    kEquipMainHandReverseKey,
    kUnequipMainHandKey,
    // Number keys for slots (Stardew style)
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
    // Menus
    kToggleInventoryKey,
    kCraftingKey,
    kToggleInputsKey,
    // Debug
    kAdvanceDayKey,
    kClearSaveKey,
    kAddTestItemsKey,
  ];

  static final PlayerController createKeyboardInput = Keyboard(
    config: KeyboardConfig(
      directionalKeys: keyboardDirectionalKeys(),
      acceptedKeys: keyboardAcceptedKeys(),
    ),
  );
}
