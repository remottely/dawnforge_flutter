import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_model.dart';

class ImpEnemyController extends DDBaseEnemyController<ImpEnemyModel> {
  ImpEnemyController({
    required super.model,
    required super.onSeeAndMoveToMeleeAttack,
  });

  @override
  void update(double dt) {
    onSeeAndMoveToMeleeAttack!(
      closeVisionRadius: model.closeVisionRadius,
      closePlayer: (_) {},
    );
  }
}
