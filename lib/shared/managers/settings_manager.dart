import 'package:flutter/foundation.dart';

enum InputActionsType { keyboard, joystick }

final class SettingsManager {
  SettingsManager._();

  static final SettingsManager instance = SettingsManager._();

  InputActionsType _inputSelected = kIsWeb
      ? InputActionsType.keyboard
      : InputActionsType.joystick;
      
  InputActionsType get inputSelected => _inputSelected;

  void setInputSelected(InputActionsType value) {
    _inputSelected = value;
  }
}
