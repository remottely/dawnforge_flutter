import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/data/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/core/hud/gameplay_hud.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_logger.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/color_helper.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_sensor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Darkness Dungeon gameplay screen - Main game arena where the adventure unfolds
/// This widget manages the complete game environment including player controls,
/// world map, entities, and user interface components.
class Gameplay extends StatefulWidget {
  const Gameplay({super.key});

  /// Configuration flag to determine input method
  /// true: Touch joystick controls (mobile-friendly)
  /// false: Keyboard controls (desktop-friendly)
  static bool useJoystickControls = false;

  /// Game difficulty settings
  static const GameDifficulty difficulty = GameDifficulty.normal;

  @override
  State<Gameplay> createState() => _GameplayState();
}

/// State management for the Darkness Dungeon gameplay
///
/// This class handles the complete game environment including:
/// - Game lifecycle management (initialization, cleanup)
/// - Player controller configuration (joystick vs keyboard)
/// - Camera and world setup
/// - Map navigation and transitions
/// - Audio management and background music
///
/// Following CLAUDE.md patterns for Flutter StatefulWidget organization
class _GameplayState extends State<Gameplay> {
  // 1. Constantes de configuração do jogo (agrupadas por tipo)
  // UI Constants
  static const double _kJoystickSpriteSize = 100.0;
  static const double kActionButtonSize = 80.0;
  static const double kActionButtonMarginBottom = 50.0;
  static const double kPrimaryActionMarginRight = 50.0;
  static const double kSecondaryActionMarginRight = 160.0;

  // 2. Componentes de jogo pré-construídos
  late final GameplayHUD _gameplayHUD;
  late final CameraConfig _cameraConfig;

  // 3. Métodos de ciclo de vida
  @override
  void initState() {
    super.initState();
    _initializeGameAudio();
    _initializeGameComponents();
  }

  @override
  void dispose() {
    _cleanupGameAudio();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cameraConfig = CameraConfig(
      speed: GameplayConstants.kCameraSpeed,
      zoom: GameplayConstants.getCameraZoomFromMaxVisibleTile(
        context,
        maxVisibleTile: GameplayConstants.kMaxVisibleTiles,
      ),
    );
  }

  // 4. Método de build principal

  @override
  Widget build(BuildContext gameplayContext) {
    return MapNavigator(
      maps: GameplayMapManager.maps,
      initialMap: MapId.map1.name,
      builder: (context, arguments, mapItem) {
        MapArguments? mapArguments = arguments as MapArguments?;
        final playerPosition =
            (mapArguments?.playerPosition ?? Vector2(4, 4)) *
            GameplayConstants.kTileDimensionStandard;

        // Read background music from Tiled properties (optional field)
        final mapBackgroundMusic = mapItem
            .properties[GameplayMapData.kBackgroundMusicPropertyKey]
            ?.toString();

        // Parse color values using ColorHelper for better maintainability
        final mapLightingColor = ColorHelper.fromHex(
          mapItem.properties[GameplayMapData.kLightingColorPropertyKey]
              ?.toString(),
        );
        final mapBackgroundColor = ColorHelper.fromHex(
          mapItem.properties[GameplayMapData.kBackgroundColorPropertyKey]
              ?.toString(),
        );
        // Start map-specific background music if provided
        if (mapBackgroundMusic != null && mapBackgroundMusic.isNotEmpty) {
          GameplayAudioManager.ensureBackgroundMusicPlaying(mapBackgroundMusic);
        }

        AppLogger.info(
          'Building BonfireWidget for map: ${mapItem.id}, player position: $playerPosition, music: $mapBackgroundMusic, lighting: $mapLightingColor, background: $mapBackgroundColor',
        );

        // Create player for the current map
        final player = _createKnightPlayerWithState(playerPosition);

        // Ensure controller is active by recreating it for each map
        final activeController = _createFreshController();

        return Material(
          color: Colors.transparent,
          child: BonfireWidget(
            playerControllers: [activeController],
            player: player,
            map: mapItem.map,
            components: [GameplayStateManager()],
            interface: _gameplayHUD,
            lightingColorGame: mapLightingColor,
            backgroundColor: mapBackgroundColor,
            cameraConfig: _cameraConfig,
            debugMode: AppEnvironment.isTesting,
            showCollisionArea: AppEnvironment.showCollisionBoxes,
          ),
        );
      },
    );
  }

  // 5. Métodos de inicialização (agrupados)
  /// Initializes background music and sound effects
  void _initializeGameAudio() {
    GameplayAudioManager.ensureBackgroundMusicPlaying();
  }

  /// Cleans up audio resources when game ends
  void _cleanupGameAudio() {
    GameplayAudioManager.stopBackgroundMusic();
  }

  /// Pre-initializes all game components for better performance
  void _initializeGameComponents() {
    _gameplayHUD = GameplayHUD();
  }

  KnightPlayerView _createKnightPlayerWithState(Vector2 position) {
    final knight = KnightPlayerView(position);

    AppLogger.info('Created fresh knight at position: $position');
    return knight;
  }

  /// Creates a fresh controller instance for each map navigation
  /// Following Flutter pattern of controller management
  PlayerController _createFreshController() {
    return _createPlayerController();
  }

  /// Creates the appropriate player controller based on configuration
  /// Following Flutter pattern of controller factory methods
  PlayerController _createPlayerController() {
    return Gameplay.useJoystickControls
        ? _createJoystickController()
        : _createKeyboardController();
  }

  /// Creates touch-based joystick controller for mobile devices
  PlayerController _createJoystickController() {
    return Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: _kJoystickSpriteSize,
        isFixed: false,
      ),
      actions: [_createPrimaryAttackAction(), _createRangedAttackAction()],
    );
  }

  /// Creates keyboard controller for desktop devices
  PlayerController _createKeyboardController() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: [KeyboardDirectionalKeys.arrows()],
        acceptedKeys: [LogicalKeyboardKey.space, LogicalKeyboardKey.keyZ],
      ),
    );
  }

  /// Creates primary melee attack action button
  JoystickAction _createPrimaryAttackAction() {
    return JoystickAction(
      actionId: PlayerActions.meleeAttack.index,
      sprite: Sprite.load('joystick_attack.png'),
      spritePressed: Sprite.load('joystick_attack_selected.png'),
      size: kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: kActionButtonMarginBottom,
        right: kPrimaryActionMarginRight,
      ),
    );
  }

  /// Creates secondary ranged attack action button
  JoystickAction _createRangedAttackAction() {
    return JoystickAction(
      actionId: PlayerActions.rangedAttack.index,
      sprite: Sprite.load('joystick_attack_range.png'),
      spritePressed: Sprite.load('joystick_attack_range_selected.png'),
      size: kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: kActionButtonMarginBottom,
        right: kSecondaryActionMarginRight,
      ),
    );
  }
}

/// Enumeration of available player actions
enum PlayerActions { meleeAttack, rangedAttack }

/// Game difficulty levels
enum GameDifficulty { easy, normal, hard, nightmare }
