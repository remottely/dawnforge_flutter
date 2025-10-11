import 'package:flame_audio/flame_audio.dart';

import '../constants/gameplay_audio_constants.dart';

/// [GameplayAudioManager] responsible for managing game audio and sound effects
/// Following Flutter naming conventions for audio manager systems
class GameplayAudioManager {
  /// Initializes the audio system and preloads audio files
  /// Following Flutter pattern of async initialization methods
  static Future<void> initialize() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(
      GameplayAudioConstants.kAudioFilesToPreload,
    );
  }

  /// Plays player melee attack sound effect
  /// Following Flutter pattern of descriptive method names
  static void playAttackPlayerMelee() {
    FlameAudio.play(
      GameplayAudioConstants.kAttackPlayerAsset,
      volume: GameplayAudioConstants.kAttackVolume,
    );
  }

  /// Plays range attack sound effect (fireball)
  /// Following Flutter pattern of descriptive method names
  static void playAttackRange() {
    FlameAudio.play(
      GameplayAudioConstants.kAttackFireBallAsset,
      volume: GameplayAudioConstants.kRangeVolume,
    );
  }

  /// Plays enemy melee attack sound effect
  /// Following Flutter pattern of descriptive method names
  static void playAttackEnemyMelee() {
    FlameAudio.play(
      GameplayAudioConstants.kAttackEnemyAsset,
      volume: GameplayAudioConstants.kAttackVolume,
    );
  }

  /// Plays explosion sound effect
  /// Following Flutter pattern of descriptive method names
  static void playExplosion() {
    FlameAudio.play(
      GameplayAudioConstants.kExplosionAsset,
      volume: GameplayAudioConstants.kExplosionVolume,
    );
  }

  /// Plays interaction sound effect
  /// Following Flutter pattern of descriptive method names
  static void playInteraction() {
    FlameAudio.play(
      GameplayAudioConstants.kInteractionAsset,
      volume: GameplayAudioConstants.kInteractionVolume,
    );
  }

  /// Stops background music completely
  /// Following Flutter pattern of async return types for consistency
  static Future<void> stopBackgroundMusic() async {
    await FlameAudio.bgm.stop();
  }

  /// Plays main background music
  /// Following Flutter pattern of async methods for audio operations
  static Future<void> playBackgroundMusic() async {
    await stopBackgroundMusic();
    FlameAudio.bgm.play(GameplayAudioConstants.kBackgroundMusicAsset);
  }

  /// Plays boss battle background music
  /// Following Flutter pattern of descriptive method names
  static void playBossBackgroundMusic() {
    FlameAudio.bgm.play(GameplayAudioConstants.kBossBackgroundAsset);
  }

  /// Pauses the currently playing background music
  /// Following Flutter pattern of simple state management methods
  static void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }

  /// Resumes the paused background music
  /// Following Flutter pattern of simple state management methods
  static void resumeBackgroundMusic() {
    FlameAudio.bgm.resume();
  }

  /// Disposes of audio resources
  /// Following Flutter pattern of resource cleanup methods
  static void dispose() {
    FlameAudio.bgm.dispose();
  }
}
