import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/characters/enemies/skeleton/skeleton_enemy_controller.dart';
import 'package:dawnforge/game/modules/characters/enemies/skeleton/skeleton_enemy_def.dart';
import 'package:dawnforge/game/modules/characters/enemies/skeleton/skeleton_enemy_model.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';

class SkeletonEnemyView
    extends DDBaseEnemyView<SkeletonEnemyController, SkeletonEnemyModel> {
  SkeletonEnemyView({required super.position})
    : super(
        animation: SkeletonEnemyDef.createAnimationWalkDirectional(),
        size: SkeletonEnemyDef.componentSize,
        speed: SkeletonEnemyDef.kSpeed,
        life: SkeletonEnemyDef.kLife,
      );

  @override
  double get fixedLifeBarWidth => SkeletonEnemyDef.kFixedLifeBarWidth;

  @override
  Vector2 get fixedLifeBarOffset => SkeletonEnemyDef.fixedLifeBarOffset;

  @override
  SkeletonEnemyModel createModel() => SkeletonEnemyModel();

  @override
  SkeletonEnemyController createController(SkeletonEnemyModel model) =>
      SkeletonEnemyController(
        model: model,
        onDetectPlayerAndMoveToMeleeAttack:
            onDetectPlayerAndMoveToPrimaryAttack,
      );

  @override
  RectangleHitbox getHitbox() => SkeletonEnemyDef.createHitbox();

  @override
  DDAnimationDirectionalFactory get attackAnimationFactory =>
      SkeletonEnemyDef.animationAttack1DirectionalFactory();

  // @override
  // List<DDAnimationDirectionalFactory> get comboAttackAnimationFactories =>
  //     SkeletonEnemyDef.comboAttackAnimationFactories();
}
