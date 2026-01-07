final class AudioDef {
  AudioDef._();

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
  // static const String
  // kMusicRo1DeathHexBackgroundAsset = // TODO(Kevin): change this name
  //     // 'music/music_gameplay_background.mp3'; // TODO(Kevin): put it back, or change the music
  //     'music/music_ro1_death_hex_background.mp3';
  // static const String
  // kMusicRo1LettersBackgroundAsset = // TODO(Kevin): change this name
  //     // 'music/music_gameplay_background.mp3'; // TODO(Kevin): put it back, or change the music
  //     'music/music_ro1_death_hex_background.mp3';
  // static const String
  // kMusicBossBattleBackgroundAsset = // TODO(Kevin): change this name
  //     // 'music/music_boss_battle_background.mp3'; // TODO(Kevin): put it back, or change the music
  //     'music/music_ro1_letters_background.mp3';

  // static const backgroundMusic1 = 'music/Keys Of Moon - Enchanted.mp3';

  static const bgMusicFarm = 'bg/music/farm - PhaseShift.mp3';
  static const bgMusicTown = 'bg/music/town - Scott Buckley - Clarion.mp3';
  static const bgMusicForest = 'bg/music/forest - Savfk - Rounding.mp3';
  static const bgMusicLake =
      'bg/music/lake - Justin Allan Arnold - Antigone.mp3';
  static const bgMusicBeach = 'bg/music/beach - Glitch - Prehistory.mp3';
  static const bgMusicCaveBoss = 'bg/music/cave_boss - RitesOfPassage.mp3';

  static const List<String> kPreloadAudioFiles = [
    kSfxPlayerAttackAsset,
    kSfxCharacterFireBallAttackAsset,
    kSfxEnemyAttackAsset,
    kSfxCharacterFireballExplosionAsset,
    kSfxConversationInteractionAsset,
    // backgroundMusic1,
    // kMusicRo1DeathHexBackgroundAsset,
    // kMusicRo1LettersBackgroundAsset,
    // kMusicBossBattleBackgroundAsset,
    bgMusicFarm,
    bgMusicTown,
    bgMusicForest,
    bgMusicLake,
    bgMusicBeach,
    bgMusicCaveBoss,
  ];
}
