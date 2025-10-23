import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants/gameplay_audio_constants.dart';

/// [GameplayAudioManager] responsible for managing game audio and sound effects
/// Following Flutter naming conventions for audio manager systems
///
/// This class handles:
/// - Background music playback and transitions
/// - Sound effect triggering and management
/// - Audio resource preloading and caching
/// - Music state persistence and control
/// - Volume and playback configuration
class GameplayAudioManager {
  // Private static instance for singleton pattern
  static GameplayAudioManager? _instance;
  static final GameplayAudioManager instance = _instance ??=
      GameplayAudioManager._internal();

  // Private constructor for singleton
  GameplayAudioManager._internal();

  // Audio state management
  bool _isMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  /// Gets current music state
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

  /// Centralized error handling for audio operations
  /// Following Flutter pattern of error management
  static void _handleAudioError(String operation, dynamic error) {
    if (kDebugMode) {
      print('[GameplayAudioManager] Error in $operation: $error');
    }
    // Future: Could integrate with crash reporting service
  }

  /// Initializes the audio system and preloads audio files
  /// Following Flutter pattern of async initialization methods
  static Future<void> initialize() async {
    try {
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll(
        GameplayAudioConstants.kAudioFilesToPreload,
      );
    } catch (e) {
      _handleAudioError('initialize', e);
    }
  }

  /// Plays player melee attack sound effect
  /// Following Flutter pattern of descriptive method names
  static void playAttackPlayerMelee() {
    try {
      FlameAudio.play(
        GameplayAudioConstants.kAttackPlayerAsset,
        volume: GameplayAudioConstants.kAttackVolume,
      );
    } catch (e) {
      _handleAudioError('playAttackPlayerMelee', e);
    }
  }

  /// Plays range attack sound effect (fireball)
  /// Following Flutter pattern of descriptive method names
  static void playFireballAttack() {
    try {
      FlameAudio.play(
        GameplayAudioConstants.kFireBallAttackAudioAssetPath,
        volume: GameplayAudioConstants.kRangeVolume,
      );
    } catch (e) {
      _handleAudioError('playAttackRange', e);
    }
  }

  /// Plays enemy melee attack sound effect
  /// Following Flutter pattern of descriptive method names
  static void playAttackEnemyMelee() {
    try {
      FlameAudio.play(
        GameplayAudioConstants.kAttackEnemyAsset,
        volume: GameplayAudioConstants.kAttackVolume,
      );
    } catch (e) {
      _handleAudioError('playAttackEnemyMelee', e);
    }
  }

  /// Plays explosion sound effect
  /// Following Flutter pattern of descriptive method names
  static void playFireballExplosion() {
    try {
      FlameAudio.play(
        GameplayAudioConstants.kFireballExplosionAudioAssetPath,
        volume: GameplayAudioConstants.kFireballExplosionVolume,
      );
    } catch (e) {
      _handleAudioError('playExplosion', e);
    }
  }

  /// Plays interaction sound effect
  /// Following Flutter pattern of descriptive method names
  static void playInteraction() {
    try {
      FlameAudio.play(
        GameplayAudioConstants.kInteractionAsset,
        volume: GameplayAudioConstants.kInteractionVolume,
      );
    } catch (e) {
      _handleAudioError('playInteraction', e);
    }
  }

  /// Stops background music completely and updates state
  /// Following Flutter pattern of state management
  static Future<void> stopBackgroundMusic() async {
    try {
      await FlameAudio.bgm.stop();
      instance._isBackgroundMusicPlaying = false;
      instance._currentBackgroundTrack = null;
    } catch (e) {
      _handleAudioError('stopBackgroundMusic', e);
      // Ensure state is properly reset even if stop fails
      instance._isBackgroundMusicPlaying = false;
      instance._currentBackgroundTrack = null;
    }
  }

  /// Ensures background music is playing (idempotent operation)
  /// Following Flutter pattern of safe state operations
  static Future<void> ensureBackgroundMusicPlaying([String? musicTrack]) async {
    try {
      final manager = instance;

      if (!manager._isMusicEnabled) return;

      // Use provided track or default
      final targetTrack =
          musicTrack ?? GameplayAudioConstants.kLettersBackgroundMusicAsset;

      // Only start music if it's not already playing the correct track
      if (!manager._isBackgroundMusicPlaying ||
          manager._currentBackgroundTrack != targetTrack) {
        await _startSpecificMusic(targetTrack);
      }
    } catch (e) {
      _handleAudioError('ensureBackgroundMusicPlaying', e);
    }
  }

  /// Plays specific background music track
  /// Following Flutter pattern of targeted operations
  static Future<void> playSpecificBackgroundMusic(String musicTrack) async {
    try {
      final manager = instance;

      if (!manager._isMusicEnabled) return;

      await _startSpecificMusic(musicTrack);
    } catch (e) {
      _handleAudioError('playSpecificBackgroundMusic', e);
    }
  }

  /// Internal method to start specific background music
  static Future<void> _startSpecificMusic(String musicTrack) async {
    final manager = instance;
    print('[GameplayAudioManager] Stopping current music...');
    await FlameAudio.bgm.stop();
    print('[GameplayAudioManager] Starting music: $musicTrack');
    try {
      if (!AppEnvironment.isTesting) await FlameAudio.bgm.play(musicTrack);
      manager._isBackgroundMusicPlaying = true;
      manager._currentBackgroundTrack = musicTrack;
      print('[GameplayAudioManager] Music started successfully: $musicTrack');
    } catch (e) {
      print('[GameplayAudioManager] Error starting music: $e');
      manager._isBackgroundMusicPlaying = false;
      manager._currentBackgroundTrack = null;
    }
  }

  /// Legacy method for backwards compatibility
  /// Following Flutter pattern of deprecation management
  static Future<void> playBackgroundMusic() async {
    try {
      await ensureBackgroundMusicPlaying();
    } catch (e) {
      _handleAudioError('playBackgroundMusic', e);
    }
  }

  static Future<void> playBossBackgroundMusic() async {
    try {
      await _startSpecificMusic(GameplayAudioConstants.kBossBackgroundAsset);
    } catch (e) {
      _handleAudioError('playBossBackgroundMusic', e);
    }
  }

  /// Pauses the currently playing background music
  /// Following Flutter pattern of simple state management methods
  static void pauseBackgroundMusic() {
    try {
      FlameAudio.bgm.pause();
      // Note: We don't change _isBackgroundMusicPlaying as it's just paused
    } catch (e) {
      _handleAudioError('pauseBackgroundMusic', e);
    }
  }

  /// Resumes the paused background music
  /// Following Flutter pattern of simple state management methods
  static void resumeBackgroundMusic() {
    try {
      FlameAudio.bgm.resume();
    } catch (e) {
      _handleAudioError('resumeBackgroundMusic', e);
    }
  }

  /// Enables music globally
  static void enableMusic() {
    try {
      instance._isMusicEnabled = true;
    } catch (e) {
      _handleAudioError('enableMusic', e);
    }
  }

  /// Disables music globally and stops current playback
  static Future<void> disableMusic() async {
    try {
      instance._isMusicEnabled = false;
      await stopBackgroundMusic();
    } catch (e) {
      _handleAudioError('disableMusic', e);
    }
  }

  /// Disposes of audio resources
  /// Following Flutter pattern of resource cleanup methods
  static void dispose() {
    try {
      FlameAudio.bgm.dispose();
      instance._isBackgroundMusicPlaying = false;
      instance._currentBackgroundTrack = null;
    } catch (e) {
      _handleAudioError('dispose', e);
      // Ensure state cleanup even if dispose fails
      instance._isBackgroundMusicPlaying = false;
      instance._currentBackgroundTrack = null;
    }
  }
}
