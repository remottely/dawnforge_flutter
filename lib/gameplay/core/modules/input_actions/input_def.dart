import 'package:bonfire/input/player_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';

final class InputDef {
  const InputDef._();

  static PlayerController create() =>
      switch (SettingsManager.instance.inputSelected) {
        InputActionsType.keyboard => KeyboardSetup.createKeyboardInput,
        InputActionsType.joystick => JoystickSetup.createJoystickInput,
      };

  static bool isPrimaryAction(dynamic actionId) {
    return actionId == JoystickSetup.kPrimaryActionId ||
        actionId == KeyboardSetup.kPrimaryActionKey;
  }

  static bool isSecondaryAction(dynamic actionId) {
    return actionId == JoystickSetup.kSecondaryActionId ||
        actionId == KeyboardSetup.kSecondaryActionKey;
  }

  static bool isRunAction(dynamic actionId) {
    return actionId == JoystickSetup.kRunId ||
        actionId == KeyboardSetup.kRunKey;
  }

  static bool isInteractionAction(dynamic actionId) {
    return actionId == JoystickSetup.kInteractionId ||
        actionId == KeyboardSetup.kInteractionKey;
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
    return actionId == JoystickSetup.kEquipMainHandId ||
        actionId == KeyboardSetup.kEquipMainHandKey;
  }

  static bool isEquipMainHandReverseAction(dynamic actionId) {
    return actionId == JoystickSetup.kEquipMainHandReverseId ||
        actionId == KeyboardSetup.kEquipMainHandReverseKey;
  }

  static bool isUnequipMainHandAction(dynamic actionId) {
    return actionId == JoystickSetup.kUnequipMainHandId ||
        actionId == KeyboardSetup.kUnequipMainHandKey;
  }

  static bool isEquipOffhandAction(dynamic actionId) {
    return actionId == JoystickSetup.kEquipOffhandId ||
        actionId == KeyboardSetup.kEquipOffhandKey;
  }

  static bool isEquipOffhandReverseAction(dynamic actionId) {
    return actionId == JoystickSetup.kEquipOffhandReverseId ||
        actionId == KeyboardSetup.kEquipOffhandReverseKey;
  }

  static bool isUnequipOffhandAction(dynamic actionId) {
    return actionId == JoystickSetup.kUnequipOffhandId ||
        actionId == KeyboardSetup.kUnequipOffhandKey;
  }

  static bool isAddTestItemsAction(dynamic actionId) {
    return actionId == JoystickSetup.kAddTestItemsId ||
        actionId == KeyboardSetup.kAddTestItemsKey;
  }
}
