// // lib/game/features/gameplay_screen_viewmodel.dart
// import 'package:bonfire/bonfire.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/cute/cute_player_controller.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/cute/cute_player_def.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/cute/cute_player_view.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/farmer/farmer_player_controller.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/farmer/farmer_player_def.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/farmer/farmer_player_view.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/smallburg/smallburg_player_controller.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/smallburg/smallburg_player_def.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/smallburg/smallburg_player_view.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/sunny/sunny_player_controller.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/sunny/sunny_player_def.dart';
// import 'package:dawnforge/game/features/game_world/characters/player/sunny/sunny_player_view.dart';
// import 'package:dawnforge/game/global/global_input_handler.dart';
// import 'package:dawnforge/game/systems/combat/shield_defense_input_handler.dart';
// import 'package:dawnforge/game/systems/game/game_state_manager.dart';
// import 'package:dawnforge/game/systems/game/inventory_input_handler.dart';
// import 'package:dawnforge/game/systems/game/player_state_manager.dart';
// import 'package:dawnforge/game/systems/save/game_save_controller.dart';
// import 'package:dawnforge/game/features/farm/handlers/farm_input_handler.dart';
// import 'package:dawnforge/game/features/gameplay_screen.dart';
// import 'package:dawnforge/game/features/gameplay_screen_def.dart';
// import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
// import 'package:dawnforge/game/features/market/market_decoration.dart';
// import 'package:dawnforge/core/utils/game_logger.dart';
// import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
// import 'package:dawnforge/shared/utils/ui_sprite_animations_def.dart';
// import 'package:flutter/material.dart';

// abstract class GameplayScreenViewmodel extends State<GameplayScreen>
//     with WidgetsBindingObserver {
//   final PlayerStateManager playerStateManager = PlayerStateManager.instance;

//   bool isLoadingSave = true;
//   Vector2? loadedPlayerPosition;

//   GameStateManager gameplayGameStateManager = GameStateManager();

//   late InventoryInputHandler inventoryInputHandler;
//   late ShieldDefenseInputHandler shieldDefenseInputHandler;
//   late GlobalInputHandler globalInputHandler;

//   // ✅ PlayerInput ÚNICO (criado uma vez no initState)
//   late final PlayerController _playerInput;
//   PlayerController get playerInput => _playerInput;

//   late FarmInputHandler farmInputHandler;

//   String? lastMapId;

//   @override
//   void initState() {
//     super.initState();
//     MarketDecoration.clearSpawnRegistry();
//     WidgetsBinding.instance.addObserver(this);

//     // ✅ CRIA PlayerInput UMA VEZ
//     _playerInput = GameplayScreenDef.createPlayerInput();

//     GameLogger.debug('[GameplayViewModel] initState - PlayerInput created');

//     recreatePerMapDependencies(mapId: null);
//     _loadGameOrResetLife();
//   }

//   @override
//   void dispose() {
//     // ✅ LIMPA OBSERVERS ANTES DE DESTRUIR
//     _cleanupObservers();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   Future<void> _loadGameOrResetLife() async {
//     try {
//       GameLogger.debug(
//         '[GameplayViewModel] _loadGameOrResetLife - Starting...',
//       );
//       final success = await GameSaveController.instance.loadGame();

//       GameLogger.debug('[GameplayViewModel] Load game result: $success');

//       if (!success) {
//         GameLogger.info(
//           '[GameplayViewModel] No save found, resetting player life',
//         );
//         _resetPlayerLifeOnNewGame();
//         loadedPlayerPosition = null;
//       } else {
//         GameLogger.info('[GameplayViewModel] ✅ Save loaded successfully!');
//         final lastPlayerModel = playerStateManager.lastPlayerModel;
//         final positionList = (lastPlayerModel?.toJson()['position'] as List?)
//             ?.map((e) => (e as num).toDouble())
//             .toList();
//         if (positionList != null && positionList.length == 2) {
//           loadedPlayerPosition = Vector2(positionList[0], positionList[1]);
//           GameLogger.info(
//             '[GameplayViewModel] Loaded player position from save: $loadedPlayerPosition',
//           );
//         } else {
//           loadedPlayerPosition = null;
//         }
//       }
//     } catch (e, stackTrace) {
//       GameLogger.error('[GameplayViewModel] ❌ Error loading game: $e');
//       GameLogger.error('[GameplayViewModel] Stack trace: $stackTrace');
//       _resetPlayerLifeOnNewGame();
//       loadedPlayerPosition = null;
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoadingSave = false;
//         });
//         GameLogger.debug(
//           '[GameplayViewModel] Loading complete, isLoadingSave = false',
//         );
//       }
//     }
//   }

//   void _resetPlayerLifeOnNewGame() {
//     final lastPlayerModel = playerStateManager.lastPlayerModel;

//     if (lastPlayerModel == null) return;

//     final currentLife = lastPlayerModel.life ?? 0;
//     if (currentLife <= 0) lastPlayerModel.updateLife(200);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }

//   CameraConfig getCameraConfig(BuildContext context) {
//     final newConfig = GameplayScreenDef.createCameraConfig(context);

//     GameLogger.debug(
//       '[GameplayViewModel] Camera config: resolution=${newConfig.resolution}, zoom=${newConfig.zoom}',
//     );

//     return newConfig;
//   }

//   DDBasePlayerView buildSunnyPlayer(Vector2 position) {
//     var lastPlayerModel = playerStateManager.lastPlayerModel;

//     if (lastPlayerModel is! DDFarmPlayerModel) {
//       GameLogger.info('[GameplayViewModel] Creating NEW Sunny model');
//       lastPlayerModel = DDFarmPlayerModel.fromJson(
//         {},
//         SunnyPlayerDef.modelConfig,
//       );
//       playerStateManager.setLastPlayerModel(lastPlayerModel);
//     } else {
//       GameLogger.info(
//         '[GameplayViewModel] Using EXISTING Sunny model: stamina=${lastPlayerModel.stamina}, life=${lastPlayerModel.life}',
//       );
//     }

//     playerStateManager.currentPlayerAnimation =
//         UISpriteAnimationsDef.loadAnimationSunnyPlayerIdleRight;

//     final player = SunnyPlayerView<SunnyPlayerController, DDFarmPlayerModel>(
//       position: position,
//       model: lastPlayerModel,
//     );

//     PlayerStateManager.instance.setLastPlayerView(player);

//     return player;
//   }

//   DDBasePlayerView buildCutePlayer(Vector2 position) {
//     var lastPlayerModel = playerStateManager.lastPlayerModel;
//     final lastPlayerJson = lastPlayerModel?.toJson() ?? {'coins': 500};

//     if (lastPlayerModel is! DDFarmPlayerModel) {
//       lastPlayerModel = DDFarmPlayerModel.fromJson(
//         lastPlayerJson,
//         CutePlayerDef.modelConfig,
//       );
//       playerStateManager.setLastPlayerModel(lastPlayerModel);
//     }

//     playerStateManager.currentPlayerAnimation =
//         UISpriteAnimationsDef.loadAnimationCutePlayerIdleRight;

//     final player = CutePlayerView<CutePlayerController, DDFarmPlayerModel>(
//       position: position,
//       model: lastPlayerModel,
//     );

//     PlayerStateManager.instance.setLastPlayerView(player);

//     return player;
//   }

//   DDBasePlayerView buildFarmerPlayer(Vector2 position) {
//     GameLogger.debug(
//       '[GameplayViewModel] Building farmer player at position: $position',
//     );

//     var lastPlayerModel = playerStateManager.lastPlayerModel;
//     final lastPlayerJson = lastPlayerModel?.toJson() ?? {'coins': 500};

//     if (lastPlayerModel is! DDFarmPlayerModel) {
//       lastPlayerModel = DDFarmPlayerModel.fromJson(
//         lastPlayerJson,
//         FarmerPlayerDef.modelConfig,
//       );
//       playerStateManager.setLastPlayerModel(lastPlayerModel);
//     }

//     playerStateManager.currentPlayerAnimation =
//         FarmerPlayerDef.loadAnimationIdleDown;

//     final player = FarmerPlayerView<FarmerPlayerController, DDFarmPlayerModel>(
//       position: position,
//       model: lastPlayerModel,
//     );

//     PlayerStateManager.instance.setLastPlayerView(player);

//     return player;
//   }

//   DDBasePlayerView buildSmallburgPlayer(Vector2 position) {
//     GameLogger.debug(
//       '[GameplayViewModel] Building smallburg player at position: $position',
//     );

//     var lastPlayerModel = playerStateManager.lastPlayerModel;
//     final lastPlayerJson = lastPlayerModel?.toJson() ?? {'coins': 500};

//     if (lastPlayerModel is! DDFarmPlayerModel) {
//       lastPlayerModel = DDFarmPlayerModel.fromJson(
//         lastPlayerJson,
//         SmallburgPlayerDef.modelConfig,
//       );
//       playerStateManager.setLastPlayerModel(lastPlayerModel);
//     }

//     playerStateManager.currentPlayerAnimation =
//         SmallburgPlayerDef.loadAnimationIdleDown;

//     final player =
//         SmallburgPlayerView<SmallburgPlayerController, DDFarmPlayerModel>(
//           position: position,
//           model: lastPlayerModel,
//         );

//     PlayerStateManager.instance.setLastPlayerView(player);

//     return player;
//   }

//   /// ✅ LIMPA OBSERVERS ANTIGOS ANTES DE RECRIAR
//   void _cleanupObservers() {
//     GameLogger.debug(
//       '[GameplayViewModel] Cleaning up observers for map transition',
//     );

//     // Remove observers antigos (se existirem)
//     if (lastMapId != null) {
//       try {
//         _playerInput.removeObserver(inventoryInputHandler);
//         _playerInput.removeObserver(shieldDefenseInputHandler);
//         _playerInput.removeObserver(globalInputHandler);
//         _playerInput.removeObserver(farmInputHandler);
//       } catch (e) {
//         GameLogger.warning('[GameplayViewModel] Error removing observers: $e');
//       }
//     }
//   }

//   /// ✅ RECRIA OBSERVERS (SEM RECRIAR PlayerInput)
//   void recreatePerMapDependencies({required String? mapId}) {
//     GameLogger.debug(
//       '[GameplayViewModel] Recreating dependencies for map: $mapId',
//     );

//     // ✅ LIMPA OBSERVERS ANTIGOS
//     _cleanupObservers();

//     GlobalInputHandler.instance.setPlayerInput(_playerInput);
//     globalInputHandler = GlobalInputHandler.instance;

//     // ✅ RECRIA HANDLERS (mas usa o MESMO _playerInput)
//     inventoryInputHandler = InventoryInputHandler(playerInput: _playerInput);
//     shieldDefenseInputHandler = ShieldDefenseInputHandler(
//       playerInput: _playerInput,
//     );
//     gameplayGameStateManager = GameStateManager();

//     lastMapId = mapId;

//     GameLogger.debug(
//       '[GameplayViewModel] Dependencies recreated for map: $mapId',
//     );
//   }
// }
