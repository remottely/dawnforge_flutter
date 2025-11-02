import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_model.dart';

class ImpEnemyView extends DDBaseEnemy<ImpEnemyController, ImpEnemyModel> {
  ImpEnemyView(Vector2 position)
    : super(
        animation: ImpEnemyConfig.animation,
        position: position,
        size: ImpEnemyConfig.componentSize,
        speed: ImpEnemyConfig.kSpeed,
        life: ImpEnemyConfig.kLife,
      );

  @override
  ImpEnemyModel createModel() => ImpEnemyModel();

  @override
  ImpEnemyController createController(ImpEnemyModel model) {
    return ImpEnemyController(
      model: model,
      onSeeAndMoveToMeleeAttack: seeAndMoveToPrimaryAttack,
    );
  }

  @override
  RectangleHitbox createHitbox() => ImpEnemyConfig.createHitbox();
}
