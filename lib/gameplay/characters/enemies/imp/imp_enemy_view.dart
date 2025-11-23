import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';

class ImpEnemyView extends DDBaseEnemyView<ImpEnemyController, ImpEnemyModel> {
  ImpEnemyView({required super.position})
    : super(
        animation: ImpEnemyConfig.walkAnimation,
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
      onDetectPlayerAndMoveToMeleeAttack: onDetectPlayerAndMoveToPrimaryAttack,
    );
  }

  @override
  RectangleHitbox getHitbox() => ImpEnemyConfig.createHitbox();
}
