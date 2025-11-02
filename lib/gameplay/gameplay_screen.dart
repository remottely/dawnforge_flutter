import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_player_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/color_helper.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_transition_sensor.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_viewmodel.dart';
import 'package:flutter/material.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends GameplayScreenViewmodel {
  @override
  Widget build(BuildContext gameplayContext) {
    return MapNavigator(
      maps: GameplayMapManager.allMaps,
      initialMap: GameplayMapConfig.kForest1Id,
      builder: (context, arguments, mapItem) {
        final mapLightingColor = ColorHelper.fromHex(
          mapItem.properties[GameplayMapConfig.kLightingColorPropertyKey]
              ?.toString(),
        );
        final mapBackgroundColor = ColorHelper.fromHex(
          mapItem.properties[GameplayMapConfig.kBackgroundColorPropertyKey]
              ?.toString(),
        );
        final mapBackgroundMusic = mapItem
            .properties[GameplayMapConfig.kBackgroundMusicPropertyKey]
            ?.toString();
        if (mapBackgroundMusic != null && mapBackgroundMusic.isNotEmpty) {
          GameplayAudioManager.instance.playBackgroundMusic(mapBackgroundMusic);
        }

        MapArguments? mapArguments = arguments as MapArguments?;
        final playerPosition =
            (mapArguments?.playerPosition ?? Vector2.all(4)) *
            GameplayTileConfig.kTileDimensionStandard;
        final knightPlayer = buildKnightPlayer(playerPosition);

        final playerInput =
            GameplayPlayerInputActionsConfig.createPlayerInput();

        return Material(
          color: Colors.transparent,
          child: BonfireWidget(
            playerControllers: [playerInput],
            player: knightPlayer,
            map: mapItem.map,
            components: [gameplayGameStateManager],
            interface: gameplayHUD,
            lightingColorGame: mapLightingColor,
            backgroundColor: mapBackgroundColor,
            cameraConfig: cameraConfig,
            debugMode: AppEnvironment.kIsDebugMode,
            showCollisionArea: AppEnvironment.kShowCollisionBoxes,
          ),
        );
      },
    );
  }
}
