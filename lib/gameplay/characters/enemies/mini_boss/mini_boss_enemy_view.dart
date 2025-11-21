import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_ranged_enemy/dd_ranged_enemy_view.dart';

class MiniBossEnemyView
    extends DDRangedEnemyView<MiniBossEnemyController, MiniBossEnemyModel> {
  MiniBossEnemyView({required super.position})
    : super(
        animation: MiniBossEnemyConfig.walkAnimation,
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
      onDetectPlayerAndMoveToMeleeAttack: onDetectPlayerAndMoveToPrimaryAttack,
      onDetectPlayerAndMoveToRangedAttack:
          onDetectPlayerAndMoveToFireballAttack,
    );
  }

  @override
  RectangleHitbox getHitbox() => MiniBossEnemyConfig.createHitbox();
}
