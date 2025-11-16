import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/inventory_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/shield_defense_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/hud_view.dart';
import 'package:darkness_dungeon/gameplay/farm/components/farm_interaction_component.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_config.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen> {
  late final HUDView gameplayHUD;
  late final CameraConfig cameraConfig;
  final gameplayGameStateManager = GameStateManager();
  final inventoryInputHandler = InventoryInputHandler();
  final shieldDefenseInputHandler = ShieldDefenseInputHandler();
  FarmInteractionComponent? farmInteractionComponent;

  // Referências aos últimos players criados (para capturar vida antes de recriar)
  KnightPlayerView? _lastKnightPlayer;
  SunnyPlayerView? _lastSunnyPlayer;

  @override
  void initState() {
    super.initState();
    _initializeGameComponents();
  }

  @override
  void dispose() {
    // NÃO para a música no dispose - deixa o AudioManager gerenciar
    // A música deve continuar entre transições de tela
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cameraConfig = GameplayScreenConfig.createCameraConfig(context);
  }

  void _initializeGameComponents() {
    gameplayHUD = HUDView();
  }

  SunnyPlayerView buildSunnyPlayer(Vector2 position) {
    final stateManager = PlayerStateManager.instance;
    final model = stateManager.getSunnyModel();

    // Salvar vida do player anterior no model antes de criar novo
    if (_lastSunnyPlayer != null) {
      final currentLife = _lastSunnyPlayer!.life;
      model.updateLife(currentLife);
      developer.log(
        '[ViewModel] Captured Sunny life before rebuild: $currentLife',
      );
    }

    final player = SunnyPlayerView(position: position, model: model);

    developer.log(
      '[ViewModel] Created Sunny with model life: ${model.life ?? 'null'}',
    );

    _lastSunnyPlayer = player;
    return player;
  }

  KnightPlayerView buildKnightPlayer(Vector2 position) {
    final stateManager = PlayerStateManager.instance;
    final model = stateManager.getKnightModel();

    // Salvar vida do player anterior no model antes de criar novo
    if (_lastKnightPlayer != null) {
      final currentLife = _lastKnightPlayer!.life;
      model.updateLife(currentLife);
      developer.log(
        '[ViewModel] Captured Knight life before rebuild: $currentLife',
      );
    }

    final player = KnightPlayerView(position: position, model: model);

    developer.log(
      '[ViewModel] Created Knight with model life: ${model.life ?? 'null'}',
    );

    _lastKnightPlayer = player;
    return player;
  }
}
