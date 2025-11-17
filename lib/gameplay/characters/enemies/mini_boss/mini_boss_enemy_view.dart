import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_ranged_enemy.dart';

class MiniBossEnemyView
    extends DDRangedEnemy<MiniBossEnemyController, MiniBossEnemyModel> {
  MiniBossEnemyView({required super.position})
    : super(
        animation: MiniBossEnemyConfig.createWalkAnimation,
        size: MiniBossEnemyConfig.componentSize,
        speed: MiniBossEnemyConfig.kSpeed,
        life: MiniBossEnemyConfig.kLife,
      );

  @override
  MiniBossEnemyModel createModel() => MiniBossEnemyModel();

  @override
  MiniBossEnemyController createController(MiniBossEnemyModel model) {
    return MiniBossEnemyController(
      model: model,
      onSeeAndMoveToMeleeAttack: seeAndMoveToPrimaryAttack,
      onSeeAndMoveToRangeAttack: seeAndMoveToFireballAttack,
    );
  }

  @override
  RectangleHitbox createHitbox() => MiniBossEnemyConfig.createHitbox();
}
