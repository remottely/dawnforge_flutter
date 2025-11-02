import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_model.dart';

class GoblinEnemyView
    extends DDBaseEnemy<GoblinEnemyController, GoblinEnemyModel> {
  GoblinEnemyView(Vector2 position)
    : super(
        animation: GoblinEnemyConfig.directionalSpriteAnimation,
        position: position,
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
      onSeeAndMoveToMeleeAttack: seeAndMoveToPrimaryAttack,
    );
  }

  @override
  RectangleHitbox createHitbox() => GoblinEnemyConfig.createHitbox();
}
