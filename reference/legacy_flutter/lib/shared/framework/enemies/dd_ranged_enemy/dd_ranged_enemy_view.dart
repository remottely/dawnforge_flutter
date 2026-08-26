import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/combat/attacks/character_fireball_attack_def.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';

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
    _executeFireballAttack(
      enemy: this,
      damage: controller.model.primaryAttackDamage,
      longVisionRadius: longVisionRadius,
    );
  }

  static void _executeFireballAttack({
    required SimpleEnemy enemy,
    required double damage,
    required double longVisionRadius,
  }) {
    enemy.seeAndMoveToAttackRange(
      radiusVision: longVisionRadius,
      positioned: (_) {
        enemy.simpleAttackRange(
          size: CharacterFireballAttackDef.componentSize,
          speed: CharacterFireballAttackDef.kSpeed,
          lightingConfig: CharacterFireballAttackDef.lighting,
          damage: damage,
          collision: CharacterFireballAttackDef.createHitbox(),
          animation: CharacterFireballAttackDef.loadAnimationExecution(),
          animationDestroy: CharacterFireballAttackDef.loadAnimationDestroy(),
          execute: CharacterFireballAttackDef.playAudioExecution,
          onDestroy: () => CharacterFireballAttackDef.onDestroy(enemy.gameRef),
        );
      },
    );
  }
}
