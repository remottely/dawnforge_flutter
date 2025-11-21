import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/game/custom_player_inventory_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/inventory_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/shield_defense_input_handler.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay/gameplay_hud_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_save_controller.dart';
import 'package:darkness_dungeon/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_config.dart';
import 'package:darkness_dungeon/gameplay/inventory/equipment_to_custom_player_adapter.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen> {
  final gameplayHUD = GameplayHUDView();
  late final CameraConfig cameraConfig;
  final gameplayGameStateManager = GameStateManager();
  // final customPlayerInventoryInputHandler = CustomPlayerInventoryInputHandler();
  final inventoryInputHandler = InventoryInputHandler();
  final shieldDefenseInputHandler = ShieldDefenseInputHandler();
  late PlayerController playerInput;
  late FarmInputHandler farmInputHandler;

  // Referências aos últimos players criados (para capturar vida antes de recriar)
  CustomPlayerView? _lastCustomPlayer;
  SunnyPlayerView? _lastSunnyPlayer;

  @override
  void initState() {
    super.initState();
    _loadGameOrResetLife();
  }

  /// Tenta carregar save existente, ou reseta vida se for novo jogo
  void _loadGameOrResetLife() {
    // Tentar carregar save de forma assíncrona
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
    // Resetar vida no PlayerStateManager quando iniciar novo jogo
    // Isso garante que mesmo após morte, o próximo jogo comece com vida cheia
    final stateManager = PlayerStateManager.instance;
    final customModel = stateManager.getKnightModel();
    final sunnyModel = stateManager.getSunnyModel();

    // Se a vida estiver em 0 ou muito baixa, resetar para null (usa vida padrão)
    if (customModel.life != null && customModel.life! <= 0) {
      customModel.updateLife(200); // Vida padrão do Knight (kLifeExtraLarge)
      developer.log('[ViewModel] Reset Knight life to full on new game');
    }

    if (sunnyModel.life != null && sunnyModel.life! <= 0) {
      sunnyModel.updateLife(200); // Vida padrão do Sunny (kLifeExtraLarge)
      developer.log('[ViewModel] Reset Sunny life to full on new game');
    }
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
    _initializeGameComponents();
  }

  void _initializeGameComponents() {
    cameraConfig = GameplayScreenConfig.createCameraConfig(context);
  }

  SunnyPlayerView buildSunnyPlayer(Vector2 position) {
    final stateManager = PlayerStateManager.instance;
    final model = stateManager.getSunnyModel();

    // Salvar vida do player anterior no model antes de criar novo
    // (apenas se não estiver morto - evita loop de morte)
    if (_lastSunnyPlayer != null && !_lastSunnyPlayer!.isDead) {
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

  CustomPlayerView buildCustomPlayer(Vector2 position) {
    final stateManager = PlayerStateManager.instance;
    final model = stateManager.getKnightModel();

    // Salvar vida do player anterior no model antes de criar novo
    // (apenas se não estiver morto - evita loop de morte)
    if (_lastCustomPlayer != null && !_lastCustomPlayer!.isDead) {
      final currentLife = _lastCustomPlayer!.life;
      model.updateLife(currentLife);
      developer.log(
        '[ViewModel] Captured Knight life before rebuild: $currentLife',
      );
    }

    // final player = CustomPlayerView(
    //   position: position,
    //   model: model,
    //   animation: KnightPlayerConfig.animation,
    //   size: KnightPlayerConfig.componentSize,
    //   hitbox: KnightPlayerConfig.hitbox,
    //   life: KnightPlayerConfig.kLife,
    //   speed: KnightPlayerConfig.kSpeed,
    //   lightingConfig: KnightPlayerConfig.lightingConfig,
    // handLoadout: EquipmentToCustomPlayerAdapter.instance
    // .createLoadoutFromEquipment(),
    // );

    final player = CustomPlayerView(
      position: position,
      model: model,
      animation: SunnyPlayerConfig.walkAnimation,
      size: SunnyPlayerConfig.componentSize,
      hitbox: SunnyPlayerConfig.hitbox,
      life: SunnyPlayerConfig.kLife,
      speed: SunnyPlayerConfig.kSpeed,
      lightingConfig: SunnyPlayerConfig.lightingConfig,
      handLoadout: EquipmentToCustomPlayerAdapter.instance
          .createLoadoutFromEquipment(),
    );

    developer.log(
      '[ViewModel] Created Knight with model life: ${model.life ?? 'null'}',
    );

    _lastCustomPlayer = player;
    return player;
  }
}
