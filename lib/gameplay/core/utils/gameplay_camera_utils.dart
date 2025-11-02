import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_config.dart';
import 'package:flutter/widgets.dart';

final class GameplayCameraUtils {
  GameplayCameraUtils._();

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
