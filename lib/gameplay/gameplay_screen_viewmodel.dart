import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/characters/player/cute/cute_player_def.dart';

import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';

import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';
import 'package:dawnforge/gameplay/characters/player/farmer/farmer_player_def.dart';

import 'package:dawnforge/gameplay/characters/player/sunny/sunny_player_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/shield_defense_input_handler.dart';
import 'package:dawnforge/gameplay/core/modules/game/game_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/game/inventory_input_handler.dart';
import 'package:dawnforge/gameplay/core/modules/game/player_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/hud/gameplay/gameplay_hud_view.dart';
import 'package:dawnforge/gameplay/core/modules/save/game_save_controller.dart';
import 'package:dawnforge/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:dawnforge/gameplay/gameplay_screen.dart';
import 'package:dawnforge/gameplay/gameplay_screen_def.dart';
import 'package:dawnforge/shared/framework/character/character.dart';
import 'package:dawnforge/gameplay/market/market_decoration.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/shared/utils/ui_sprite_animations_def.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen>
    with WidgetsBindingObserver {
  final PlayerStateManager playerStateManager = PlayerStateManager.instance;

  GameplayHUDView gameplayHUD = GameplayHUDView();

  bool isLoadingSave = true;

  /// Holds the loaded player position from save, if available
  Vector2? loadedPlayerPosition;

  GameStateManager gameplayGameStateManager = GameStateManager();

  late InventoryInputHandler inventoryInputHandler;
  late ShieldDefenseInputHandler shieldDefenseInputHandler;
  late PlayerController playerInput;
  late FarmInputHandler farmInputHandler;

  String? lastMapId;

  @override
  void initState() {
    super.initState();
    // Reset market spawn registry to allow re-adding decoration after reloads.
    MarketDecoration.clearSpawnRegistry();
    WidgetsBinding.instance.addObserver(this);
    GameLogger.debug(
      '[GameplayViewModel] initState - Creating new player input',
    );
    recreatePerMapDependencies(mapId: null);
    _loadGameOrResetLife();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadGameOrResetLife() async {
    try {
      GameLogger.debug(
        '[GameplayViewModel] _loadGameOrResetLife - Starting...',
      );
      final success = await GameSaveController.instance.loadGame();

      GameLogger.debug('[GameplayViewModel] Load game result: $success');

      if (!success) {
        GameLogger.info(
          '[GameplayViewModel] No save found, resetting player life',
        );
        _resetPlayerLifeOnNewGame();
        loadedPlayerPosition = null;
      } else {
        GameLogger.info('[GameplayViewModel] ✅ Save loaded successfully!');
        // Try to extract position from loaded player model
        final lastPlayerData = playerStateManager.lastPlayerData;
        final positionList = (lastPlayerData?.toJson()['position'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList();
        if (positionList != null && positionList.length == 2) {
          loadedPlayerPosition = Vector2(positionList[0], positionList[1]);
          GameLogger.info(
            '[GameplayViewModel] Loaded player position from save: $loadedPlayerPosition',
          );
        } else {
          loadedPlayerPosition = null;
        }
      }
    } catch (e, stackTrace) {
      GameLogger.error('[GameplayViewModel] ❌ Error loading game: $e');
      GameLogger.error('[GameplayViewModel] Stack trace: $stackTrace');
      _resetPlayerLifeOnNewGame();
      loadedPlayerPosition = null;
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSave = false;
        });
        GameLogger.debug(
          '[GameplayViewModel] Loading complete, isLoadingSave = false',
        );
      }
    }
  }

  void _resetPlayerLifeOnNewGame() {
    final lastPlayerData = playerStateManager.lastPlayerData;

    if (lastPlayerData == null) return;

    final currentLife = lastPlayerData.life ?? 0;
    if (currentLife <= 0) lastPlayerData.updateLife(200);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// Retorna a configuração da câmera, recalculando dinamicamente
  /// baseado no tamanho atual da tela sem forçar rebuilds do BonfireWidget
  CameraConfig getCameraConfig(BuildContext context) {
    // Sempre recalcula baseado no MediaQuery atual
    // Isso permite que a câmera se ajuste em fullscreen e orientação
    // sem precisar reconstruir o BonfireWidget (que resetaria o player)
    final newConfig = GameplayScreenDef.createCameraConfig(context);

    GameLogger.debug(
      '[GameplayViewModel] Camera config: resolution=${newConfig.resolution}, zoom=${newConfig.zoom}',
    );

    return newConfig;
  }

  // Character buildSunnyPlayer(Vector2 position) {
  //   // if (isLoadingSave)
  //   //   return SunnyPlayerView<SunnyPlayerController, CharacterData>(
  //   //     position: position,
  //   //     model: CharacterData.fromJson({}),
  //   //   );
  //   var lastPlayerData = playerStateManager.lastPlayerData;

  //   if (lastPlayerData is! CharacterData) {
  //     GameLogger.info(
  //       '[GameplayViewModel] Creating NEW Sunny model (no saved model found)',
  //     );
  //     lastPlayerData = CharacterData.fromJson(
  //       {},
  //       SunnyPlayerDef.modelConfig,
  //     );
  //     playerStateManager.lastPlayerData = lastPlayerData;
  //   } else {
  //     GameLogger.info(
  //       '[GameplayViewModel] Using EXISTING Sunny model: stamina=${lastPlayerData.stamina}, life=${lastPlayerData.life}',
  //     );
  //   }

  //   playerStateManager.currentPlayerAnimation =
  //       UISpriteAnimationsDef.loadAnimationSunnyPlayerIdleRight;

  //   return DemoPlayer(
  //     position: position,
  //     id: '',
  //     data: lastPlayerData,
  //   );
  // }

  // Character buildCutePlayer(Vector2 position) {
  //   // if (isLoadingSave)
  //   //   return CutePlayerView<CutePlayerController, CharacterData>(
  //   //     position: position,
  //   //     model: CharacterData.fromJson({}),
  //   //   );
  //   var lastPlayerData = playerStateManager.lastPlayerData;
  //   final lastPlayerJson = lastPlayerData?.toJson() ?? {'coins': 500};
  //   //  ?? PlayerSaveData.initial(playerType: 'cute').toJson();

  //   if (lastPlayerData is! CharacterData) {
  //     lastPlayerData = CharacterData.fromJson(
  //       lastPlayerJson,
  //       CutePlayerDef.modelConfig,
  //     );
  //     playerStateManager.lastPlayerData = lastPlayerData;
  //   }

  //   playerStateManager.currentPlayerAnimation =
  //       UISpriteAnimationsDef.loadAnimationCutePlayerIdleRight;

  //   return CutePlayerView<CutePlayerController, CharacterData>(
  //     position: position,
  //     model: lastPlayerData,
  //   );
  // }

  // Character buildFarmerPlayer(Vector2 position) {
  //   GameLogger.debug(
  //     '[GameplayViewModel] Building farmer player at position: $position',
  //   );

  //   var lastPlayerData = playerStateManager.lastPlayerData;
  //   final lastPlayerJson = lastPlayerData?.toJson() ?? {'coins': 500};
  //   //  ?? PlayerSaveData.initial(playerType: 'farmer').toJson();

  //   if (lastPlayerData is! CharacterData) {
  //     lastPlayerData = CharacterData.fromJson(
  //       lastPlayerJson,
  //       FarmerPlayerDef.modelConfig,
  //     );
  //     playerStateManager.lastPlayerData = lastPlayerData;
  //   }

  //   playerStateManager.currentPlayerAnimation =
  //       FarmerPlayerDef.loadAnimationIdleDown;

  //   return FarmerPlayerView<FarmerPlayerController, CharacterData>(
  //     position: position,
  //     model: lastPlayerData,
  //   );
  // }

  DemoPlayer buildDemoPlayer(Vector2 position) {
    print('[GameplayViewModel] Building demo player at position: $position');

    var lastPlayerData = playerStateManager.lastPlayerData;

    // ✅ CORREÇÃO: Cria novo player se não existe save
    if (lastPlayerData == null) {
      print('[GameplayViewModel] No save data found, creating new player');

      // Cria CharacterData padrão
      lastPlayerData = CharacterData.defaultPlayer(
        maxStamina: DemoPlayerDef.config.maxStamina,
        maxEnergy: DemoPlayerDef.config.maxEnergy,
        maxLife: DemoPlayerDef.config.maxLife,
        position: position,
      );

      // Salva no state manager
      playerStateManager.lastPlayerData = lastPlayerData;
    }

    playerStateManager.currentPlayerAnimation =
        DemoPlayerDef.loadAnimationIdleDown;

    return DemoPlayer(
      position: position,
      id: 'player_demo',
      data: lastPlayerData, // ✅ Agora sempre tem valor
    );
  }

  void recreatePerMapDependencies({required String? mapId}) {
    playerInput = GameplayScreenDef.createPlayerInput();
    inventoryInputHandler = InventoryInputHandler(
      playerController: playerInput,
    );
    shieldDefenseInputHandler = ShieldDefenseInputHandler(
      playerController: playerInput,
    );
    gameplayGameStateManager = GameStateManager();
    gameplayHUD = GameplayHUDView();
    lastMapId = mapId;
  }
}
