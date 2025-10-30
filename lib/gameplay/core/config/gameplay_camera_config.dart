import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:flutter/widgets.dart';

class GameplayCameraConfig {
  static const double kCameraSpeed = 3.0;

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
