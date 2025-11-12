import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';

abstract class DDRangedEnemy<
  C extends DDBaseEnemyController,
  M extends DDBaseEnemyModel
>
    extends DDBaseEnemy<C, M> {
  DDRangedEnemy({
    required super.position,
    required super.size,
    required super.animation,
    required super.speed,
    required super.life,
  });

  void seeAndMoveToFireballAttack({required double longVisionRadius}) {
    seeAndMoveToAttackRange(
      radiusVision: longVisionRadius,
      positioned: (player) {
        simpleAttackRange(
          animation: CharacterFireballAttackConfig.createExecutionAnimation(),
          animationDestroy:
              CharacterFireballAttackConfig.createDestroyAnimation(),
          size: CharacterFireballAttackConfig.componentSize,
          damage: controller.model.primaryAttackDamage,
          speed: CharacterFireballAttackConfig.kSpeed,
          execute: CharacterFireballAttackConfig.playExecutionAudio,
          onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
          collision: CharacterFireballAttackConfig.createHitbox(),
          lightingConfig: CharacterFireballAttackConfig.lightingConfig,
        );
      },
    );
  }
}
