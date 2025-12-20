import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/color_helper.dart';
import 'package:darkness_dungeon/gameplay/decorations/map_transition_sensor.dart';
import 'package:darkness_dungeon/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_def.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_viewmodel.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/equipment_overlay.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_debug_hud.dart';
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
      initialMap: MapDef.kFarmId,
      builder: (context, arguments, mapItem) {
        final mapLightingColor = ColorHelper.fromHex(
          mapItem.properties[MapDef.kLightingColorPropertyKey]?.toString(),
        );
        final mapBackgroundColor = ColorHelper.fromHex(
          mapItem.properties[MapDef.kBackgroundColorPropertyKey]?.toString(),
        );
        final mapBackgroundMusic = mapItem
            .properties[MapDef.kBackgroundMusicPropertyKey]
            ?.toString();

        if (mapBackgroundMusic != null &&
            mapBackgroundMusic.isNotEmpty &&
            _lastRequestedMusic != mapBackgroundMusic) {
          _lastRequestedMusic = mapBackgroundMusic;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AudioManager.instance.playBackgroundMusic(mapBackgroundMusic);
          });
        }

        final mapArguments = arguments as MapArguments?;
        final playerPosition =
            (mapArguments?.playerPosition ?? Vector2(24, 24)) *
            TileDef.kTileDimensionStandard;

        // final player = buildSunnyPlayer(playerPosition);
        // final player = buildCutePlayer(playerPosition);
        final player = buildFarmerPlayer(playerPosition);

        playerInput = GameplayScreenDef.createPlayerInput();

        farmInputHandler = FarmInputHandler(player: player);

        return Stack(
          children: [
            BonfireWidget(
              playerControllers: [playerInput],
              player: player,
              map: mapItem.map,
              components: [
                gameplayGameStateManager,
                inventoryInputHandler,
                shieldDefenseInputHandler,
                farmInputHandler,
              ],
              hudComponents: [
                DDDebugHud(
                  showFps: true,
                  showPosition: true,
                  showEntities: true,
                ),
              ],
              interface: gameplayHUD,
              lightingColorGame: mapLightingColor,
              // backgroundColor: mapBackgroundColor, // TODO(Kevin): put it back?
              overlayBuilderMap: {},
              backgroundColor: const Color(0xFF000000),
              cameraConfig: cameraConfig,
              debugMode: AppEnvironment.kIsDebugMode,
              showCollisionArea: AppEnvironment.kShowCollisionBoxes,
            ),
            // Flutter Equipment Overlay - inside MapNavigator builder
            const EquipmentOverlay(),
          ],
        );
      },
    );
  }
}
