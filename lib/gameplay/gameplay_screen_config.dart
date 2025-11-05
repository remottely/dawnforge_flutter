import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_player_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/gameplay_camera_utils.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
import 'package:flutter/widgets.dart';

class GameplayScreenConfig {
  static const double kCameraSpeed = 3.0;

  static CameraConfig createCameraConfig(BuildContext context) {
    return CameraConfig(
      speed: kCameraSpeed,
      zoom: GameplayCameraUtils.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: GameplayTileConstants.kMaxVisibleTiles,
      ),
    );
  }

  static PlayerController createPlayerInput() {
    return switch (SettingsManager.instance.vIsJoystickInputSelected) {
      InputActionsType.keyboard => GameplayKeyboardConfig.createKeyboardInput(),
      InputActionsType.joystick => GameplayJoystickConfig.createJoystickInput(),
    };
  }
}
