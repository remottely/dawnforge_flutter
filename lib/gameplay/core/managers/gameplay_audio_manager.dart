import 'dart:developer';

import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../config/gameplay_audio_config.dart';

class GameplayAudioManager {
  static final instance = GameplayAudioManager();

  bool _isBackgroundMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  bool get isMusicEnabled => _isBackgroundMusicEnabled;
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

  Future<void> initialize() async {
    try {
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll(
        GameplayAudioConfig.kPreloadAudioFiles,
      );
    } catch (e) {
      _handleAudioError('initialize', e);
    }
  }

  /// Sound Effects
  void playPlayerPrimaryAttackSfx() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kSfxPlayerAttackAsset,
        volume: GameplayAudioConfig.kPrimaryAttackVolume,
      );
    } catch (e) {
      _handleAudioError('playPlayerPrimaryAttackSfx', e);
    }
  }

  void playFireballAttackSfx() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kSfxCharacterFireBallAttackAsset,
        volume: GameplayAudioConfig.kCharacterFireballAttackVolume,
      );
    } catch (e) {
      _handleAudioError('playFireballAttackSfx', e);
    }
  }

  void playEnemyPrimaryAttackSfx() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kSfxEnemyAttackAsset,
        volume: GameplayAudioConfig.kPrimaryAttackVolume,
      );
    } catch (e) {
      _handleAudioError('playEnemyPrimaryAttackSfx', e);
    }
  }

  void playFireballExplosionSfx() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kSfxCharacterFireballExplosionAsset,
        volume: GameplayAudioConfig.kCharacterFireballExplosionVolume,
      );
    } catch (e) {
      _handleAudioError('playFireballExplosionSfx', e);
    }
  }

  void playConversationInteractionSfx() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kSfxConversationInteractionAsset,
        volume: GameplayAudioConfig.kConversationInteractionVolume,
      );
    } catch (e) {
      _handleAudioError('playConversationInteractionSfx', e);
    }
  }

  /// Background Music
  Future<void> stopBackgroundMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      _handleAudioError('stopBackgroundMusic', e);
    } finally {
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }

  Future<void> playBackgroundMusic(String musicTrack) async {
    stopBackgroundMusic();
    try {
      if (!_isBackgroundMusicEnabled) return;
      if (!_isBackgroundMusicPlaying || _currentBackgroundTrack != musicTrack) {
        if (AppEnvironment.kPlayBackgroundMusic) {
          await FlameAudio.bgm.play(musicTrack);
          _isBackgroundMusicPlaying = true;
          _currentBackgroundTrack = musicTrack;
        }
      }
    } catch (e) {
      _handleAudioError('playBackgroundMusic', e);
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }

  void pauseBackgroundMusic() {
    try {
      FlameAudio.bgm.pause();
    } catch (e) {
      _handleAudioError('pauseBackgroundMusic', e);
    }
  }

  void resumeBackgroundMusic() {
    try {
      FlameAudio.bgm.resume();
    } catch (e) {
      _handleAudioError('resumeBackgroundMusic', e);
    }
  }

  void enableBackgroundMusic() {
    try {
      _isBackgroundMusicEnabled = true;
    } catch (e) {
      _handleAudioError('enableBackgroundMusic', e);
    }
  }

  Future<void> disableBackgroundMusic() async {
    try {
      _isBackgroundMusicEnabled = false;
      await stopBackgroundMusic();
    } catch (e) {
      _handleAudioError('disableBackgroundMusic', e);
    }
  }

  void disposeBackgroundMusic() {
    try {
      FlameAudio.bgm.dispose();
    } catch (e) {
      _handleAudioError('disposeBackgroundMusic', e);
    } finally {
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }

  void _handleAudioError(String operation, dynamic error) {
    if (kDebugMode) {
      log('[GameplayAudioManager] Error in $operation: $error');
    }
  }
}
