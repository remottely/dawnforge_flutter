import 'package:bonfire/input/player_controller.dart';
import 'package:dawnforge/game/systems/input_actions/joysctick_setup.dart';
import 'package:dawnforge/game/systems/input_actions/keyboard_setup.dart';
import 'package:dawnforge/core/managers/settings_manager.dart';

final class InputDef {
  const InputDef._();

  static PlayerController create() =>
      switch (SettingsManager.instance.inputSelected) {
        InputActionsType.keyboard => KeyboardSetup.createInput(),
        InputActionsType.joystick => JoystickSetup.createInput(),
      };

  static bool isPrimaryAction(dynamic actionId) {
    final isPrimary =
        actionId == JoystickSetup.kPrimaryActionId ||
        actionId == KeyboardSetup.kPrimaryActionKey;

    return isPrimary;
  }

  static bool isInteractionAction(dynamic actionId) {
    return actionId == JoystickSetup.kInteractionId ||
        actionId == KeyboardSetup.kInteractionKey;
  }

  static bool isRunAction(dynamic actionId) {
    return actionId == JoystickSetup.kRunId ||
        actionId == KeyboardSetup.kRunKey;
  }

  static bool isAdvanceDayAction(dynamic actionId) {
    return actionId == JoystickSetup.kAdvanceDayId ||
        actionId == KeyboardSetup.kAdvanceDayKey;
  }

  static bool isClearSaveAction(dynamic actionId) {
    return actionId == JoystickSetup.kClearSaveId ||
        actionId == KeyboardSetup.kClearSaveKey;
  }

  static bool isToggleInventoryAction(dynamic actionId) {
    return actionId == JoystickSetup.kToggleInventoryId ||
        actionId == KeyboardSetup.kToggleInventoryKey;
  }

  static bool isToggleTutorialInputsAction(dynamic actionId) {
    return actionId == JoystickSetup.kToggleTutorialInputsId ||
        actionId == KeyboardSetup.kToggleInputsKey;
  }

  static bool isEquipMainHandAction(dynamic actionId) {
    return actionId == JoystickSetup.kSlotNavNextId ||
        actionId == KeyboardSetup.kSlotNavNextKey;
  }

  static bool isEquipMainHandReverseAction(dynamic actionId) {
    return actionId == JoystickSetup.kSlotNavPrevId ||
        actionId == KeyboardSetup.kSlotNavPrevKey;
  }

  static bool isAddTestItemsAction(dynamic actionId) {
    return actionId == JoystickSetup.kAddTestItemsId ||
        actionId == KeyboardSetup.kAddTestItemsKey;
  }

  // ========== TOOLBAR SLOT SELECTION (SV style) ==========
  static int? getToolbarSlotNumber(dynamic actionId) {
    if (actionId == KeyboardSetup.kSlot1Key) return 0;
    if (actionId == KeyboardSetup.kSlot2Key) return 1;
    if (actionId == KeyboardSetup.kSlot3Key) return 2;
    if (actionId == KeyboardSetup.kSlot4Key) return 3;
    if (actionId == KeyboardSetup.kSlot5Key) return 4;
    if (actionId == KeyboardSetup.kSlot6Key) return 5;
    if (actionId == KeyboardSetup.kSlot7Key) return 6;
    if (actionId == KeyboardSetup.kSlot8Key) return 7;
    if (actionId == KeyboardSetup.kSlot9Key) return 8;
    if (actionId == KeyboardSetup.kSlot10Key) return 9;
    if (actionId == KeyboardSetup.kSlot11Key) return 10;
    if (actionId == KeyboardSetup.kSlot12Key) return 11;
    return null;
  }

  static bool isCraftingAction(dynamic actionId) {
    return actionId == KeyboardSetup.kCraftingKey;
  }

  static bool isConsumeAction(dynamic actionId) => isPrimaryAction(actionId);
  static bool isDefenseAction(dynamic actionId) =>
      isInteractionAction(actionId);
}
