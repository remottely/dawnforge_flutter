import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_calculations.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
import 'package:flutter/widgets.dart';

class GameplayScreenDef {
  static const double kCameraSpeed = 3.0;

  static CameraConfig createCameraConfig(BuildContext context) {
    return CameraConfig(
      speed: kCameraSpeed,
      zoom: CameraCalculations.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: TileConstants.kMaxVisibleTiles,
      ),
    );
  }

  static PlayerController createPlayerInput() {
    return switch (SettingsManager.instance.vIsJoystickInputSelected) {
      InputActionsType.keyboard => KeyboardSetup.createKeyboardInput(),
      InputActionsType.joystick => JoystickSetup.createJoystickInput(),
    };
  }
}
