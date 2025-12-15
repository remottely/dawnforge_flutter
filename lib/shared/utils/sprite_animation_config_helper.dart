import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_constants.dart';

final class SpriteAnimationConfigHelper {
  SpriteAnimationConfigHelper._();

  static DDSpriteAnimationData createStandardData({
    required int amount,
    required Vector2 textureSize,
    Vector2? texturePosition,
    Vector2? effectiveSize,
  }) => DDSpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    texturePosition: texturePosition,
    effectiveSize: effectiveSize,
    stepTime: SpriteAnimationConstants.kStepTimeStandard,
  );

  static DDSpriteAnimationData createCustomData({
    required int amount,
    required Vector2 textureSize,
    Vector2? texturePosition,
    Vector2? effectiveSize,
    required double stepTime,
    bool loop = true,
  }) => DDSpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    texturePosition: texturePosition,
    effectiveSize: effectiveSize,
    stepTime: stepTime,
    loop: loop,
  );
}

class DDSpriteAnimationData extends SpriteAnimationData {
  /// Tamanho efetivo do sprite que será renderizado.
  /// Se definido, o widget calculará o scale necessário para expandir.
  final Vector2? effectiveSize;

  DDSpriteAnimationData.sequenced({
    required int amount,
    required double stepTime,
    required Vector2 textureSize,
    int? amountPerRow,
    Vector2? texturePosition,
    this.effectiveSize,
    bool loop = true,
  }) : super.variable(
         amount: amount,
         amountPerRow: amountPerRow,
         texturePosition: texturePosition,
         textureSize: textureSize,
         loop: loop,
         stepTimes: List.filled(amount, stepTime),
       );
}

/// Wrapper para SpriteAnimation que mantém o effectiveSize
class DDSpriteAnimation {
  final SpriteAnimation animation;
  final Vector2? effectiveSize;

  DDSpriteAnimation({required this.animation, this.effectiveSize});

  /// Carrega a animação e retorna um Future<DDSpriteAnimation>
  static Future<DDSpriteAnimation> load(
    String src,
    DDSpriteAnimationData data, {
    Images? images,
  }) async {
    final animation = await SpriteAnimation.load(src, data, images: images);
    return DDSpriteAnimation(
      animation: animation,
      effectiveSize: data.effectiveSize,
    );
  }
}
