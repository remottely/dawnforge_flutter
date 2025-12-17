import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_def.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_ranged_enemy/dd_ranged_enemy_view.dart';

class MiniBossEnemyView
    extends DDRangedEnemyView<MiniBossEnemyController, MiniBossEnemyModel> {
  MiniBossEnemyView({required super.position})
    : super(
        animation: MiniBossEnemyDef.createAnimationWalkDirectional(),
        size: MiniBossEnemyDef.componentSize,
        speed: MiniBossEnemyDef.kSpeed,
        life: MiniBossEnemyDef.kLife,
      );

  @override
  MiniBossEnemyModel createModel() => MiniBossEnemyModel();

  @override
  MiniBossEnemyController createController(
    MiniBossEnemyModel model,
  ) => MiniBossEnemyController(
    model: model,
    onDetectPlayerAndMoveToMeleeAttack: onDetectPlayerAndMoveToPrimaryAttack,
    onDetectPlayerAndMoveToRangedAttack: onDetectPlayerAndMoveToFireballAttack,
  );

  @override
  RectangleHitbox getHitbox() => MiniBossEnemyDef.createHitbox();
}
