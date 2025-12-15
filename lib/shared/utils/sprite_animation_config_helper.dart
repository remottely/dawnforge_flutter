import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_constants.dart';

final class SpriteAnimationConfigHelper {
  SpriteAnimationConfigHelper._();

  static SpriteAnimationData createStandardData({
    required int amount,
    required Vector2 textureSize,
    Vector2? texturePosition,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    texturePosition: texturePosition,
    stepTime: SpriteAnimationConstants.kStepTimeStandard,
  );

  static SpriteAnimationData createCustomData({
    required int amount,
    required Vector2 textureSize,
    Vector2? texturePosition,
    required double stepTime,
    bool loop = true,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    texturePosition: texturePosition,
    stepTime: stepTime,
    loop: loop,
  );
}
