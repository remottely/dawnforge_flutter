import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';

class GoblinEnemyView
    extends DDBaseEnemyView<GoblinEnemyController, GoblinEnemyModel> {
  GoblinEnemyView({required super.position})
    : super(
        animation: GoblinEnemyConfig.animationWalkDirectional,
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
  RectangleHitbox getHitbox() => GoblinEnemyConfig.createHitbox();
}
