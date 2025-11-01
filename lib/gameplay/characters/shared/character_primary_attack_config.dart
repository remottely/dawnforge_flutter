import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';

final class CharacterPrimaryAttackConfig {
  CharacterPrimaryAttackConfig._();

  static Future<SpriteAnimation> loadPlayerExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/player/player_primary_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: GameplayTileConfig.fTileSizeStandard,
        ),
      );

  static Future<SpriteAnimation> loadEnemyExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_primary_attack_right_3.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: GameplayTileConfig.fTileSizeStandard,
        ),
      );
}
