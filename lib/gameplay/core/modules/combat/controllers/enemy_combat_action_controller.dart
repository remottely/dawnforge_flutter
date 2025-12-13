import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/enemy_primary_attack_config.dart';

final class EnemyCombatActionController {
  EnemyCombatActionController._();

  static void executePrimaryAttack({
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

        // TODO(Kevin): fix this attackDirection and attackOffset behavior
        // final attackDirection =
        //     _resolveAttackDirection(enemy, player) ?? enemy.lastDirection;
        // final attackOffset = OffsetHelper.getCenterOffset(
        //   Vector2(enemy.width / 2, 0),
        //   attackDirection,
        // );

        enemy.simpleAttackMelee(
          size: EnemyPrimaryAttackConfig.componentSize,
          damage: damage,
          interval: interval,
          // direction: attackDirection,
          // centerOffset: attackOffset,
          animationRight: EnemyPrimaryAttackConfig.loadAnimationFxRight(),
          execute: AudioManager.instance.playEnemyPrimaryAttackSfx,
        );
      },
    );
  }

  static void executeFireballAttack({
    required SimpleEnemy enemy,
    required double damage,
    required double longVisionRadius,
  }) {
    enemy.seeAndMoveToAttackRange(
      radiusVision: longVisionRadius,
      positioned: (_) {
        enemy.simpleAttackRange(
          size: CharacterFireballAttackConfig.componentSize,
          speed: CharacterFireballAttackConfig.kSpeed,
          lightingConfig: CharacterFireballAttackConfig.lighting,
          damage: damage,
          collision: CharacterFireballAttackConfig.createHitbox(),
          animation: CharacterFireballAttackConfig.loadAnimationExecution(),
          animationDestroy:
              CharacterFireballAttackConfig.loadAnimationDestroy(),
          execute: CharacterFireballAttackConfig.playAudioExecution,
          onDestroy: () =>
              CharacterFireballAttackConfig.onDestroy(enemy.gameRef),
        );
      },
    );
  }

  // static Direction? _resolveAttackDirection(SimpleEnemy enemy, Player player) {
  //   final delta = player.center - enemy.center;
  //   const double threshold = 2;

  //   final bool hasHorizontal = delta.x.abs() > threshold;
  //   final bool hasVertical = delta.y.abs() > threshold;

  //   if (hasHorizontal && hasVertical) {
  //     if (delta.x > 0 && delta.y > 0) return Direction.downRight;
  //     if (delta.x > 0 && delta.y < 0) return Direction.upRight;
  //     if (delta.x < 0 && delta.y > 0) return Direction.downLeft;
  //     return Direction.upLeft;
  //   }

  //   if (hasHorizontal) {
  //     return delta.x > 0 ? Direction.right : Direction.left;
  //   }

  //   if (hasVertical) {
  //     return delta.y > 0 ? Direction.down : Direction.up;
  //   }

  //   return null;
  // }
}
