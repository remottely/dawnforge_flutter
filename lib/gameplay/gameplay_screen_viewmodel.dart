// lib/gameplay/gameplay_screen_viewmodel.dart (REFATORADO)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_view.dart';
import 'package:dawnforge/gameplay/core/modules/combat/shield_defense_input_handler.dart';
import 'package:dawnforge/gameplay/core/modules/game/game_state_manager.dart';
import 'package:dawnforge/gameplay/core/modules/game/inventory_input_handler.dart';
import 'package:dawnforge/gameplay/core/modules/hud/gameplay/gameplay_hud_view.dart';
import 'package:dawnforge/gameplay/farm/handlers/farm_input_handler.dart';
import 'package:dawnforge/gameplay/gameplay_screen.dart';
import 'package:dawnforge/gameplay/gameplay_screen_def.dart';
import 'package:dawnforge/gameplay/market/market_decoration.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/shared/framework/save/player_save_manager.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen>
    with WidgetsBindingObserver {
  
  GameplayHUDView gameplayHUD = GameplayHUDView();
  bool isLoadingSave = true;
  
  /// Dados do player carregados do save
  CharacterData? loadedPlayerData;
  
  /// Player atual em jogo
  DemoPlayer? currentPlayer;
  
  GameStateManager gameplayGameStateManager = GameStateManager();
  
  late InventoryInputHandler inventoryInputHandler;
  late ShieldDefenseInputHandler shieldDefenseInputHandler;
  late PlayerController playerInput;
  late FarmInputHandler farmInputHandler;
  
  String? lastMapId;
  
  @override
  void initState() {
    super.initState();
    MarketDecoration.clearSpawnRegistry();
    WidgetsBinding.instance.addObserver(this);
    
    GameLogger.info('[GameplayViewModel] 🎮 Initializing...');
    
    recreatePerMapDependencies(mapId: null);
    _loadGameOrCreateNew();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    // Auto-save ao sair
    if (currentPlayer != null) {
      PlayerSaveManager.savePlayer(currentPlayer!.data);
    }
    
    super.dispose();
  }
  
  /// Carrega save ou cria novo player
  Future<void> _loadGameOrCreateNew() async {
    try {
      GameLogger.info('[GameplayViewModel] 📂 Loading save...');
      
      final savedData = await PlayerSaveManager.loadPlayer();
      
      if (savedData != null) {
        GameLogger.info('[GameplayViewModel] ✅ Save loaded!');
        loadedPlayerData = savedData;
      } else {
        GameLogger.info('[GameplayViewModel] 📝 No save found, creating new game');
        loadedPlayerData = null;
      }
    } catch (e, stackTrace) {
      GameLogger.error('[GameplayViewModel] ❌ Error loading game: $e');
      GameLogger.error('[GameplayViewModel] Stack trace: $stackTrace');
      loadedPlayerData = null;
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSave = false;
        });
        GameLogger.info('[GameplayViewModel] ✅ Loading complete');
      }
    }
  }
  
  /// Retorna a configuração da câmera
  CameraConfig getCameraConfig(BuildContext context) {
    final newConfig = GameplayScreenDef.createCameraConfig(context);
    
    GameLogger.debug(
      '[GameplayViewModel] 📷 Camera config: '
      'resolution=${newConfig.resolution}, zoom=${newConfig.zoom}',
    );
    
    return newConfig;
  }
  
  /// Constrói o player (carregado do save ou novo)
  DemoPlayer buildDemoPlayer(Vector2 position) {
    GameLogger.info(
      '[GameplayViewModel] 🎮 Building DemoPlayer at position: $position',
    );
    
    final player = loadedPlayerData != null
        ? DemoPlayer.fromSave(loadedPlayerData!.toJson())
        : DemoPlayer.newGame(position);
    
    // Se carregou do save, ajusta posição
    if (loadedPlayerData != null) {
      player.position = position;
      player.data.position = position;
    }
    
    currentPlayer = player;
    
    GameLogger.info(
      '[GameplayViewModel] ✅ Player created: '
      'life=${player.data.life}, stamina=${player.data.stamina}, '
      'coins=${player.data.coins}',
    );
    
    return player;
  }
  
  /// Recria dependências por mapa
  void recreatePerMapDependencies({required String? mapId}) {
    GameLogger.debug('[GameplayViewModel] 🔄 Recreating dependencies for map: $mapId');
    
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
