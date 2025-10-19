import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// [GameplaySpriteConstants] responsible for centralizing sprite animation configuration
/// Following Flutter naming conventions for game sprite systems
class GameplaySpriteConstants {
  /// Asset path for key icon sprite
  static const String kDoorKeyDecorationAssetPath =
      'decorations/door_key_decoration_1.png';

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

  // Texture size getters that create Vector2 instances
  static Vector2 get playerTextureSize => GameplayConstants.kDefaultVectorSize;
  static Vector2 get enemyTextureSize => GameplayConstants.kDefaultVectorSize;
  static Vector2 get bossTextureSize => Vector2(32, 36);
  static Vector2 get miniBossTextureSize => Vector2(16, 24);
  static Vector2 get npcKidTextureSize => Vector2(16, 22);
  static Vector2 get npcWizardTextureSize => Vector2(16, 22);
  static Vector2 get effectTextureSize => GameplayConstants.kDefaultVectorSize;
  static Vector2 get fireballTextureSize => Vector2(23, 23);
  static Vector2 get explosionTextureSize =>
      GameplayConstants.kCurrentVectorSize;
  static Vector2 get barrelDecorationTextureSize => Vector2(23, 23);
}
