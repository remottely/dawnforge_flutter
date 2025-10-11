import 'package:bonfire/bonfire.dart';

/// [SpriteConstants] responsible for centralizing sprite animation configuration
/// Following Flutter naming conventions for game sprite systems
class SpriteConstants {
  // Animation timing constants
  static const double _kDefaultStepTime = 0.1;
  static const double _kFastStepTime = 0.05;
  static const double _kSlowStepTime = 0.15;

  // Animation frame counts
  static const int _kIdleFrames = 4;
  static const int _kRunFrames = 6;
  static const int _kAttackFrames = 6;
  static const int _kGoblinIdleFrames = 6;
  static const int _kGoblinRunFrames = 6;
  static const int _kPlayerIdleFrames = 6;
  static const int _kPlayerRunFrames = 6;
  static const int _kExplosionFrames = 7;
  static const int _kSmokeExplosionFrames = 6;
  static const int _kFireballFrames = 3;
  static const int _kFireballExplosionFrames = 6;
  static const int _kTorchFrames = 6;
  static const int _kSpikesFrames = 10;
  static const int _kDoorFrames = 14;

  // Getter methods for commonly used configurations
  static double get defaultStepTime => _kDefaultStepTime;
  static double get fastStepTime => _kFastStepTime;
  static double get slowStepTime => _kSlowStepTime;

  // Texture size getters that create Vector2 instances
  static Vector2 get playerTextureSize => Vector2(16, 16);
  static Vector2 get enemyTextureSize => Vector2(16, 16);
  static Vector2 get bossTextureSize => Vector2(32, 36);
  static Vector2 get miniBossTextureSize => Vector2(16, 24);
  static Vector2 get npcKidTextureSize => Vector2(16, 22);
  static Vector2 get npcWizardTextureSize => Vector2(16, 22);
  static Vector2 get effectTextureSize => Vector2(16, 16);
  static Vector2 get fireballTextureSize => Vector2(23, 23);
  static Vector2 get explosionTextureSize => Vector2(32, 32);
  static Vector2 get itemTextureSize => Vector2(16, 16);
  static Vector2 get doorTextureSize => Vector2(32, 32);

  static int get idleFrames => _kIdleFrames;
  static int get runFrames => _kRunFrames;
  static int get attackFrames => _kAttackFrames;
  static int get goblinIdleFrames => _kGoblinIdleFrames;
  static int get goblinRunFrames => _kGoblinRunFrames;
  static int get playerIdleFrames => _kPlayerIdleFrames;
  static int get playerRunFrames => _kPlayerRunFrames;
  static int get explosionFrames => _kExplosionFrames;
  static int get smokeExplosionFrames => _kSmokeExplosionFrames;
  static int get fireballFrames => _kFireballFrames;
  static int get fireballExplosionFrames => _kFireballExplosionFrames;
  static int get torchFrames => _kTorchFrames;
  static int get spikesFrames => _kSpikesFrames;
  static int get doorFrames => _kDoorFrames;
}
