import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_constants.dart';

final class SpriteAnimationConfigHelper {
  SpriteAnimationConfigHelper._();

  static SpriteAnimationData createStandardData({
    required int amount,
    required Vector2 textureSize,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: SpriteAnimationConstants.kStepTimeStandard,
  );

  static SpriteAnimationData createCustomData({
    required int amount,
    required Vector2 textureSize,
    required double stepTime,
    bool loop = true,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: stepTime,
    loop: loop,
  );
}
