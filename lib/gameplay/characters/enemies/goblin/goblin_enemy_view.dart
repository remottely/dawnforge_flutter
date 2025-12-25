import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_def.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';

class GoblinEnemyView
    extends DDBaseEnemyView<GoblinEnemyController, GoblinEnemyModel> {
  GoblinEnemyView({required super.position})
    : super(
        animation: GoblinEnemyDef.createAnimationWalkDirectional(),
        size: GoblinEnemyDef.componentSize,
        speed: GoblinEnemyDef.kSpeed,
        life: GoblinEnemyDef.kLife,
      );

  @override
  GoblinEnemyModel createModel() => GoblinEnemyModel();

  @override
  GoblinEnemyController createController(GoblinEnemyModel model) =>
      GoblinEnemyController(
        model: model,
        onDetectPlayerAndMoveToMeleeAttack:
            onDetectPlayerAndMoveToPrimaryAttack,
      );

  @override
  RectangleHitbox getHitbox() => GoblinEnemyDef.createHitbox();
}
