import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class NpcSpriteAnimations {
  static final Vector2 _npcKidTextureSize = Vector2(16, 22);
  static final Vector2 _npcWizardTextureSize = Vector2(16, 22);

  static Future<SpriteAnimation> kidIdleLeft() => SpriteAnimation.load(
    'gameplay/characters/npcs/kid_idle_npc_left_4.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: _npcKidTextureSize,
    ),
  );

  static Future<SpriteAnimation> wizardIdleLeft() => SpriteAnimation.load(
    'gameplay/characters/npcs/wizard_idle_npc_left_4.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: _npcWizardTextureSize,
    ),
  );
}
