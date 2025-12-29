import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/color_helper.dart';
import 'package:darkness_dungeon/gameplay/decorations/map_transition_sensor.dart';
import 'package:darkness_dungeon/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/inputs/widgets/mobile_inputs_overlay.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/tutorial_inputs/widgets/tutorial_inputs_overlay.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_def.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_viewmodel.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/equipment_overlay.dart';
import 'package:darkness_dungeon/gameplay/inventory/widgets/inventory_overlay.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_debug_hud.dart';
import 'package:darkness_dungeon/shared/managers/settings_manager.dart';
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
      // initialMap: MapDef.kSVFarmId,
      // initialMap: MapDef.kSVTownId,
      initialMap: MapDef.kF1Id,
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
            (mapArguments?.playerPosition ??
                Vector2(
                  7,
                  7,
                )) * // Vector2(24, 24)) * // TODO(Kevin): NOW - put it back
            TileConstants.kTileDimensionStandard;

        // final player = buildSunnyPlayer(playerPosition);
        // final player = buildCutePlayer(playerPosition);
        final player = buildFarmerPlayer(playerPosition);

        farmInputHandler = FarmInputHandler(
          player: player,
          playerController: playerInput,
        );

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
                  showFps: AppEnvironment.kIsDevToolsMode,
                  showPosition: AppEnvironment.kIsDevToolsMode,
                  showEntities: AppEnvironment.kIsDevToolsMode,
                ),
              ],
              interface: gameplayHUD,
              lightingColorGame: mapLightingColor,
              // backgroundColor: mapBackgroundColor, // TODO(Kevin): put it back?
              overlayBuilderMap: const {},
              backgroundColor: const Color(0xFF000000),
              cameraConfig: cameraConfig,
              debugMode: AppEnvironment.kIsDebugMode,
              showCollisionArea: AppEnvironment.kShowCollisionArea,
            ),
            // Flutter Equipment Overlay - inside MapNavigator builder
            const EquipmentOverlay(),
            // Flutter Inventory Overlay - inside MapNavigator builder
            const InventoryOverlay(),
            // Flutter Tutorial Inputs Overlay - inside MapNavigator builder
            const TutorialInputsOverlay(),
            // Flutter Mobile Inputs Overlay - only for joystick mode
            if (SettingsManager.instance.inputSelected ==
                InputActionsType.joystick)
              MobileInputsOverlay(playerController: playerInput),
          ],
        );
      },
    );
  }
}
