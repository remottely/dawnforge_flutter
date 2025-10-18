import 'package:bonfire/bonfire.dart';

import '../../constants/gameplay_sprite_constants.dart';

/// [EnvironmentSpriteSheet] responsible for providing sprite animations for environment elements
/// Following Flutter naming conventions for environment sprite systems
class EnvironmentSpriteSheet {
  /// Creates doorDecoration opening animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> openTheDoor() => SpriteAnimation.load(
    'decorations/door_decoration_opening.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kDoorFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.doorTextureSize,
    ),
  );

  /// Creates spike traps animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> spikeTrapDecoration() => SpriteAnimation.load(
    'decorations/spike_trap_decoration.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kSpikeTrapDecorationFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.itemTextureSize,
    ),
  );

  /// Creates torch flame animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> torchDecoration() => SpriteAnimation.load(
    'decorations/torch_decoration.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kTorchDecorationFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.itemTextureSize,
    ),
  );
}
