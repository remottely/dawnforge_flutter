class GameplayAudioConstants {
  static const double kAttackVolume = 0.4;
  static const double kRangeVolume = 0.3;
  static const double kInteractionVolume = 0.4;
  static const double kFireballExplosionVolume = 1.0;

  static const String kAttackPlayerAsset = 'attack_player.mp3';
  static const String kFireBallAttackAudioAssetPath =
      'fireball_attack_audio.wav';
  static const String kAttackEnemyAsset = 'attack_enemy.mp3';
  static const String kFireballExplosionAudioAssetPath =
      'fireball_explosion_audio.wav';
  static const String kInteractionAsset = 'sound_interaction.wav';
  static const String kDeathHexBackgroundMusicAsset = 'ro1_death_hex.mp3';
  static const String kLettersBackgroundMusicAsset = 'ro1_letters.mp3';
  static const String kBossBackgroundAsset = 'battle_boss.mp3';

  static const List<String> kAudioFilesToPreload = [
    kAttackPlayerAsset,
    kFireBallAttackAudioAssetPath,
    kAttackEnemyAsset,
    kFireballExplosionAudioAssetPath,
    kInteractionAsset,
    kDeathHexBackgroundMusicAsset,
    kLettersBackgroundMusicAsset,
    kBossBackgroundAsset,
  ];
}
