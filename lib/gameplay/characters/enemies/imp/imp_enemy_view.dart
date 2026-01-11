import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/characters/enemies/imp/imp_enemy_def.dart';
import 'package:dawnforge/gameplay/characters/enemies/imp/imp_enemy_controller.dart';
import 'package:dawnforge/gameplay/characters/enemies/imp/imp_enemy_model.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_view.dart';

class ImpEnemyView extends DDBaseEnemyView<ImpEnemyController, ImpEnemyModel> {
  ImpEnemyView({required super.position})
    : super(
        animation: ImpEnemyDef.createAnimationWalkDirectional(),
        size: ImpEnemyDef.componentSize,
        speed: ImpEnemyDef.kSpeed,
        life: ImpEnemyDef.kLife,
      );

  @override
  double get fixedLifeBarWidth => ImpEnemyDef.fixedLifeBarWidth;

  @override
  Vector2 get fixedLifeBarOffset => ImpEnemyDef.fixedLifeBarOffset;

  @override
  ImpEnemyModel createModel() => ImpEnemyModel();

  @override
  ImpEnemyController createController(ImpEnemyModel model) =>
      ImpEnemyController(
        model: model,
        onDetectPlayerAndMoveToMeleeAttack:
            onDetectPlayerAndMoveToPrimaryAttack,
      );

  @override
  RectangleHitbox getHitbox() => ImpEnemyDef.createHitbox();
}
