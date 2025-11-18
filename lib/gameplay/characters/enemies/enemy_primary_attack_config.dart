import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

final class EnemyPrimaryAttackConfig {
  EnemyPrimaryAttackConfig._();

  static final Vector2 kEnemyPrimaryAttackFxSize = TileConstants.tileSizeSmall;

  static Future<SpriteAnimation> createEnemyExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_primary_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: TileConstants.tileSizeStandard,
        ),
      );

  static void playEnemyExecutionSfx() =>
      AudioManager.instance.playEnemyPrimaryAttackSfx();
}
