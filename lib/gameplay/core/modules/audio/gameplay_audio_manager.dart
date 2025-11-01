import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_environment.dart';
import 'package:flame_audio/flame_audio.dart';

import 'gameplay_audio_config.dart';

final class GameplayAudioManager {
  GameplayAudioManager._();

  static final GameplayAudioManager instance = GameplayAudioManager._();

  bool _isBackgroundMusicEnabled = true;
  bool _isBackgroundMusicPlaying = false;
  String? _currentBackgroundTrack;

  Future<void> initialize() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll(GameplayAudioConfig.kPreloadAudioFiles);
  }

  /// SFX
  void playPlayerPrimaryAttackSfx() {
    FlameAudio.play(
      GameplayAudioConfig.kSfxPlayerAttackAsset,
      volume: GameplayAudioConfig.kPrimaryAttackVolume,
    );
  }

  void playFireballAttackSfx() {
    FlameAudio.play(
      GameplayAudioConfig.kSfxCharacterFireBallAttackAsset,
      volume: GameplayAudioConfig.kCharacterFireballAttackVolume,
    );
  }

  void playEnemyPrimaryAttackSfx() {
    FlameAudio.play(
      GameplayAudioConfig.kSfxEnemyAttackAsset,
      volume: GameplayAudioConfig.kPrimaryAttackVolume,
    );
  }

  void playFireballExplosionSfx() {
    FlameAudio.play(
      GameplayAudioConfig.kSfxCharacterFireballExplosionAsset,
      volume: GameplayAudioConfig.kCharacterFireballExplosionVolume,
    );
  }

  void playConversationInteractionSfx() {
    FlameAudio.play(
      GameplayAudioConfig.kSfxConversationInteractionAsset,
      volume: GameplayAudioConfig.kConversationInteractionVolume,
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
