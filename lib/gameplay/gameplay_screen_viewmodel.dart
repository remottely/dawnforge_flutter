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
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen> {
  final playerStateManager = PlayerStateManager.instance;

  final gameplayHUD = GameplayHUDView();

  bool isLoadingSave = true;

  late final CameraConfig cameraConfig;
  final gameplayGameStateManager = GameStateManager();

  final inventoryInputHandler = InventoryInputHandler();
  final shieldDefenseInputHandler = ShieldDefenseInputHandler();
  late PlayerController playerInput;
  late FarmInputHandler farmInputHandler;

  @override
  void initState() {
    super.initState();
    _loadGameOrResetLife();
  }

  Future<void> _loadGameOrResetLife() async {
    try {
      final success = await GameSaveController.instance.loadGame();

      if (!success) {
        _resetPlayerLifeOnNewGame();
      } else if (playerStateManager.consumeRespawnWithFullLifeFlag()) {
        _restoreFullLifeForCurrentPlayer();
      }
    } catch (_) {
      _resetPlayerLifeOnNewGame();
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSave = false;
        });
      }
    }
  }

  void _resetPlayerLifeOnNewGame() {
    final lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel == null) return;

    final currentLife = lastPlayerModel.life ?? 0;
    if (currentLife <= 0) lastPlayerModel.updateLife(200);
  }

  void _restoreFullLifeForCurrentPlayer() {
    final model = playerStateManager.lastPlayerModel;
    if (model == null) return;

    if (model is FarmerPlayerModel) {
      model.updateLife(FarmerPlayerDef.kLife);
      return;
    }

    if (model is CutePlayerModel) {
      model.updateLife(CutePlayerDef.kLife);
      return;
    }

    if (model is SunnyPlayerModel) {
      model.updateLife(SunnyPlayerDef.kLife);
      return;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeGameComponents();
  }

  void _initializeGameComponents() {
    cameraConfig = GameplayScreenDef.createCameraConfig(context);
  }

  DDBasePlayerView buildSunnyPlayer(Vector2 position) {
    // if (isLoadingSave)
    //   return SunnyPlayerView<SunnyPlayerController, SunnyPlayerModel>(
    //     position: position,
    //     model: SunnyPlayerModel.fromJson({}),
    //   );
    var lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel is! SunnyPlayerModel) {
      lastPlayerModel = SunnyPlayerModel.fromJson({});
      playerStateManager.lastPlayerModel = lastPlayerModel;
    }

    playerStateManager.currentPlayerAnimation =
        UISpriteAnimationsDef.loadAnimationSunnyPlayerIdleRight();

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
        UISpriteAnimationsDef.loadAnimationCutePlayerIdleRight();

    return CutePlayerView<CutePlayerController, CutePlayerModel>(
      position: position,
      model: lastPlayerModel,
    );
  }

  DDBasePlayerView buildFarmerPlayer(Vector2 position) {
    // if (isLoadingSave)
    //   return FarmerPlayerView<FarmerPlayerController, FarmerPlayerModel>(
    //     position: position,
    //     model: FarmerPlayerModel.fromJson({}),
    //   );
    var lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel is! FarmerPlayerModel) {
      lastPlayerModel = FarmerPlayerModel.fromJson({});
      playerStateManager.lastPlayerModel = lastPlayerModel;
    }

    playerStateManager.currentPlayerAnimation =
        FarmerPlayerDef.loadAnimationIdleRight;

    return FarmerPlayerView<FarmerPlayerController, FarmerPlayerModel>(
      position: position,
      model: lastPlayerModel,
    );
  }
}
