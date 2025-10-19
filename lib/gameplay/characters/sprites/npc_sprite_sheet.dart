import 'package:bonfire/bonfire.dart';

import '../../core/utils/constants/gameplay_sprite_constants.dart';

/// [NpcSpriteSheet] responsible for providing NPC character sprite animations
/// Following Flutter naming conventions for NPC sprite systems
class NpcSpriteSheet {
  /// Creates kid idle left animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> kidIdleLeft() => SpriteAnimation.load(
    'npc/kid_idle_left.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.npcKidTextureSize,
    ),
  );

  /// Creates wizard idle left animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> wizardIdleLeft() => SpriteAnimation.load(
    'npc/wizard_idle_left.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.npcWizardTextureSize,
    ),
  );
}
