// enum GameplayInputActionsType { keyboard, joystick }

final class GameSettingsManager {
  GameSettingsManager._();

  static final GameSettingsManager instance = GameSettingsManager._();

  bool _isJoystickInputSelected = false;
  bool get isJoystickInputSelected => _isJoystickInputSelected;
  void setInputSelected(bool newInput) {
    _isJoystickInputSelected = newInput;
  }
}
