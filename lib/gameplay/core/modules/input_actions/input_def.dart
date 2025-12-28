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

  static bool isAdvanceDayAction(dynamic actionId) {
    return actionId == KeyboardSetup.kAdvanceDayKey;
  }

  static bool isClearSaveAction(dynamic actionId) {
    return actionId == KeyboardSetup.kClearSaveKey;
  }
}
