import 'package:bonfire/bonfire.dart';

import '../../constants/sprite_constants.dart';

/// [EnvironmentSpriteSheet] responsible for providing sprite animations for environment elements
/// Following Flutter naming conventions for environment sprite systems
class EnvironmentSpriteSheet {
  /// Creates door opening animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> openTheDoor() => SpriteAnimation.load(
    'items/door_open.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kDoorFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.doorTextureSize,
    ),
  );

  /// Creates spikes animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> spikes() => SpriteAnimation.load(
    'items/spikes.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kSpikesFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.itemTextureSize,
    ),
  );

  /// Creates torch flame animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> torch() => SpriteAnimation.load(
    'items/torch_spritesheet.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kTorchFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.itemTextureSize,
    ),
  );
}
