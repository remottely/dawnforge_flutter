import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';

class GoblinEnemyController extends DDBaseEnemyController<GoblinEnemyModel> {
  GoblinEnemyController({
    required super.model,
    required super.onDetectPlayerAndMoveToMeleeAttack,
  });

  @override
  void update(double dt) {
    onDetectPlayerAndMoveToMeleeAttack?.call(
      closeVisionRadius: model.closeVisionRadius,
      onCloseToPlayer: (_) {},
    );
  }
}
