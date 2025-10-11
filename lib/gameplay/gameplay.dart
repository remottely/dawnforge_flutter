import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/game_constants.dart';
import 'package:darkness_dungeon/gameplay/core/managers/game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/sound_manager.dart';
import 'package:darkness_dungeon/gameplay/decoration/door.dart';
import 'package:darkness_dungeon/gameplay/decoration/key.dart';
import 'package:darkness_dungeon/gameplay/decoration/life_potion.dart';
import 'package:darkness_dungeon/gameplay/decoration/spikes.dart';
import 'package:darkness_dungeon/gameplay/decoration/torch.dart';
import 'package:darkness_dungeon/gameplay/enemies/boss.dart';
import 'package:darkness_dungeon/gameplay/enemies/goblin.dart';
import 'package:darkness_dungeon/gameplay/enemies/imp.dart';
import 'package:darkness_dungeon/gameplay/enemies/mini_boss.dart';
import 'package:darkness_dungeon/gameplay/hud/player_hud.dart';
import 'package:darkness_dungeon/gameplay/npc/kid.dart';
import 'package:darkness_dungeon/gameplay/npc/wizard_npc.dart';
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

  // Player spawn configuration
  static const double _kPlayerSpawnX = 2.0;
  static const double _kPlayerSpawnY = 3.0;

  // Potion configuration
  static const double _kLifePotionHealAmount = 30.0;

  // Pre-built game components for performance optimization
  late final PlayerController _playerController;
  late final Knight _player;
  late final WorldMapByTiled _worldMap;
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
    SoundManager.playBackgroundMusic();
  }

  /// Cleans up audio resources when game ends
  void _cleanupGameAudio() {
    SoundManager.stopBackgroundMusic();
  }

  /// Pre-initializes all game components for better performance
  void _initializeGameComponents() {
    _player = _createPlayer();
    _worldMap = _createWorldMap();
    _gameHUD = PlayerHUD();
    _lightingColor = Colors.black.withValues(alpha: _kLightingOpacity);
    _backgroundColor = Colors.grey[900];
    _playerController = _createPlayerController();
  }

  /// Initialize camera config in didChangeDependencies for context access
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cameraConfig = CameraConfig(
      speed: _kCameraSpeed,
      zoom: getZoomFromMaxVisibleTile(
        context,
        GameConstants.kCurrentTileSize,
        _kMaxVisibleTiles,
      ),
    );
  }

  @override
  Widget build(BuildContext gameplayContext) {
    return Material(
      color: Colors.transparent,
      child: BonfireWidget(
        playerControllers: [_playerController],
        player: _player,
        map: _worldMap,
        components: [GameStateManager()],
        interface: _gameHUD,
        lightingColorGame: _lightingColor,
        backgroundColor: _backgroundColor,
        cameraConfig: _cameraConfig,
      ),
    );
  }

  /// Creates the appropriate player controller based on configuration
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

  /// Creates the player character at spawn position
  Knight _createPlayer() {
    return Knight(
      Vector2(
        _kPlayerSpawnX * GameConstants.kCurrentTileSize,
        _kPlayerSpawnY * GameConstants.kCurrentTileSize,
      ),
    );
  }

  /// Creates the game world map with all entities and decorations
  WorldMapByTiled _createWorldMap() {
    return WorldMapByTiled(
      WorldMapReader.fromAsset('tiled/map.json'),
      forceTileSize: Vector2(
        GameConstants.kCurrentTileSize,
        GameConstants.kCurrentTileSize,
      ),
      objectsBuilder: _createObjectsMap(),
    );
  }

  /// Defines the mapping of object types to their constructors
  Map<String, GameComponent Function(TiledObjectProperties)>
  _createObjectsMap() {
    return {
      // Interactive decorations
      'door': (p) => Door(p.position, p.size),
      'key': (p) => DoorKey(p.position),
      'potion': (p) => LifePotion(p.position, _kLifePotionHealAmount),

      // Environmental decorations
      'torch': (p) => Torch(p.position),
      'torch_empty': (p) => Torch(p.position, isExtinguished: true),
      'spikes': (p) => Spikes(p.position),

      // Non-player characters
      'wizard': (p) => WizardNPC(p.position),
      'kid': (p) => Kid(p.position),

      // Enemies
      'boss': (p) => Boss(p.position),
      'mini_boss': (p) => MiniBoss(p.position),
      'goblin': (p) => Goblin(p.position),
      'imp': (p) => Imp(p.position),
    };
  }
}

/// Enumeration of available player actions
enum PlayerActions { meleeAttack, rangedAttack }

/// Game difficulty levels
enum GameDifficulty { easy, normal, hard, nightmare }
