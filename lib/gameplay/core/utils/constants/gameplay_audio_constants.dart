/// [GameplayAudioConstants] responsible for centralizing audio configuration
/// Following Flutter naming conventions for game audio systems
class GameplayAudioConstants {
  // Volume levels
  static const double kAttackVolume = 0.4;
  static const double kRangeVolume = 0.3;
  static const double kInteractionVolume = 0.4;
  static const double kExplosionVolume = 1.0;

  // Audio asset paths
  static const String kAttackPlayerAsset = 'attack_player.mp3';
  static const String kFireBallAttackAudioAssetPath =
      'fireball_attack_audio.wav';
  static const String kAttackEnemyAsset = 'attack_enemy.mp3';
  static const String kFIreballExplosionAudioAssetPath =
      'fireball_explosion_audio.wav';
  static const String kInteractionAsset = 'sound_interaction.wav';
  static const String kDeathHexBackgroundMusicAsset = 'ro1_death_hex.mp3';
  static const String kLettersBackgroundMusicAsset = 'ro1_letters.mp3';
  static const String kBossBackgroundAsset = 'battle_boss.mp3';

  // Audio file list for preloading
  static const List<String> kAudioFilesToPreload = [
    kAttackPlayerAsset,
    kFireBallAttackAudioAssetPath,
    kAttackEnemyAsset,
    kFIreballExplosionAudioAssetPath,
    kInteractionAsset,
    kDeathHexBackgroundMusicAsset,
    kLettersBackgroundMusicAsset,
    kBossBackgroundAsset,
  ];
}
