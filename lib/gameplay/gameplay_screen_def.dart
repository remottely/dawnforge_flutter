import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_calculations.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/input_def.dart';

import 'package:flutter/widgets.dart';

class GameplayScreenDef {
  static const double kCameraSpeed = 3.0;

  static CameraConfig createCameraConfig(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final calculatedZoom = CameraCalculations.getCameraZoomFromMaxVisibleTile(
      context,
      maxVisibleTile: TileConstants.kMaxVisibleTiles,
    );

    final pixelPerfectZoom = calculatedZoom.roundToDouble();

    return CameraConfig(
      speed: double
          .infinity, // TODO(Kevin): colocar de volta caso cause serrilhados no jogo
      zoom: pixelPerfectZoom,
      resolution: Vector2(size.width, size.height),
      moveOnlyMapArea: true,
    );
  }

  static PlayerController createPlayerInput() => InputDef.create();
}
