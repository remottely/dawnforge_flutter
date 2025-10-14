import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/models/map_model.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_logger.dart';
import 'package:darkness_dungeon/gameplay/core/utils/gameplay_map_sensor.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/color_helper.dart';
import 'package:darkness_dungeon/gameplay/hud/gameplay_hud.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';
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
  static const double kJoystickSize = 100.0;
  static const double kActionButtonSize = 80.0;
  static const double kActionButtonMarginBottom = 50.0;
  static const double kPrimaryActionMarginRight = 50.0;
  static const double kSecondaryActionMarginRight = 160.0;

  // Camera Constants
  static const double kCameraSpeed = 3.0;
  static const int kMaxVisibleTiles = 18;

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
      speed: kCameraSpeed,
      zoom: getZoomFromMaxVisibleTile(
        context,
        GameplayConstants.kCurrentTileSize,
        kMaxVisibleTiles,
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
            GameplayConstants.kCurrentTileSize;

        // Read background music from Tiled properties (optional field)
        final mapBackgroundMusic = mapItem
            .properties[MapModel.kBackgroundMusicPropertyKey]
            ?.toString();

        // Parse color values using ColorHelper for better maintainability
        final mapLightingColor = ColorHelper.fromHex(
          mapItem.properties[MapModel.kLightingColorPropertyKey]?.toString(),
        );
        final mapBackgroundColor = ColorHelper.fromHex(
          mapItem.properties[MapModel.kBackgroundColorPropertyKey]?.toString(),
        );
        // Start map-specific background music if provided
        if (mapBackgroundMusic != null && mapBackgroundMusic.isNotEmpty) {
          GameplayAudioManager.ensureBackgroundMusicPlaying(mapBackgroundMusic);
        }

        AppLogger.info(
          'Building BonfireWidget for map: ${mapItem.id}, player position: $playerPosition, music: $mapBackgroundMusic, lighting: $mapLightingColor, background: $mapBackgroundColor',
        );

        // Create player for the current map
        final player = _createPlayerWithState(playerPosition);

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

  // 6. Métodos de factory de componentes (agrupados)

  /// Creates player for the current map
  /// Following Flutter pattern of component factories
  Knight _createPlayerWithState(Vector2 position) {
    final player = Knight(position);
    AppLogger.info('Created fresh player at position: $position');
    return player;
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
        size: kJoystickSize,
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
      sprite: Sprite.load('joystick_atack.png'),
      spritePressed: Sprite.load('joystick_atack_selected.png'),
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
      sprite: Sprite.load('joystick_atack_range.png'),
      spritePressed: Sprite.load('joystick_atack_range_selected.png'),
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
