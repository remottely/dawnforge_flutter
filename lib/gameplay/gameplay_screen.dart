import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/color_helper.dart';
import 'package:darkness_dungeon/gameplay/decorations/map_transition_sensor.dart';
import 'package:darkness_dungeon/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_config.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_viewmodel.dart';
import 'package:flutter/material.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends GameplayScreenViewmodel {
  String? _lastRequestedMusic;

  @override
  Widget build(BuildContext gameplayContext) {
    if (isLoadingSave) {
      return const Material(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return MapNavigator(
      maps: MapManager.allMaps,
      // initialMap: MapConfig.kFarmId,
      initialMap: MapConfig.kFarmTestId,
      builder: (context, arguments, mapItem) {
        final mapLightingColor = ColorHelper.fromHex(
          mapItem.properties[MapConfig.kLightingColorPropertyKey]?.toString(),
        );
        final mapBackgroundColor = ColorHelper.fromHex(
          mapItem.properties[MapConfig.kBackgroundColorPropertyKey]?.toString(),
        );
        final mapBackgroundMusic = mapItem
            .properties[MapConfig.kBackgroundMusicPropertyKey]
            ?.toString();

        if (mapBackgroundMusic != null &&
            mapBackgroundMusic.isNotEmpty &&
            _lastRequestedMusic != mapBackgroundMusic) {
          _lastRequestedMusic = mapBackgroundMusic;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AudioManager.instance.playBackgroundMusic(mapBackgroundMusic);
          });
        }

        MapArguments? mapArguments = arguments as MapArguments?;
        final playerPosition =
            (mapArguments?.playerPosition ?? Vector2(2, 1)) *
            TileConstants.kTileDimensionStandard;

        // final player = buildSunnyPlayer(playerPosition);
        // final player = buildCutePlayer(playerPosition);
        final player = buildFarmerPlayer(playerPosition);

        playerInput = GameplayScreenConfig.createPlayerInput();

        farmInputHandler = FarmInputHandler(player: player);

        return Material(
          color: Colors.transparent,
          child: BonfireWidget(
            playerControllers: [playerInput],
            player: player,
            map: mapItem.map,
            components: [
              gameplayGameStateManager,
              inventoryInputHandler,
              shieldDefenseInputHandler,
              farmInputHandler,
            ],
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
