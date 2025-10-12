import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/constants/map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_map_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_logger.dart';
import 'package:darkness_dungeon/gameplay/hud/player_hud.dart';
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
  static bool useJoystickControls = true;

  /// Game difficulty settings
  static const GameDifficulty difficulty = GameDifficulty.normal;

  @override
  State<Gameplay> createState() => _GameplayState();
}

/// State management for the Darkness Dungeon gameplay
/// Handles lifecycle events, input configuration, and game world setup
class _GameplayState extends State<Gameplay> {
  // Game configuration constants
  static const double _kJoystickSize = 100.0;
  static const double _kActionButtonSize = 80.0;
  static const double _kActionButtonMarginBottom = 50.0;
  static const double _kPrimaryActionMarginRight = 50.0;
  static const double _kSecondaryActionMarginRight = 160.0;
  static const double _kCameraSpeed = 3.0;
  static const int _kMaxVisibleTiles = 18;
  static const double _kLightingOpacity = 0.6;

  // Pre-built game components for performance optimization
  late final PlayerHUD _gameHUD;
  late final Color _lightingColor;
  late final Color? _backgroundColor;
  late final CameraConfig _cameraConfig;
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

  /// Initializes background music and sound effects
  void _initializeGameAudio() {
    GameplayAudioManager.playBackgroundMusic();
  }

  /// Cleans up audio resources when game ends
  void _cleanupGameAudio() {
    GameplayAudioManager.stopBackgroundMusic();
  }

  /// Pre-initializes all game components for better performance
  void _initializeGameComponents() {
    _gameHUD = PlayerHUD();
    _lightingColor = Colors.black.withValues(alpha: _kLightingOpacity);
    _backgroundColor = Colors.grey[900];
  }

  /// Initialize camera config in didChangeDependencies for context access
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cameraConfig = CameraConfig(
      speed: _kCameraSpeed,
      zoom: getZoomFromMaxVisibleTile(
        context,
        GameplayConstants.kCurrentTileSize,
        _kMaxVisibleTiles,
      ),
    );
  }

  @override
  Widget build(BuildContext gameplayContext) {
    return MapNavigator(
      maps: GameplayMapManager.maps,
      initialMap: MapBiomeId.map1.name,
      builder: (context, arguments, mapItem) {
        MapArguments? mapArguments = arguments as MapArguments?;
        final playerPosition =
            (mapArguments?.playerPosition ?? Vector2(4, 4)) *
            GameplayConstants.kCurrentTileSize;

        AppLogger.info(
          'Building BonfireWidget for map: ${mapItem.id}, player position: $playerPosition',
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
            interface: _gameHUD,
            lightingColorGame: _lightingColor,
            backgroundColor: _backgroundColor,
            cameraConfig: _cameraConfig,
            debugMode: AppEnvironment.isTesting,
            showCollisionArea: AppEnvironment.showCollisionBoxes,
          ),
        );
      },
    );
  }

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
        size: _kJoystickSize,
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
      size: _kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: _kActionButtonMarginBottom,
        right: _kPrimaryActionMarginRight,
      ),
    );
  }

  /// Creates secondary ranged attack action button
  JoystickAction _createRangedAttackAction() {
    return JoystickAction(
      actionId: PlayerActions.rangedAttack.index,
      sprite: Sprite.load('joystick_atack_range.png'),
      spritePressed: Sprite.load('joystick_atack_range_selected.png'),
      size: _kActionButtonSize,
      margin: const EdgeInsets.only(
        bottom: _kActionButtonMarginBottom,
        right: _kSecondaryActionMarginRight,
      ),
    );
  }
}

/// Enumeration of available player actions
enum PlayerActions { meleeAttack, rangedAttack }

/// Game difficulty levels
enum GameDifficulty { easy, normal, hard, nightmare }
