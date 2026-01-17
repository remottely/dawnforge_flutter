final class AudioDef {
  AudioDef._();

  static const double kPrimaryAttackVolume = 0.4;
  static const double kCharacterFireballAttackVolume = 0.3;
  static const double kCharacterFireballExplosionVolume = 1.0;
  static const double kConversationInteractionVolume = 0.4;

  // static const String kSfxPlayerAttackAsset = 'sfx/sfx_player_attack.mp3';
  static const String kSfxPlayerAttack1Asset =
      'sfx/combat/primary_attack_1.wav';
  static const String kSfxPlayerAttack2Asset =
      'sfx/combat/primary_attack_2.wav';
  static const String kSfxPlayerAttack3Asset =
      'sfx/combat/primary_attack_3.wav';

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

  // static const String backgroundMusic1 = 'music/Keys Of Moon - Enchanted.mp3';

  // static const String bgMusicFarm = 'bg/music/farm - PhaseShift.mp3';
  // static const String bgMusicForest = 'bg/music/forest - Savfk - Rounding.mp3';
  // static const String bgMusicTown = 'bg/music/town - Scott Buckley - Clarion.mp3';
  // static const String bgMusicLake =
  //     'bg/music/lake - Justin Allan Arnold - Antigone.mp3';
  // static const String bgMusicBeach = 'bg/music/beach - Glitch - Prehistory.mp3';
  static const String bgMusicCaveBoss =
      'bg/music/cave_boss - RitesOfPassage.mp3';
  static const String bgMusicGameOverSuccess =
      'bg/music/game_over_success - Scott Buckley - Clarion.ogg';

  static const String bgMusicFarm = 'maps/farm/bgm/Pixverses - Big Helmet.ogg';
  static const String bgMusicForest =
      'maps/forest/bgm/Pixverses - A Green Pig.ogg';
  static const String bgMusicTown =
      'maps/town/bgm/Pixverses - A Lonely Cherry Tree.ogg';
  static const String bgMusicLake =
      'maps/lake/bgm/Pixverses - The Most Powerful Chicken.ogg';
  static const String bgMusicBeach =
      'maps/beach/bgm/Pixverses - A Lost Soul.ogg';
  static const String bgMusicCave =
      'maps/cave/bgm/Pixverses - A Midnight Bat.ogg';

  static const List<String> kPreloadAudioFiles = [
    // kSfxPlayerAttackAsset,
    kSfxPlayerAttack1Asset,
    kSfxPlayerAttack2Asset,
    kSfxPlayerAttack3Asset,
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
    bgMusicCave,
    bgMusicCaveBoss,
    bgMusicGameOverSuccess,
  ];
}
