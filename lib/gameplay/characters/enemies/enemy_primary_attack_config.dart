import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';

final class EnemyPrimaryAttackConfig {
  EnemyPrimaryAttackConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeSmall;
  static final Vector2 _componentSize = _textureSize;

  static Future<SpriteAnimation> _createExecutionAnimation() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_primary_attack_right_3.png',
        SpriteAnimationConfig.createStandardData(
          amount: 3,
          textureSize: _textureSize,
        ),
      );

  static void execute({
    required SimpleEnemy enemy,
    required double damage,
    required int interval,
    required double closeVisionRadius,
    void Function(Player)? onCloseToPlayer,
  }) {
    enemy.seeAndMoveToPlayer(
      radiusVision: closeVisionRadius,
      closePlayer: (player) {
        onCloseToPlayer?.call(player);

        enemy.simpleAttackMelee(
          size: _componentSize,
          damage: damage,
          interval: interval,
          animationRight: _createExecutionAnimation(),
          execute: AudioManager.instance.playEnemyPrimaryAttackSfx,
        );
      },
    );
  }
}
