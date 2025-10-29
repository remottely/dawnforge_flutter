import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../config/gameplay_audio_config.dart';

class GameplayAudioManager {
  static final instance = GameplayAudioManager();

  bool _isMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isBackgroundMusicPlaying => _isBackgroundMusicPlaying;

  void _handleAudioError(String operation, dynamic error) {
    if (kDebugMode) {
      print('[GameplayAudioManager] Error in $operation: $error');
    }
  }

  Future<void> initialize() async {
    try {
      FlameAudio.bgm.initialize();
      await FlameAudio.audioCache.loadAll(
        GameplayAudioConfig.kAudioFilesToPreload,
      );
    } catch (e) {
      _handleAudioError('initialize', e);
    }
  }

  void playAttackPlayerMelee() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kAttackPlayerAsset,
        volume: GameplayAudioConfig.kAttackVolume,
      );
    } catch (e) {
      _handleAudioError('playAttackPlayerMelee', e);
    }
  }

  void playFireballAttack() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kFireBallAttackAudioAsset,
        volume: GameplayAudioConfig.kRangeVolume,
      );
    } catch (e) {
      _handleAudioError('playAttackRange', e);
    }
  }

  void playAttackEnemyMelee() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kAttackEnemyAsset,
        volume: GameplayAudioConfig.kAttackVolume,
      );
    } catch (e) {
      _handleAudioError('playAttackEnemyMelee', e);
    }
  }

  void playFireballExplosion() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kFireballExplosionAudioAsset,
        volume: GameplayAudioConfig.kFireballExplosionVolume,
      );
    } catch (e) {
      _handleAudioError('playExplosion', e);
    }
  }

  void playInteraction() {
    try {
      FlameAudio.play(
        GameplayAudioConfig.kInteractionAsset,
        volume: GameplayAudioConfig.kInteractionVolume,
      );
    } catch (e) {
      _handleAudioError('playInteraction', e);
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await FlameAudio.bgm.stop();
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    } catch (e) {
      _handleAudioError('stopBackgroundMusic', e);

      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }

  Future<void> ensureBackgroundMusicPlaying([String? musicTrack]) async {
    try {
      if (!_isMusicEnabled) return;

      final targetTrack =
          musicTrack ?? GameplayAudioConfig.kLettersBackgroundMusicAsset;

      if (!_isBackgroundMusicPlaying ||
          _currentBackgroundTrack != targetTrack) {
        await _startSpecificMusic(targetTrack);
      }
    } catch (e) {
      _handleAudioError('ensureBackgroundMusicPlaying', e);
    }
  }

  Future<void> playSpecificBackgroundMusic(String musicTrack) async {
    try {
      if (!_isMusicEnabled) return;
      await _startSpecificMusic(musicTrack);
    } catch (e) {
      _handleAudioError('playSpecificBackgroundMusic', e);
    }
  }

  Future<void> _startSpecificMusic(String musicTrack) async {
    print('[GameplayAudioManager] Stopping current music...');
    await FlameAudio.bgm.stop();
    print('[GameplayAudioManager] Starting music: $musicTrack');
    try {
      if (AppEnvironment.kPlayBackgroundMusic)
        await FlameAudio.bgm.play(musicTrack);
      _isBackgroundMusicPlaying = true;
      _currentBackgroundTrack = musicTrack;
      print('[GameplayAudioManager] Music started successfully: $musicTrack');
    } catch (e) {
      print('[GameplayAudioManager] Error starting music: $e');
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }

  Future<void> playBackgroundMusic() async {
    try {
      await ensureBackgroundMusicPlaying();
    } catch (e) {
      _handleAudioError('playBackgroundMusic', e);
    }
  }

  Future<void> playBossBackgroundMusic() async {
    try {
      await _startSpecificMusic(GameplayAudioConfig.kBossBackgroundAsset);
    } catch (e) {
      _handleAudioError('playBossBackgroundMusic', e);
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

  void enableMusic() {
    try {
      _isMusicEnabled = true;
    } catch (e) {
      _handleAudioError('enableMusic', e);
    }
  }

  Future<void> disableMusic() async {
    try {
      _isMusicEnabled = false;
      await stopBackgroundMusic();
    } catch (e) {
      _handleAudioError('disableMusic', e);
    }
  }

  void dispose() {
    try {
      FlameAudio.bgm.dispose();
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    } catch (e) {
      _handleAudioError('dispose', e);
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }
}
