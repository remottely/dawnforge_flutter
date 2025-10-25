import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/data/gameplay_map_config.dart';
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

class Gameplay extends StatefulWidget {
  const Gameplay({super.key});

  static bool useJoystickControls = false;

  static const GameDifficulty difficulty = GameDifficulty.normal;

  @override
  State<Gameplay> createState() => _GameplayState();
}

class _GameplayState extends State<Gameplay> {
  static const double _kJoystickSpriteSize = 100.0;
  static const double kActionButtonSize = 80.0;
  static const double kActionButtonMarginBottom = 50.0;
  static const double kPrimaryActionMarginRight = 50.0;
  static const double kSecondaryActionMarginRight = 160.0;

  late final GameplayHUD _gameplayHUD;
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

        final mapBackgroundMusic = mapItem
            .properties[GameplayMapConfig.kBackgroundMusicPropertyKey]
            ?.toString();

        final mapLightingColor = ColorHelper.fromHex(
          mapItem.properties[GameplayMapConfig.kLightingColorPropertyKey]
              ?.toString(),
        );
        final mapBackgroundColor = ColorHelper.fromHex(
          mapItem.properties[GameplayMapConfig.kBackgroundColorPropertyKey]
              ?.toString(),
        );

        if (mapBackgroundMusic != null && mapBackgroundMusic.isNotEmpty) {
          GameplayAudioManager.instance.ensureBackgroundMusicPlaying(
            mapBackgroundMusic,
          );
        }

        AppLogger.info(
          'Building BonfireWidget for map: ${mapItem.id}, player position: $playerPosition, music: $mapBackgroundMusic, lighting: $mapLightingColor, background: $mapBackgroundColor',
        );

        final player = _createKnightPlayerWithState(playerPosition);

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

  void _initializeGameAudio() {
    GameplayAudioManager.instance.ensureBackgroundMusicPlaying();
  }

  void _cleanupGameAudio() {
    GameplayAudioManager.instance.stopBackgroundMusic();
  }

  void _initializeGameComponents() {
    _gameplayHUD = GameplayHUD();
  }

  KnightPlayerView _createKnightPlayerWithState(Vector2 position) {
    final knight = KnightPlayerView(position);

    AppLogger.info('Created fresh knight at position: $position');
    return knight;
  }

  PlayerController _createFreshController() {
    return _createPlayerController();
  }

  PlayerController _createPlayerController() {
    return Gameplay.useJoystickControls
        ? _createJoystickController()
        : _createKeyboardController();
  }

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

  PlayerController _createKeyboardController() {
    return Keyboard(
      config: KeyboardConfig(
        directionalKeys: [KeyboardDirectionalKeys.arrows()],
        acceptedKeys: [LogicalKeyboardKey.space, LogicalKeyboardKey.keyZ],
      ),
    );
  }

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

enum PlayerActions { meleeAttack, rangedAttack }

enum GameDifficulty { easy, normal, hard, nightmare }
