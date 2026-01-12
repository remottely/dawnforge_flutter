import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';
import 'package:dawnforge/gameplay/core/modules/combat/shield_defense_input_handler.dart';
import 'package:dawnforge/gameplay/core/modules/game/game_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/game/inventory_input_handler.dart';
import 'package:dawnforge/gameplay/core/modules/game/player_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/hud/gameplay/gameplay_hud_view.dart';
import 'package:dawnforge/gameplay/core/modules/save/game_save_controller.dart';
import 'package:dawnforge/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:dawnforge/gameplay/gameplay_screen.dart';
import 'package:dawnforge/gameplay/gameplay_screen_def.dart';
import 'package:dawnforge/gameplay/core/modules/save/domain/models/player_save_data.dart';
import 'package:dawnforge/gameplay/market/market_decoration.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/shared/utils/ui_sprite_animations_def.dart';
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
    // Reset market spawn registry to allow re-adding decoration after reloads.
    MarketDecoration.clearSpawnRegistry();
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

    print(
      '[GameplayViewModel] Camera config: '
      'resolution=${newConfig.resolution}, zoom=${newConfig.zoom}',
    );

    return newConfig;
  }

  // lib/gameplay/gameplay_screen_viewmodel.dart (CORREÇÃO)
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
      data: lastPlayerData!, // ✅ Agora sempre tem valor
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
