import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/color_helper.dart';
import 'package:darkness_dungeon/gameplay/decorations/map_transition_sensor.dart';
import 'package:darkness_dungeon/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/unified_game_overlay.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_viewmodel.dart';
import 'package:darkness_dungeon/gameplay/time/time_manager.dart' as new_time;
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
      initialMap: MapDef.kFarmMapId,
      // initialMap: MapDef.kSVTownId,
      // initialMap: MapDef.kF1Id,
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
        final mapInitialPlayerPosition = mapItem
            .properties[MapDef.kInitialPlayerPositionPropertyKey]
            ?.toString();
        final mapTimeOverride = mapItem.properties['timeOverride'];

        Vector2? _tryParsePosition(String? raw) {
          if (raw == null || raw.isEmpty) return null;
          final parts = raw.split(',');
          if (parts.length != 2) return null;
          final x = double.tryParse(parts[0].trim());
          final y = double.tryParse(parts[1].trim());
          if (x == null || y == null) return null;
          return Vector2(x, y);
        }

        if (mapBackgroundMusic != null &&
            mapBackgroundMusic.isNotEmpty &&
            _lastRequestedMusic != mapBackgroundMusic) {
          _lastRequestedMusic = mapBackgroundMusic;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AudioManager.instance.playBackgroundMusic(mapBackgroundMusic);
          });
        }

        final mapArguments = arguments as MapArguments?;
        final initialPlayerPosition = _tryParsePosition(
          mapInitialPlayerPosition,
        );

        // Keep current time; start ticking if not already running. Ignore time
        // overrides unless explicitly handled elsewhere.
        if (!new_time.TimeManager.instance.isRunning) {
          new_time.TimeManager.instance.start();
        }

        if (mapTimeOverride != null && mapTimeOverride.toString().isNotEmpty) {
          // Placeholder: map time overrides are intentionally ignored for now.
        }

        // Recreate per-map dependencies when map changes to avoid stale gameRef
        // references after navigation.
        if (lastMapId != mapItem.id) {
          recreatePerMapDependencies(mapId: mapItem.id);
        }

        final playerPosition =
            (mapArguments?.playerPosition ?? initialPlayerPosition ?? Vector2(7, 7)) *
                TileConstants.kTileDimensionStandard;

        // final player = buildSunnyPlayer(playerPosition);
        // final player = buildCutePlayer(playerPosition);
        // final player = buildFarmerPlayer(playerPosition);
        final player = buildDemoPlayer(playerPosition);

        farmInputHandler = FarmInputHandler(
          player: player,
          playerController: playerInput,
        );

        return Stack(
          children: [
            BonfireWidget(
              key: ValueKey(mapItem.id),
              playerControllers: [playerInput],
              player: player,
              map: mapItem.map,
              components: [
                gameplayGameStateManager,
                inventoryInputHandler,
                shieldDefenseInputHandler,
                farmInputHandler,
              ],
              hudComponents: const [],
              interface: gameplayHUD,
              lightingColorGame: mapLightingColor,
              // backgroundColor: mapBackgroundColor, // TODO(Kevin): put it back?
              overlayBuilderMap: const {},
              backgroundColor: const Color(0xFF000000),
              cameraConfig: getCameraConfig(gameplayContext),
              debugMode: AppEnvironment.kIsDebugMode,
              showCollisionArea: AppEnvironment.kShowCollisionArea,
            ),

            // Unified Game Overlay - all HUD components organized in a grid
            UnifiedGameOverlay(player: player, playerController: playerInput),
          ],
        );
      },
    );
  }
}
