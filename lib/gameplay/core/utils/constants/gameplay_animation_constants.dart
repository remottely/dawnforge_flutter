import 'package:bonfire/bonfire.dart';

class GameplayAnimationConstants {
  /// Standard texture size used for player characters.

  /// Standard step time used for most sprite animations.
  static const double _kStandardStepTime = 0.1;

  static SpriteAnimationData standardStepTimeSpriteAnimationConfig({
    required int amount,
    required Vector2 textureSize,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: _kStandardStepTime,
  );
}
