import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

final class KeyboardSetup {
  KeyboardSetup._();

  // ============================================================================
  // Game Action Keys
  // ============================================================================

  /// Keyboard
  static const LogicalKeyboardKey kPrimaryActionKey = LogicalKeyboardKey.space;
  static const LogicalKeyboardKey kSecondaryActionKey = LogicalKeyboardKey.keyZ;
  static const LogicalKeyboardKey kInteractionKey = LogicalKeyboardKey.keyX;
  static const LogicalKeyboardKey kRunKey = LogicalKeyboardKey.shiftLeft;

  static final List<KeyboardDirectionalKeys> keyboardDirectionalKeys = [
    KeyboardDirectionalKeys.wasd(),
    KeyboardDirectionalKeys.arrows(),
  ];
  static final List<LogicalKeyboardKey> keyboardAcceptedKeys = [
    kPrimaryActionKey,
    kSecondaryActionKey,
    kInteractionKey,
    kRunKey,
  ];

  static PlayerController createKeyboardInput() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: keyboardDirectionalKeys,
        acceptedKeys: keyboardAcceptedKeys,
      ),
    );
  }

  // ============================================================================
  // Farm Test Action Keys
  // ============================================================================

  /// Key to till soil (prepare land for planting).
  static const LogicalKeyboardKey kTillSoilKey = LogicalKeyboardKey.keyH;

  /// Key to water crops.
  static const LogicalKeyboardKey kWaterKey = LogicalKeyboardKey.keyJ;

  /// Key to plant seeds.
  static const LogicalKeyboardKey kPlantKey = LogicalKeyboardKey.keyK;

  /// Key to harvest mature crops.
  static const LogicalKeyboardKey kHarvestKey = LogicalKeyboardKey.keyR;

  // ============================================================================
  // Farm Test Debug Keys
  // ============================================================================

  /// Debug key to advance one day (also triggers auto-save).
  static const LogicalKeyboardKey kAdvanceDayKey = LogicalKeyboardKey.keyN;

  /// Debug key to clear all save data.
  static const LogicalKeyboardKey kClearSaveKey = LogicalKeyboardKey.keyG;

  // ============================================================================
  // Inventory Test Action Keys
  // ============================================================================

  /// Key to toggle inventory UI.
  static const LogicalKeyboardKey kToggleInventoryKey = LogicalKeyboardKey.keyI;

  /// Key to add test items to inventory.
  static const LogicalKeyboardKey kAddTestItemsKey = LogicalKeyboardKey.keyT;

  /// Key to equip first weapon to weapon slot (Right Hand).
  static const LogicalKeyboardKey kEquipWeaponKey = LogicalKeyboardKey.keyE;

  /// Key to unequip weapon from weapon slot (Right Hand).
  static const LogicalKeyboardKey kUnequipWeaponKey = LogicalKeyboardKey.keyU;

  /// Key to equip first item to offhand slot (Left Hand).
  static const LogicalKeyboardKey kEquipOffhandKey = LogicalKeyboardKey.keyO;

  /// Key to unequip item from offhand slot (Left Hand).
  static const LogicalKeyboardKey kUnequipOffhandKey = LogicalKeyboardKey.keyP;
}
