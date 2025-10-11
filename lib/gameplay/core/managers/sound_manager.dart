import 'package:flame_audio/flame_audio.dart';

import '../constants/audio_constants.dart';

/// [SoundManager] responsible for managing game audio and sound effects
/// Following Flutter naming conventions for audio manager systems
class SoundManager {
  /// Initializes the audio system and preloads audio files
  /// Following Flutter pattern of async initialization methods
  static Future<void> initialize() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(AudioConstants.kAudioFilesToPreload);
  }

  /// Plays player melee attack sound effect
  /// Following Flutter pattern of descriptive method names
  static void playAttackPlayerMelee() {
    FlameAudio.play(
      AudioConstants.kAttackPlayerAsset,
      volume: AudioConstants.kAttackVolume,
    );
  }

  /// Plays range attack sound effect (fireball)
  /// Following Flutter pattern of descriptive method names
  static void playAttackRange() {
    FlameAudio.play(
      AudioConstants.kAttackFireBallAsset,
      volume: AudioConstants.kRangeVolume,
    );
  }

  /// Plays enemy melee attack sound effect
  /// Following Flutter pattern of descriptive method names
  static void playAttackEnemyMelee() {
    FlameAudio.play(
      AudioConstants.kAttackEnemyAsset,
      volume: AudioConstants.kAttackVolume,
    );
  }

  /// Plays explosion sound effect
  /// Following Flutter pattern of descriptive method names
  static void playExplosion() {
    FlameAudio.play(
      AudioConstants.kExplosionAsset,
      volume: AudioConstants.kExplosionVolume,
    );
  }

  /// Plays interaction sound effect
  /// Following Flutter pattern of descriptive method names
  static void playInteraction() {
    FlameAudio.play(
      AudioConstants.kInteractionAsset,
      volume: AudioConstants.kInteractionVolume,
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
    FlameAudio.bgm.play(AudioConstants.kBackgroundMusicAsset);
  }

  /// Plays boss battle background music
  /// Following Flutter pattern of descriptive method names
  static void playBossBackgroundMusic() {
    FlameAudio.bgm.play(AudioConstants.kBossBackgroundAsset);
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
