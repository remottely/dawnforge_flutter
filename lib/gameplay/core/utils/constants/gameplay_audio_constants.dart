class GameplayAudioConstants {
  static const kAttackVolume = 0.4;
  static const kRangeVolume = 0.3;
  static const kInteractionVolume = 0.4;
  static const kFireballExplosionVolume = 1.0;

  static const kAttackPlayerAsset = 'attack_player.mp3';
  static const kFireBallAttackAudioAsset = 'fireball_attack_audio.wav';
  static const kAttackEnemyAsset = 'attack_enemy.mp3';
  static const kFireballExplosionAudioAsset = 'fireball_explosion_audio.wav';
  static const kInteractionAsset = 'sound_interaction.wav';
  static const kDeathHexBackgroundMusicAsset = 'ro1_death_hex.mp3';
  static const kLettersBackgroundMusicAsset = 'ro1_letters.mp3';
  static const kBossBackgroundAsset = 'battle_boss.mp3';

  static const kAudioFilesToPreload = [
    kAttackPlayerAsset,
    kFireBallAttackAudioAsset,
    kAttackEnemyAsset,
    kFireballExplosionAudioAsset,
    kInteractionAsset,
    kDeathHexBackgroundMusicAsset,
    kLettersBackgroundMusicAsset,
    kBossBackgroundAsset,
  ];
}
