import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';

class CharacterBasicAttackConfig {
  static Future<SpriteAnimation> loadPlayerExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_basic_attack_right_3.png',
        GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
          amount: 3,
          textureSize: GameplayTileConfig.fTileSizeStandard,
        ),
      );

  static Future<SpriteAnimation> loadEnemyExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_basic_attack_right_3.png',
        GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
          amount: 3,
          textureSize: GameplayTileConfig.fTileSizeStandard,
        ),
      );
}
