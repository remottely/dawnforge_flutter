import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_def.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_def.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_def.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/shield_defense_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/inventory_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay/gameplay_hud_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_def.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen>
    with WidgetsBindingObserver {
  final PlayerStateManager playerStateManager = PlayerStateManager.instance;

  GameplayHUDView gameplayHUD = GameplayHUDView();

  bool isLoadingSave = true;

  GameStateManager gameplayGameStateManager = GameStateManager();

  late InventoryInputHandler inventoryInputHandler;
  late ShieldDefenseInputHandler shieldDefenseInputHandler;
  late PlayerController playerInput;
  late FarmInputHandler farmInputHandler;

  String? lastMapId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('[GameplayViewModel] initState - Creating new player input');
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
      print('[GameplayViewModel] _loadGameOrResetLife - Starting...');
      final success = await GameSaveController.instance.loadGame();

      print('[GameplayViewModel] Load game result: $success');

      if (!success) {
        print('[GameplayViewModel] No save found, resetting player life');
        _resetPlayerLifeOnNewGame();
      } else {
        print('[GameplayViewModel] ✅ Save loaded successfully!');
      }
    } catch (e, stackTrace) {
      print('[GameplayViewModel] ❌ Error loading game: $e');
      print('[GameplayViewModel] Stack trace: $stackTrace');
      _resetPlayerLifeOnNewGame();
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSave = false;
        });
        print('[GameplayViewModel] Loading complete, isLoadingSave = false');
      }
    }
  }

  void _resetPlayerLifeOnNewGame() {
    final lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel == null) return;

    final currentLife = lastPlayerModel.life ?? 0;
    if (currentLife <= 0) lastPlayerModel.updateLife(200);
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
    
    print('[GameplayViewModel] Camera config: '
        'resolution=${newConfig.resolution}, zoom=${newConfig.zoom}');
    
    return newConfig;
  }

  DDBasePlayerView buildSunnyPlayer(Vector2 position) {
    // if (isLoadingSave)
    //   return SunnyPlayerView<SunnyPlayerController, SunnyPlayerModel>(
    //     position: position,
    //     model: SunnyPlayerModel.fromJson({}),
    //   );
    var lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel is! SunnyPlayerModel) {
      print(
        '[GameplayViewModel] Creating NEW Sunny model (no saved model found)',
      );
      lastPlayerModel = SunnyPlayerModel.fromJson({});
      playerStateManager.lastPlayerModel = lastPlayerModel;
    } else {
      print(
        '[GameplayViewModel] Using EXISTING Sunny model: '
        'stamina=${lastPlayerModel.stamina}, '
        'life=${lastPlayerModel.life}',
      );
    }

    playerStateManager.currentPlayerAnimation =
        UISpriteAnimationsDef.loadAnimationSunnyPlayerIdleRight;

    return SunnyPlayerView<SunnyPlayerController, SunnyPlayerModel>(
      position: position,
      model: lastPlayerModel,
    );
  }

  DDBasePlayerView buildCutePlayer(Vector2 position) {
    // if (isLoadingSave)
    //   return CutePlayerView<CutePlayerController, CutePlayerModel>(
    //     position: position,
    //     model: CutePlayerModel.fromJson({}),
    //   );
    var lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel is! CutePlayerModel) {
      lastPlayerModel = CutePlayerModel.fromJson({});
      playerStateManager.lastPlayerModel = lastPlayerModel;
    }

    playerStateManager.currentPlayerAnimation =
        UISpriteAnimationsDef.loadAnimationCutePlayerIdleRight;

    return CutePlayerView<CutePlayerController, CutePlayerModel>(
      position: position,
      model: lastPlayerModel,
    );
  }

  DDBasePlayerView buildFarmerPlayer(Vector2 position) {
    print('[GameplayViewModel] Building farmer player at position: $position');
    
    var lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel is! FarmerPlayerModel) {
      lastPlayerModel = FarmerPlayerModel.fromJson({});
      playerStateManager.lastPlayerModel = lastPlayerModel;
    }

    playerStateManager.currentPlayerAnimation =
        FarmerPlayerDef.loadAnimationIdleDown;

    return FarmerPlayerView<FarmerPlayerController, FarmerPlayerModel>(
      position: position,
      model: lastPlayerModel,
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
