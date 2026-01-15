import 'package:dawnforge/game/utils/app_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum InputActionsType { keyboard, joystick }

final class SettingsManager {
  SettingsManager._();

  static final instance = SettingsManager._();

  InputActionsType _inputSelected =
      // kIsWeb
      //     ? InputActionsType.keyboard
      //     :
      AppEnvironment.kIsDevToolsMode
      ? InputActionsType.keyboard
      : InputActionsType.joystick;

  InputActionsType get inputSelected => _inputSelected;

  void setInputSelected(InputActionsType value) {
    _inputSelected = value;
    _updateOrientation();
  }

  /// Force landscape orientation when using joystick on mobile
  void _updateOrientation() {
    if (_inputSelected == InputActionsType.joystick && !kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Allow all orientations for keyboard mode
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  /// Call this on app initialization to set the correct orientation
  Future<void> initializeOrientation() async {
    _updateOrientation();
  }
}
