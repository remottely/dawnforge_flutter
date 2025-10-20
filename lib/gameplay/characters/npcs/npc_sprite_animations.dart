import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class NpcSpriteAnimations {
  static Future<SpriteAnimation> kidIdleLeft() => SpriteAnimation.load(
    'gameplay/characters/npcs/kid_idle_left.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.npcKidTextureSize,
    ),
  );

  static Future<SpriteAnimation> wizardIdleLeft() => SpriteAnimation.load(
    'gameplay/characters/npcs/wizard_idle_left.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.npcWizardTextureSize,
    ),
  );
}
