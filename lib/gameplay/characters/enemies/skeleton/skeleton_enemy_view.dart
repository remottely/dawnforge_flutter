import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/skeleton/skeleton_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/skeleton/skeleton_enemy_def.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/skeleton/skeleton_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';

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

  @override
  List<DDAnimationDirectionalFactory> get comboAttackAnimationFactories =>
      SkeletonEnemyDef.comboAttackAnimationFactories();
}
