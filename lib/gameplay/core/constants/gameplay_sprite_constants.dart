import 'package:bonfire/bonfire.dart';

/// [GameplaySpriteConstants] responsible for centralizing sprite animation configuration
/// Following Flutter naming conventions for game sprite systems
class GameplaySpriteConstants {
  // Animation timing constants for commonly used configurations
  static const double kDefaultStepTime = 0.1;
  static const double kFastStepTime = 0.05;
  static const double kSlowStepTime = 0.15;

  // Animation frame counts
  static const int kIdleFrames = 4;
  static const int kRunFrames = 6;
  static const int kAttackFrames = 6;
  static const int kGoblinIdleFrames = 6;
  static const int kPlayerIdleFrames = 6;
  static const int kExplosionFrames = 7;
  static const int kSmokeExplosionFrames = 6;
  static const int kFireballFrames = 3;
  static const int kFireballExplosionFrames = 6;
  static const int kTorchDecorationFrames = 6;
  static const int kSpikesDecorationFrames = 10;
  static const int kDoorFrames = 14;

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
}
