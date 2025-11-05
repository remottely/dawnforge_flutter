enum InputActionsType { keyboard, joystick }

final class SettingsManager {
  SettingsManager._();

  static final SettingsManager instance = SettingsManager._();

  InputActionsType _vIsJoystickInputSelected = InputActionsType.keyboard;
  InputActionsType get vIsJoystickInputSelected => _vIsJoystickInputSelected;
  void setInputSelected(InputActionsType newInput) {
    _vIsJoystickInputSelected = newInput;
  }
}
