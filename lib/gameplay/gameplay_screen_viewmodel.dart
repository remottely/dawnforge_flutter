import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
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
import 'package:darkness_dungeon/gameplay/gameplay_screen_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen> {
  final playerStateManager = PlayerStateManager.instance;

  final gameplayHUD = GameplayHUDView();

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

  void _loadGameOrResetLife() {
    GameSaveController.instance
        .loadGame()
        .then((success) {
          if (success) {
          } else {
            _resetPlayerLifeOnNewGame();
          }
        })
        .catchError((e) {
          _resetPlayerLifeOnNewGame();
        });
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
    _initializeGameComponents();
  }

  void _initializeGameComponents() {
    cameraConfig = GameplayScreenConfig.createCameraConfig(context);
  }

  DDBasePlayerView buildSunnyPlayer(Vector2 position) {
    var lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel is! SunnyPlayerModel) {
      lastPlayerModel = SunnyPlayerModel();
      playerStateManager.lastPlayerModel = lastPlayerModel;
    }

    return SunnyPlayerView<SunnyPlayerController, SunnyPlayerModel>(
      position: position,
      model: lastPlayerModel,
    );
  }

  DDBasePlayerView buildCutePlayer(Vector2 position) {
    var lastPlayerModel = playerStateManager.lastPlayerModel;

    if (lastPlayerModel is! CutePlayerModel) {
      lastPlayerModel = CutePlayerModel();
      playerStateManager.lastPlayerModel = lastPlayerModel;
    }

    return CutePlayerView<CutePlayerController, CutePlayerModel>(
      position: position,
      model: lastPlayerModel,
    );
  }
}
