import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:flutter/widgets.dart';

class GameplayCameraUtils {
  static const double kCameraSpeed = 3.0;

  static CameraConfig createCameraConfig(BuildContext context) {
    return CameraConfig(
      speed: GameplayCameraUtils.kCameraSpeed,
      zoom: GameplayCameraUtils.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: GameplayTileConfig.kMaxVisibleTiles,
      ),
    );
  }

  static double getCameraZoomFromMaxVisibleTile(
    BuildContext context, {
    required int maxVisibleTile,
  }) {
    return getZoomFromMaxVisibleTile(
      context,
      GameplayTileConfig.kTileDimensionStandard,
      maxVisibleTile,
    );
  }
}
