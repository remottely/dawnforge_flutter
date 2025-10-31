import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_camera_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_map_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/data/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/core/hud/gameplay_hud.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/color_helper.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_transition_sensor.dart';
import 'package:flutter/material.dart';

class Gameplay extends StatefulWidget {
  const Gameplay({super.key});

  @override
  State<Gameplay> createState() => _GameplayState();
}

abstract class GameplayViewmodel extends State<Gameplay> {
  late final GameplayHUD _gameplayHUD;
  late final CameraConfig _cameraConfig;

  @override
  void initState() {
    super.initState();
    _initializeGameComponents();
  }

  @override
  void dispose() {
    _cleanupGameAudio();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cameraConfig = CameraConfig(
      speed: GameplayCameraConfig.kCameraSpeed,
      zoom: GameplayCameraConfig.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: GameplayTileConfig.kMaxVisibleTiles,
      ),
    );
  }

  void _cleanupGameAudio() {
    GameplayAudioManager.instance.stopBackgroundMusic();
  }

  void _initializeGameComponents() {
    _gameplayHUD = GameplayHUD();
  }

  KnightPlayerView _buildKnightPlayer(Vector2 position) =>
      KnightPlayerView(position);
}

class _GameplayState extends GameplayViewmodel {
  @override
  Widget build(BuildContext gameplayContext) {
    return MapNavigator(
      maps: GameplayMapManager.fAllMaps,
      initialMap: MapId.map1.name,
      builder: (context, arguments, mapItem) {
        MapArguments? mapArguments = arguments as MapArguments?;
        final playerPosition =
            (mapArguments?.playerPosition ?? Vector2(4, 4)) *
            GameplayTileConfig.kTileDimensionStandard;

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

        final knightPlayer = _buildKnightPlayer(playerPosition);

        final playerInput = GameplayInputActionsConfig.createPlayerInput();

        return Material(
          color: Colors.transparent,
          child: BonfireWidget(
            playerControllers: [playerInput],
            player: knightPlayer,
            map: mapItem.map,
            components: [GameplayStateManager()],
            interface: _gameplayHUD,
            lightingColorGame: mapLightingColor,
            backgroundColor: mapBackgroundColor,
            cameraConfig: _cameraConfig,
            debugMode: AppEnvironment.kIsDebugMode,
            showCollisionArea: AppEnvironment.kShowCollisionBoxes,
          ),
        );
      },
    );
  }
}
