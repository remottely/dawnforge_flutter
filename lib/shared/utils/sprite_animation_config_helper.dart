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

  static Future<SpriteAnimation> loadAnimationFromSheet({
    required String assetPath,
    required Vector2 textureSize,
    required int totalFrames,
    required double framePositionX,
    required double framePositionY,
    int skipFirstFrames = 0,
    double framePositionYPadding = 0,
    double framePositionXPadding = 0,
  }) {
    final int usedFrames = totalFrames - skipFirstFrames;
    assert(
      usedFrames > 0,
      'usedFrames must be > 0. '
      'totalFrames=$totalFrames, skipFirstFrames=$skipFirstFrames',
    );

    return SpriteAnimation.load(
      assetPath,
      createStandardData(
        amount: usedFrames,
        textureSize: textureSize,
        texturePosition: Vector2(
          framePositionXPadding +
              (framePositionX + skipFirstFrames) * textureSize.x,
          framePositionYPadding + 32 + (framePositionY * 32),
        ),
      ),
    );
  }
}
