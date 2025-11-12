import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'audio_config.dart';

final class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  bool _isBackgroundMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  Future<void> initialize() async {
    if (kDebugMode) {
      print('[AudioManager] Initializing...');
    }
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(AudioConfig.kPreloadAudioFiles);
    if (kDebugMode) {
      print('[AudioManager] Initialized successfully');
    }
  }

  /// SFX
  void playPlayerPrimaryAttackSfx() {
    FlameAudio.play(
      AudioConfig.kSfxPlayerAttackAsset,
      volume: AudioConfig.kPrimaryAttackVolume,
    );
  }

  void playFireballAttackSfx() {
    FlameAudio.play(
      AudioConfig.kSfxCharacterFireBallAttackAsset,
      volume: AudioConfig.kCharacterFireballAttackVolume,
    );
  }

  void playEnemyPrimaryAttackSfx() {
    FlameAudio.play(
      AudioConfig.kSfxEnemyAttackAsset,
      volume: AudioConfig.kPrimaryAttackVolume,
    );
  }

  void playFireballExplosionSfx() {
    FlameAudio.play(
      AudioConfig.kSfxCharacterFireballExplosionAsset,
      volume: AudioConfig.kCharacterFireballExplosionVolume,
    );
  }

  void playConversationInteractionSfx() {
    FlameAudio.play(
      AudioConfig.kSfxConversationInteractionAsset,
      volume: AudioConfig.kConversationInteractionVolume,
    );
  }

  /// Background Music
  Future<void> stopBackgroundMusic() async {
    if (kDebugMode) {
      print('[AudioManager] Stopping music. Current: $_currentBackgroundTrack');
    }
    await FlameAudio.bgm.stop();
    _isBackgroundMusicPlaying = false;
    _currentBackgroundTrack = null;
  }

  Future<void> playBackgroundMusic(String musicTrack) async {
    if (kDebugMode) {
      print('[AudioManager] playBackgroundMusic called with: $musicTrack');
      print(
        '[AudioManager] Current state - playing: $_isBackgroundMusicPlaying, track: $_currentBackgroundTrack',
      );
    }

    // Verifica se deve tocar música
    if (!_isBackgroundMusicEnabled) {
      if (kDebugMode) {
        print('[AudioManager] Background music disabled, skipping');
      }
      return;
    }

    if (!AppEnvironment.kPlayBackgroundMusic) {
      if (kDebugMode) {
        print(
          '[AudioManager] AppEnvironment.kPlayBackgroundMusic is false, skipping',
        );
      }
      return;
    }

    // Se já está tocando a mesma música, não precisa fazer nada
    if (_isBackgroundMusicPlaying && _currentBackgroundTrack == musicTrack) {
      if (kDebugMode) {
        print('[AudioManager] Already playing $musicTrack, skipping');
      }
      return;
    }

    // Para a música atual se houver
    if (_isBackgroundMusicPlaying) {
      await stopBackgroundMusic();
    }

    // Toca a nova música
    try {
      if (kDebugMode) {
        print('[AudioManager] Starting to play: $musicTrack');
      }
      await FlameAudio.bgm.play(musicTrack);
      _isBackgroundMusicPlaying = true;
      _currentBackgroundTrack = musicTrack;
      if (kDebugMode) {
        print('[AudioManager] Successfully started playing: $musicTrack');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[AudioManager] ERROR playing music: $e');
      }
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }

  void pauseBackgroundMusic() {
    FlameAudio.bgm.pause();
  }

  void resumeBackgroundMusic() {
    FlameAudio.bgm.resume();
  }

  void enableBackgroundMusic() {
    resumeBackgroundMusic();
    _isBackgroundMusicEnabled = true;
  }

  void disableBackgroundMusic() {
    pauseBackgroundMusic();
    _isBackgroundMusicEnabled = false;
  }

  void disposeBackgroundMusic() {
    FlameAudio.bgm.dispose();
    _isBackgroundMusicPlaying = false;
    _currentBackgroundTrack = null;
  }
}
