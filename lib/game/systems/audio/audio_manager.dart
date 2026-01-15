import 'package:dawnforge/game/utils/app_environment.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:dawnforge/core/utils/game_logger.dart';

import 'audio_def.dart';

final class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  bool _isBackgroundMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  double musicVolume = 0.5; // TODO(Kevin): save/load from cache

  void changeMusicVolume(double newVolume) {
    musicVolume = newVolume;

    // Só tenta mudar o volume se houver música tocando
    if (_isBackgroundMusicPlaying &&
        FlameAudio.bgm.audioPlayer.state == PlayerState.playing) {
      FlameAudio.bgm.audioPlayer.setVolume(musicVolume);
      GameLogger.debug('[AudioManager] Volume changed to: $musicVolume');
    }
  }

  Future<void> initialize() async {
    GameLogger.debug('[AudioManager] Initializing...');
    FlameAudio.bgm.initialize();
    for (final asset in AudioDef.kPreloadAudioFiles) {
      try {
        await FlameAudio.audioCache.load(asset);
      } catch (e) {
        GameLogger.warning(
          '[AudioManager] Skipping missing/invalid asset: $asset -> $e',
        );
      }
    }
    GameLogger.debug('[AudioManager] Initialized successfully');
  }

  /// SFX
  void playPlayerPrimaryAttackSfx(int comboStep) {
    FlameAudio.play(
      comboStep == 0
          ? AudioDef.kSfxPlayerAttack1Asset
          : comboStep == 1
          ? AudioDef.kSfxPlayerAttack2Asset
          : AudioDef.kSfxPlayerAttack3Asset,
      volume: AudioDef.kPrimaryAttackVolume,
    );
  }

  void playFireballAttackSfx() {
    FlameAudio.play(
      AudioDef.kSfxCharacterFireBallAttackAsset,
      volume: AudioDef.kCharacterFireballAttackVolume,
    );
  }

  void playEnemyPrimaryAttackSfx() {
    FlameAudio.play(
      AudioDef.kSfxEnemyAttackAsset,
      volume: AudioDef.kPrimaryAttackVolume,
    );
  }

  void playFireballExplosionSfx() {
    FlameAudio.play(
      AudioDef.kSfxCharacterFireballExplosionAsset,
      volume: AudioDef.kCharacterFireballExplosionVolume,
    );
  }

  void playConversationInteractionSfx() {
    FlameAudio.play(
      AudioDef.kSfxConversationInteractionAsset,
      volume: AudioDef.kConversationInteractionVolume,
    );
  }

  /// Background Music
  Future<void> stopBackgroundMusic() async {
    GameLogger.debug(
      '[AudioManager] Stopping music. Current: $_currentBackgroundTrack',
    );
    await FlameAudio.bgm.stop();
    _isBackgroundMusicPlaying = false;
    _currentBackgroundTrack = null;
  }

  Future<void> playBackgroundMusic(String musicTrack) async {
    GameLogger.debug(
      '[AudioManager] playBackgroundMusic called with: $musicTrack',
    );
    GameLogger.debug(
      '[AudioManager] Current state - playing: $_isBackgroundMusicPlaying, track: $_currentBackgroundTrack',
    );

    // Verifica se deve tocar música
    if (!_isBackgroundMusicEnabled) {
      GameLogger.info('[AudioManager] Background music disabled, skipping');
      return;
    }

    if (!AppEnvironment.kPlayBackgroundMusic) {
      GameLogger.info(
        '[AudioManager] AppEnvironment.kPlayBackgroundMusic is false, skipping',
      );
      return;
    }

    if (_isBackgroundMusicPlaying && _currentBackgroundTrack == musicTrack)
      return;

    if (_isBackgroundMusicPlaying) {
      await stopBackgroundMusic();
    }

    try {
      GameLogger.debug(
        '[AudioManager] Starting to play: $musicTrack with volume: $musicVolume',
      );

      // CORREÇÃO: Passar o volume diretamente no play()
      await FlameAudio.bgm.play(musicTrack, volume: musicVolume);

      _isBackgroundMusicPlaying = true;
      _currentBackgroundTrack = musicTrack;

      GameLogger.debug(
        '[AudioManager] Successfully started playing: $musicTrack',
      );
    } catch (e) {
      GameLogger.error('[AudioManager] ERROR playing music: $e');
      _isBackgroundMusicPlaying = false;
      _currentBackgroundTrack = null;
    }
  }

  void pauseBackgroundMusic() {
    if (_isBackgroundMusicPlaying) {
      FlameAudio.bgm.pause();
    }
  }

  void resumeBackgroundMusic() {
    if (_isBackgroundMusicPlaying) {
      FlameAudio.bgm.resume();
    }
  }

  void enableBackgroundMusic() {
    _isBackgroundMusicEnabled = true;
    resumeBackgroundMusic();
  }

  void disableBackgroundMusic() {
    _isBackgroundMusicEnabled = false;
    pauseBackgroundMusic();
  }

  void disposeBackgroundMusic() {
    FlameAudio.bgm.dispose();
    _isBackgroundMusicPlaying = false;
    _currentBackgroundTrack = null;
  }
}
