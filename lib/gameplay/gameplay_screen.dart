import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/audio/audio_manager.dart';
import 'package:dawnforge/gameplay/core/modules/game/tile_constants.dart';
import 'package:dawnforge/gameplay/core/modules/map/map_def.dart';
import 'package:dawnforge/gameplay/core/modules/map/map_manager.dart';
import 'package:dawnforge/gameplay/core/modules/map/map_transition_controller.dart';
import 'package:dawnforge/gameplay/core/utils/app_environment.dart';
import 'package:dawnforge/gameplay/core/utils/color_helper.dart';
import 'package:dawnforge/gameplay/decorations/map_transition_sensor.dart';
import 'package:dawnforge/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:dawnforge/gameplay/core/modules/hud/unified_game_overlay.dart';
import 'package:dawnforge/gameplay/gameplay_screen_viewmodel.dart';
import 'package:dawnforge/gameplay/time/time_manager.dart' as new_time;
import 'package:flutter/material.dart';
import 'dart:async';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends GameplayScreenViewmodel {
  String? _lastRequestedMusic;
  StreamSubscription<MapTransitionRequest>? _transitionSubscription;

  // Usamos BuildContext do MapNavigator para navegação
  BuildContext? _mapNavigatorContext;

  @override
  void initState() {
    super.initState();

    // Escuta solicitações de transição de mapa
    _transitionSubscription = MapTransitionController
        .instance
        .onTransitionRequested
        .listen(_handleMapTransition);
  }

  @override
  void dispose() {
    _transitionSubscription?.cancel();
    super.dispose();
  }

  // Handler para transição de mapa
  void _handleMapTransition(MapTransitionRequest request) {
    if (_mapNavigatorContext != null) {
      // Usa o contexto do MapNavigator para navegar
      MapNavigator.of(_mapNavigatorContext!).toNamed(
        request.mapId,
        arguments: MapArguments(
          playerPosition: request.playerPosition,
          playerDirection: request.playerDirection ?? Direction.down,
        ),
      );
    }
  }

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
      initialMap: MapDef.kHomeMapId,
      builder: (context, arguments, mapItem) {
        // Salva o contexto do MapNavigator
        _mapNavigatorContext = context;

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

        if (!new_time.TimeManager.instance.isRunning) {
          new_time.TimeManager.instance.start();
        }

        if (mapTimeOverride != null && mapTimeOverride.toString().isNotEmpty) {
          // Placeholder: map time overrides are intentionally ignored for now.
        }

        if (lastMapId != mapItem.id) {
          recreatePerMapDependencies(mapId: mapItem.id);
        }

        final playerPosition =
            (mapItem.id == MapDef.kHomeMapId
                ? loadedPlayerPosition ?? Vector2(5, 5)
                : (mapArguments?.playerPosition ??
                      initialPlayerPosition ??
                      Vector2(7, 7))) *
            TileConstants.kTileDimensionStandard;

        final player = buildSmallburgPlayer(playerPosition);

        farmInputHandler = FarmInputHandler(
          player: player,
          playerController: playerInput,
        );

        return Stack(
          children: [
            BonfireWidget(
              key: ValueKey(mapItem.id),
              onReady: (game) {
                new_time.TimeManager.instance.setGame(game);
                new_time.TimeManager.instance.start();
              },
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
              overlayBuilderMap: const {},
              backgroundColor: const Color(0xFF000000),
              cameraConfig: getCameraConfig(gameplayContext),
              debugMode: AppEnvironment.kIsDebugMode,
              showCollisionArea: AppEnvironment.kShowCollisionArea,
            ),

            UnifiedGameOverlay(player: player, playerController: playerInput),
          ],
        );
      },
    );
  }
}
