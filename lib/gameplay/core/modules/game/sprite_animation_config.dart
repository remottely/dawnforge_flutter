import 'package:bonfire/bonfire.dart';

final class SpriteAnimationConfig {
  SpriteAnimationConfig._();

  static const double _kStandardStepTime = 0.1;

  static const double kSmallSize = 50.0;
  static const double kStandardSize = 100.0;
  static const double kLargeSize = 150.0;
  static const double kExtraLargeSize = 200.0;

  static SpriteAnimationData createStandardData({
    required int amount,
    required Vector2 textureSize,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: _kStandardStepTime,
  );
}
