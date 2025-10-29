import 'package:bonfire/bonfire.dart';

class GameplayAnimationConfig {
  static const _kStandardStepTime = 0.1;

  static SpriteAnimationData standardStepTimeSpriteAnimationConfig({
    required int amount,
    required Vector2 textureSize,
  }) => SpriteAnimationData.sequenced(
    amount: amount,
    textureSize: textureSize,
    stepTime: _kStandardStepTime,
  );
}
