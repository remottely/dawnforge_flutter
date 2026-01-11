import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/game/tile_constants.dart';
import 'package:flutter/widgets.dart';

final class CameraCalculations {
  CameraCalculations._();

  static double getCameraZoomFromMaxVisibleTile(
    BuildContext context, {
    required int maxVisibleTile,
  }) {
    return getZoomFromMaxVisibleTile(
      context,
      TileConstants.kTileDimensionStandard,
      maxVisibleTile,
    );
  }
}
