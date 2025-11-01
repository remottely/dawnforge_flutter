class GameplayAudioConfig {
  static const double kPrimaryAttackVolume = 0.4;
  static const double kCharacterFireballAttackVolume = 0.3;
  static const double kCharacterFireballExplosionVolume = 1.0;
  static const double kConversationInteractionVolume = 0.4;

  static const String kSfxPlayerAttackAsset = 'sfx/sfx_player_attack.mp3';
  static const String kSfxCharacterFireBallAttackAsset =
      'sfx/sfx_character_fireball_attack.wav';
  static const String kSfxEnemyAttackAsset = 'sfx/sfx_enemy_attack.mp3';
  static const String kSfxCharacterFireballExplosionAsset =
      'sfx/sfx_character_fireball_explosion.wav';
  static const String kSfxConversationInteractionAsset =
      'sfx/sfx_conversation_interaction.wav';
  static const String kMusicRo1DeathHexBackgroundAsset =
      'music/music_ro1_death_hex_background.mp3';
  static const String kMusicRo1LettersBackgroundAsset =
      'music/music_ro1_letters_background.mp3';
  static const String kMusicBossBattleBackgroundAsset =
      'music/music_boss_battle_background.mp3';

  static const List<String> kPreloadAudioFiles = [
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
