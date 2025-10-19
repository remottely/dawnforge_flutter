import 'package:bonfire/bonfire.dart';

import '../../core/utils/constants/gameplay_sprite_constants.dart';

/// [EnvironmentSpriteAnimation] responsible for providing sprite animations for environment elements
/// Following Flutter naming conventions for environment sprite systems
class EnvironmentSpriteAnimation {
  /// Creates doorDecoration opening animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> doorDecorationOpening14() =>
      SpriteAnimation.load(
        'decorations/door_decoration_opening_14.png',
        SpriteAnimationData.sequenced(
          amount: 14,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: Vector2(32, 32),
        ),
      );

  /// Creates spike traps animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> spikeTrapDecoration10() =>
      SpriteAnimation.load(
        'decorations/spike_trap_decoration_10.png',
        SpriteAnimationData.sequenced(
          amount: 10,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: Vector2(16, 16),
        ),
      );

  /// Creates torch flame animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> torchDecoration6() => SpriteAnimation.load(
    'decorations/torch_decoration_6.png',
    SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: Vector2(16, 16),
    ),
  );
}
