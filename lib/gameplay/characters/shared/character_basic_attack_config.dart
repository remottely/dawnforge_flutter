import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class CharacterBasicAttackConfig {
  static Future<SpriteAnimation> playerBasicAttackRight3() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_basic_attack_right_3.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kAttackFrames,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );
}
