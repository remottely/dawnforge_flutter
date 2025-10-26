import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';

class CharacterBasicAttackConfig {
  static Future<SpriteAnimation> loadPlayerAttackAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_basic_attack_right_3.png',
        GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplayAnimationConstants.kAttackFrames,
          textureSize: GameplayAnimationConstants.effectTextureSize,
        ),
      );

  static Future<SpriteAnimation> loadEnemyAttackAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_basic_attack_right_3.png',
        GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplayAnimationConstants.kAttackFrames,
          textureSize: GameplayAnimationConstants.effectTextureSize,
        ),
      );
}
