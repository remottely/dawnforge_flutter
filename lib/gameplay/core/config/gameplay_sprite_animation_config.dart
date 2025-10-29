import 'package:bonfire/bonfire.dart';

class GameplaySpriteAnimationConfig {
  static const _kStandardStepTime = 0.1;

  static const kSmallSize = 50.0;
  static const kStandardSize = 100.0;
  static const kLargeSize = 150.0;
  static const kExtraLargeSize = 200.0;

  static SpriteAnimationData createStandardData({
    required int amount,
    required Vector2 textureSize,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: _kStandardStepTime,
  );
}
