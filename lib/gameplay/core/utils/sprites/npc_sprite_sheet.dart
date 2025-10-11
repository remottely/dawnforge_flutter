import 'package:bonfire/bonfire.dart';

import '../../constants/sprite_constants.dart';

/// [NpcSpriteSheet] responsible for providing NPC character sprite animations
/// Following Flutter naming conventions for NPC sprite systems
class NpcSpriteSheet {
  /// Creates kid idle left animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> kidIdleLeft() => SpriteAnimation.load(
    'npc/kid_idle_left.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kIdleFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.npcKidTextureSize,
    ),
  );

  /// Creates wizard idle left animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> wizardIdleLeft() => SpriteAnimation.load(
    'npc/wizard_idle_left.png',
    SpriteAnimationData.sequenced(
      amount: SpriteConstants.kIdleFrames,
      stepTime: SpriteConstants.kDefaultStepTime,
      textureSize: SpriteConstants.npcWizardTextureSize,
    ),
  );
}
