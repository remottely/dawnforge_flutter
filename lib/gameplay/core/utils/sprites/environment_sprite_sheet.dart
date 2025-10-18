import 'package:bonfire/bonfire.dart';

import '../../constants/gameplay_sprite_constants.dart';

/// [EnvironmentSpriteSheet] responsible for providing sprite animations for environment elements
/// Following Flutter naming conventions for environment sprite systems
class EnvironmentSpriteSheet {
  /// Creates doorDecoration opening animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> openTheDoor() => SpriteAnimation.load(
    'items/door_open.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kDoorFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.doorTextureSize,
    ),
  );

  /// Creates spikes animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> spikesDecoration() => SpriteAnimation.load(
    'items/spikes_decoration.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kSpikesDecorationFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.itemTextureSize,
    ),
  );

  /// Creates torch flame animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> torch() => SpriteAnimation.load(
    'items/torch_decoration_spritesheet.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kTorchDecorationFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.itemTextureSize,
    ),
  );
}
