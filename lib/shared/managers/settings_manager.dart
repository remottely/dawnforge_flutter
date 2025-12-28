enum InputActionsType { keyboard, joystick }

final class SettingsManager {
  SettingsManager._();

  static final SettingsManager instance = SettingsManager._();

  InputActionsType _inputSelected = InputActionsType.keyboard;
  InputActionsType get inputSelected => _inputSelected;

  void setInputSelected(InputActionsType value) {
    _inputSelected = value;
  }
}
