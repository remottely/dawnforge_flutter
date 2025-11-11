import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/hud_view.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen_config.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen> {
  late final HUDView gameplayHUD;
  late final CameraConfig cameraConfig;
  final gameplayGameStateManager = GameStateManager();

  @override
  void initState() {
    super.initState();
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
    cameraConfig = GameplayScreenConfig.createCameraConfig(context);
  }

  void _cleanupGameAudio() {
    AudioManager.instance.stopBackgroundMusic();
  }

  void _initializeGameComponents() {
    gameplayHUD = HUDView();
  }

  SunnyPlayerView buildKnightPlayer(Vector2 position) => SunnyPlayerView(
    position: position,
    model: SunnyPlayerModel(),
  ); // TODO(Kevin): implement save/load KnightPlayerModel
}
