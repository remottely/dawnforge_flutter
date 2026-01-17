import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';
import 'package:flutter/foundation.dart';

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
    required double stepTime,
    Vector2? texturePosition,
    bool loop = true,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    texturePosition: texturePosition,
    stepTime: stepTime,
    loop: loop,
  );

  static Future<SpriteAnimation> loadAnimationFromTextureAtlasModernFarm({
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

  static Future<Sprite> loadSpriteFromTextureAtlasModernFarm({
    required String assetPath,
    required Vector2 spriteSize,
    required int frameIndex,
    required int rowIndex,
    int skipFirstFrames = 0,
  }) {
    final adjustedFrameIndex = frameIndex + skipFirstFrames;

    final srcPosition = Vector2(
      adjustedFrameIndex * spriteSize.x,
      rowIndex * spriteSize.y,
    );

    return Sprite.load(
      assetPath,
      srcPosition: srcPosition,
      srcSize: spriteSize,
    );
  }

  static Future<SpriteAnimation> loadAnimationFromTextureAtlasSmallBurg({
    required String assetPath,
    required Vector2 textureSize,
    required int totalFrames,
    double stepTime = SpriteAnimationConstants.kStepTimeStandard,
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

    try {
      // GameLogger.info('[SpriteAnimationConfigHelper] Carregando asset: $assetPath');
      return SpriteAnimation.load(
        assetPath,
        createCustomData(
          stepTime: stepTime,
          amount: usedFrames,
          textureSize: textureSize,
          texturePosition: Vector2(
            framePositionXPadding +
                (framePositionX + skipFirstFrames) * textureSize.x,
            framePositionYPadding + (framePositionY),
          ),
        ),
      );
    } catch (e, stack) {
      GameLogger.error(
        '[SpriteAnimationConfigHelper] ERRO ao carregar asset: $assetPath.\nErro: $e.\nStack: $stack',
      );
      rethrow;
    }
  }
}
