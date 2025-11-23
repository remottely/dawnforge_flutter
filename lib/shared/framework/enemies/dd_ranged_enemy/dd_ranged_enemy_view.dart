import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';

abstract class DDRangedEnemyView<
  C extends DDBaseEnemyController<M>,
  M extends DDBaseEnemyModel
>
    extends DDBaseEnemyView<C, M> {
  DDRangedEnemyView({
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
