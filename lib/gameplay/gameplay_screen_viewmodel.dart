import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_camera_utils.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_game_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/hud/gameplay_hud.dart';
import 'package:darkness_dungeon/gameplay/gameplay_screen.dart';
import 'package:flutter/material.dart';

abstract class GameplayScreenViewmodel extends State<GameplayScreen> {
  late final GameplayHUD gameplayHUD;
  late final CameraConfig cameraConfig;
  final gameplayGameStateManager = GameplayGameStateManager();

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
    cameraConfig = GameplayCameraUtils.createCameraConfig(context);
  }

  void _cleanupGameAudio() {
    GameplayAudioManager.instance.stopBackgroundMusic();
  }

  void _initializeGameComponents() {
    gameplayHUD = GameplayHUD();
  }

  KnightPlayerView buildKnightPlayer(Vector2 position) =>
      KnightPlayerView(position);
}
