import 'package:bonfire/bonfire.dart';

final class SpriteAnimationConfig {
  SpriteAnimationConfig._();

  static const double _kStepTimeStandard = 0.1;
  static const double kStepTimeSlow = 0.2;

  static const double kSizeSmall = 50.0;
  static const double kSizeStandard = 100.0;
  static const double kSizeLarge = 150.0;
  static const double kSizeExtraLarge = 200.0;

  static SpriteAnimationData createStandardData({
    required int amount,
    required Vector2 textureSize,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: _kStepTimeStandard,
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
