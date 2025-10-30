class GameplayAudioConfig {
  static const kBasicAttackVolume = 0.4;
  static const kCharacterFireballAttackVolume = 0.3;
  static const kCharacterFireballExplosionVolume = 1.0;
  static const kConversationInteractionVolume = 0.4;

  static const kSfxPlayerAttackAsset = 'sfx/sfx_player_attack.mp3';
  static const kSfxCharacterFireBallAttackAsset =
      'sfx/sfx_character_fireball_attack.wav';
  static const kSfxEnemyAttackAsset = 'sfx/sfx_enemy_attack.mp3';
  static const kSfxCharacterFireballExplosionAsset =
      'sfx/sfx_character_fireball_explosion.wav';
  static const kSfxConversationInteractionAsset =
      'sfx/sfx_conversation_interaction.wav';
  static const kMusicRo1DeathHexBackgroundAsset =
      'music/music_ro1_death_hex_background.mp3';
  static const kMusicRo1LettersBackgroundAsset =
      'music/music_ro1_letters_background.mp3';
  static const kMusicBossBattleBackgroundAsset =
      'music/music_boss_battle_background.mp3';

  static const kPreloadAudioFiles = [
    kSfxPlayerAttackAsset,
    kSfxCharacterFireBallAttackAsset,
    kSfxEnemyAttackAsset,
    kSfxCharacterFireballExplosionAsset,
    kSfxConversationInteractionAsset,
    kMusicRo1DeathHexBackgroundAsset,
    kMusicRo1LettersBackgroundAsset,
    kMusicBossBattleBackgroundAsset,
  ];
}
