import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
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
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen> {
  final gameplayHUD = GameplayHUDView();

  late final CameraConfig cameraConfig;
  final gameplayGameStateManager = GameStateManager();

  final inventoryInputHandler = InventoryInputHandler();
  final shieldDefenseInputHandler = ShieldDefenseInputHandler();
  late PlayerController playerInput;
  late FarmInputHandler farmInputHandler;

  SunnyPlayerView? _lastSunnyPlayer;

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
    final stateManager = PlayerStateManager.instance;
    final sunnyModel = stateManager.getSunnyModel();

    if (sunnyModel.life != null && sunnyModel.life! <= 0) {
      sunnyModel.updateLife(200);
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

  SunnyPlayerView buildSunnyPlayer(Vector2 position) {
    final playerModel = PlayerStateManager.instance.getSunnyModel();

    if (_lastSunnyPlayer != null && !_lastSunnyPlayer!.isDead) {
      final currentLife = _lastSunnyPlayer!.life;
      playerModel.updateLife(currentLife);
      developer.log(
        '[ViewModel] Captured Sunny life before rebuild: $currentLife',
      );
    }

    final player = SunnyPlayerView<SunnyPlayerController, SunnyPlayerModel>(
      position: position,
      model: playerModel,
    );

    developer.log(
      '[ViewModel] Created Sunny with model life: ${playerModel.life ?? 'null'}',
    );

    _lastSunnyPlayer = player;
    return player;
  }
}
