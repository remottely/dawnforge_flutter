import 'dart:developer' as developer;

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
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_view.dart';
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
            developer.log('[ViewModel] ✅ Game loaded from save');
          } else {
            developer.log('[ViewModel] No save found, starting new game');
            _resetPlayerLifeOnNewGame();
          }
        })
        .catchError((e) {
          developer.log('[ViewModel] Error loading game: $e');
          _resetPlayerLifeOnNewGame();
        });
  }

  void _resetPlayerLifeOnNewGame() {
    final farmModel = playerStateManager
        .lastFarmPlayerModel; // TODO(Kevin): change it to DDFarmPlayerModel

    if (farmModel != null &&
        farmModel.life != null &&
        (farmModel.life ?? 0) <= 0) {
      farmModel.updateLife(200);
      developer.log('[ViewModel] Reset Sunny life to full on new game');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeGameComponents();
  }

  void _initializeGameComponents() {
    cameraConfig = GameplayScreenConfig.createCameraConfig(context);
  }

  DDFarmPlayerView buildSunnyPlayer(Vector2 position) {
    if (playerStateManager.lastFarmPlayerModel is! SunnyPlayerModel) {
      playerStateManager.lastFarmPlayerModel = SunnyPlayerModel();
    }

    DDFarmPlayerView? lastPlayer = playerStateManager.lastFarmPlayerView;

    final playerModel = playerStateManager.lastFarmPlayerModel;

    if (lastPlayer != null && !lastPlayer.isDead) {
      final currentLife = lastPlayer.life;
      playerModel?.updateLife(currentLife);
    }

    lastPlayer = SunnyPlayerView<SunnyPlayerController, SunnyPlayerModel>(
      position: position,
      model: playerModel as SunnyPlayerModel? ?? SunnyPlayerModel(),
    );

    return lastPlayer;
  }

  DDFarmPlayerView buildCutePlayer(Vector2 position) {
    if (playerStateManager.lastFarmPlayerModel is! CutePlayerModel) {
      playerStateManager.lastFarmPlayerModel = CutePlayerModel();
    }

    DDFarmPlayerView? lastPlayer = playerStateManager.lastFarmPlayerView;

    final playerModel = playerStateManager.lastFarmPlayerModel;

    if (lastPlayer != null && !lastPlayer.isDead) {
      final currentLife = lastPlayer.life;
      playerModel?.updateLife(currentLife);
    }

    lastPlayer = CutePlayerView<CutePlayerController, CutePlayerModel>(
      position: position,
      model: playerModel as CutePlayerModel? ?? CutePlayerModel(),
    );

    return lastPlayer;
  }
}
