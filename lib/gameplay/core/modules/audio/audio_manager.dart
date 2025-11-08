import 'package:darkness_dungeon/gameplay/core/utils/app_environment.dart';
import 'package:flame_audio/flame_audio.dart';

import 'audio_config.dart';

final class AudioManager {
  AudioManager._();

  static final AudioManager instance = AudioManager._();

  bool _isBackgroundMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  Future<void> initialize() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(AudioConfig.kPreloadAudioFiles);
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
    await FlameAudio.bgm.stop();
    _isBackgroundMusicPlaying = false;
    _currentBackgroundTrack = null;
  }

  Future<void> playBackgroundMusic(String musicTrack) async {
    stopBackgroundMusic();
    if (!_isBackgroundMusicEnabled) return;
    if (!_isBackgroundMusicPlaying || _currentBackgroundTrack != musicTrack) {
      if (AppEnvironment.kPlayBackgroundMusic) {
        await FlameAudio.bgm.play(musicTrack);
        _isBackgroundMusicPlaying = true;
        _currentBackgroundTrack = musicTrack;
      }
    }
    _isBackgroundMusicPlaying = false;
    _currentBackgroundTrack = null;
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
