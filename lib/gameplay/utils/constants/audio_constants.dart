/// [AudioConstants] responsible for centralizing audio configuration
/// Following Flutter naming conventions for game audio systems
class AudioConstants {
  // Volume levels
  static const double _kAttackVolume = 0.4;
  static const double _kRangeVolume = 0.3;
  static const double _kInteractionVolume = 0.4;
  static const double _kExplosionVolume = 1.0;

  // Audio asset paths
  static const String _kAttackPlayerAsset = 'attack_player.mp3';
  static const String _kAttackFireBallAsset = 'attack_fire_ball.wav';
  static const String _kAttackEnemyAsset = 'attack_enemy.mp3';
  static const String _kExplosionAsset = 'explosion.wav';
  static const String _kInteractionAsset = 'sound_interaction.wav';
  static const String _kBackgroundMusicAsset = 'ro1_death_hex.mp3';
  static const String _kBossBackgroundAsset = 'battle_boss.mp3';

  // Audio file list for preloading
  static const List<String> _kAudioFilesToPreload = [
    _kAttackPlayerAsset,
    _kAttackFireBallAsset,
    _kAttackEnemyAsset,
    _kExplosionAsset,
    _kInteractionAsset,
  ];

  // Getter methods for volumes
  static double get attackVolume => _kAttackVolume;
  static double get rangeVolume => _kRangeVolume;
  static double get interactionVolume => _kInteractionVolume;
  static double get explosionVolume => _kExplosionVolume;

  // Getter methods for asset paths
  static String get attackPlayerAsset => _kAttackPlayerAsset;
  static String get attackFireBallAsset => _kAttackFireBallAsset;
  static String get attackEnemyAsset => _kAttackEnemyAsset;
  static String get explosionAsset => _kExplosionAsset;
  static String get interactionAsset => _kInteractionAsset;
  static String get backgroundMusicAsset => _kBackgroundMusicAsset;
  static String get bossBackgroundAsset => _kBossBackgroundAsset;

  // Getter for preload list
  static List<String> get audioFilesToPreload => _kAudioFilesToPreload;
}
