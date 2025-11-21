import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy.dart';

class GoblinEnemyView
    extends DDBaseEnemy<GoblinEnemyController, GoblinEnemyModel> {
  GoblinEnemyView({required super.position})
    : super(
        animation: GoblinEnemyConfig.walkAnimation,
        size: GoblinEnemyConfig.componentSize,
        speed: GoblinEnemyConfig.kSpeed,
        life: GoblinEnemyConfig.kLife,
      );

  @override
  GoblinEnemyModel createModel() => GoblinEnemyModel();

  @override
  GoblinEnemyController createController(GoblinEnemyModel model) {
    return GoblinEnemyController(
      model: model,
      onDetectPlayerAndMoveToMeleeAttack: onDetectPlayerAndMoveToPrimaryAttack,
    );
  }

  @override
  RectangleHitbox createHitbox() => GoblinEnemyConfig.createHitbox();
}
