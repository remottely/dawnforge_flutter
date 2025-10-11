import 'package:bonfire/bonfire.dart';

import '../../constants/gameplay_sprite_constants.dart';

/// [EnvironmentSpriteSheet] responsible for providing sprite animations for environment elements
/// Following Flutter naming conventions for environment sprite systems
class EnvironmentSpriteSheet {
  /// Creates door opening animation
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
  static Future<SpriteAnimation> spikes() => SpriteAnimation.load(
    'items/spikes.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kSpikesFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.itemTextureSize,
    ),
  );

  /// Creates torch flame animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> torch() => SpriteAnimation.load(
    'items/torch_spritesheet.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kTorchFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.itemTextureSize,
    ),
  );
}
