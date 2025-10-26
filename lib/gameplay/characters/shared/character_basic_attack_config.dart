import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

class CharacterBasicAttackConfig {
  static Future<SpriteAnimation> loadPlayerExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_basic_attack_right_3.png',
        GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
          amount: 3,
          textureSize: GameplayConstants.fTileSizeStandard,
        ),
      );

  static Future<SpriteAnimation> loadEnemyExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_basic_attack_right_3.png',
        GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
          amount: 3,
          textureSize: GameplayConstants.fTileSizeStandard,
        ),
      );
}
