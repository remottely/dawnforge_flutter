import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

/// [GameplaySpriteConstants] responsible for centralizing sprite animation configuration
/// Following Flutter naming conventions for game sprite systems
class GameplaySpriteConstants {
  /// Asset path for key icon sprite
  static const String kDoorKeyDecorationAssetPath =
      'gameplay/environment/decorations/door_key_decoration_1.png';

  // Animation timing constants for commonly used configurations
  static const double kStandardStepTime = 0.1;
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
  static final Vector2 playerTextureSize = GameplayConstants.kTileSizeStandard;
  static final Vector2 enemyTextureSize = GameplayConstants.kTileSizeStandard;
  static final Vector2 bossTextureSize = Vector2(32, 36);
  static final Vector2 miniBossTextureSize = Vector2(16, 24);
  static final Vector2 effectTextureSize = GameplayConstants.kTileSizeStandard;
  static final Vector2 fireballTextureSize = Vector2(23, 23);
  static final Vector2 explosionTextureSize =
      GameplayConstants.kTileSizeExtraLarge;
  static final Vector2 barrelDecorationTextureSize = Vector2(23, 23);

  static SpriteAnimationData defaultStepTimeSpriteAnimationData({
    required int amount,
    required Vector2 textureSize,
    // double stepTime = kStandardStepTime,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    // stepTime: stepTime,
    stepTime: kStandardStepTime,
  );
}
