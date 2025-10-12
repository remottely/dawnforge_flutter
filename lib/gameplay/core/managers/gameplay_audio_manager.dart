import 'package:flame_audio/flame_audio.dart';

import '../constants/gameplay_audio_constants.dart';

/// [GameplayAudioManager] responsible for managing game audio and sound effects
/// Following Flutter naming conventions for audio manager systems
class GameplayAudioManager {
  // Private static instance for singleton pattern
  static GameplayAudioManager? _instance;
  static GameplayAudioManager get instance =>
      _instance ??= GameplayAudioManager._internal();

  // Private constructor for singleton
  GameplayAudioManager._internal();

  // Audio state management
  bool _isMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  /// Gets current music state
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

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

  /// Stops background music completely and updates state
  /// Following Flutter pattern of state management
  static Future<void> stopBackgroundMusic() async {
    await FlameAudio.bgm.stop();
    instance._isBackgroundMusicPlaying = false;
    instance._currentBackgroundTrack = null;
  }

  /// Ensures background music is playing (idempotent operation)
  /// Following Flutter pattern of safe state operations
  static Future<void> ensureBackgroundMusicPlaying() async {
    final manager = instance;

    if (!manager._isMusicEnabled) return;

    // Only start music if it's not already playing the correct track
    if (!manager._isBackgroundMusicPlaying ||
        manager._currentBackgroundTrack !=
            GameplayAudioConstants.kBackgroundMusicAsset) {
      await _startBackgroundMusic();
    }
  }

  /// Internal method to start background music
  static Future<void> _startBackgroundMusic() async {
    final manager = instance;
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.play(GameplayAudioConstants.kBackgroundMusicAsset);
    manager._isBackgroundMusicPlaying = true;
    manager._currentBackgroundTrack =
        GameplayAudioConstants.kBackgroundMusicAsset;
  }

  /// Legacy method for backwards compatibility
  /// Following Flutter pattern of deprecation management
  static Future<void> playBackgroundMusic() async {
    await ensureBackgroundMusicPlaying();
  }

  /// Plays boss battle background music
  /// Following Flutter pattern of descriptive method names
  static Future<void> playBossBackgroundMusic() async {
    final manager = instance;
    await FlameAudio.bgm.stop();
    await FlameAudio.bgm.play(GameplayAudioConstants.kBossBackgroundAsset);
    manager._isBackgroundMusicPlaying = true;
    manager._currentBackgroundTrack =
        GameplayAudioConstants.kBossBackgroundAsset;
  }

  /// Pauses the currently playing background music
  /// Following Flutter pattern of simple state management methods
  static void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
    // Note: We don't change _isBackgroundMusicPlaying as it's just paused
  }

  /// Resumes the paused background music
  /// Following Flutter pattern of simple state management methods
  static void resumeBackgroundMusic() {
    FlameAudio.bgm.resume();
  }

  /// Enables music globally
  static void enableMusic() {
    instance._isMusicEnabled = true;
  }

  /// Disables music globally and stops current playback
  static Future<void> disableMusic() async {
    instance._isMusicEnabled = false;
    await stopBackgroundMusic();
  }

  /// Disposes of audio resources
  /// Following Flutter pattern of resource cleanup methods
  static void dispose() {
    FlameAudio.bgm.dispose();
    instance._isBackgroundMusicPlaying = false;
    instance._currentBackgroundTrack = null;
  }
}
