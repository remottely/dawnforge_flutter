import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/combat/attacks/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/combat/attacks/enemy_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';

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

        enemy.simpleAttackMelee(
          size: EnemyPrimaryAttackConfig.componentSize,
          damage: damage,
          interval: interval,
          animationRight: EnemyPrimaryAttackConfig.loadFxAnimationRight3(),
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
          lightingConfig: CharacterFireballAttackConfig.lightingConfig,
          damage: damage,
          collision: CharacterFireballAttackConfig.createHitbox(),
          animation: CharacterFireballAttackConfig.loadExecutionAnimation(),
          animationDestroy:
              CharacterFireballAttackConfig.loadDestroyAnimation(),
          execute: CharacterFireballAttackConfig.playExecutionAudio,
          onDestroy: () =>
              CharacterFireballAttackConfig.onDestroy(enemy.gameRef),
        );
      },
    );
  }
}
