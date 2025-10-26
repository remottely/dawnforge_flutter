import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

class GameplayAnimationConstants {
  static const double _kStandardStepTime = 0.1;

  static const int kIdleFrames = 4;
  static const int kRunFrames = 6;
  static const int kAttackFrames = 6;
  static const int kGoblinIdleFrames = 6;
  static const int kPlayerIdleFrames = 6;
  static const int kExplosionFrames = 7;
  static const int kSmokeExplosionFrames = 6;
  static const int kFireballFrames = 3;
  static const int kFireballExplosionFrames = 6;

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
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: _kStandardStepTime,
  );
}
