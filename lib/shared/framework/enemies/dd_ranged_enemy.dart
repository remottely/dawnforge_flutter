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

  void onDetectPlayerAndMoveToFireballAttack({
    required double longVisionRadius,
  }) {
    CharacterFireballAttackConfig.enemyExecute(
      enemy: this,
      damage: controller.model.primaryAttackDamage,
      longVisionRadius: longVisionRadius,
    );
  }
}
