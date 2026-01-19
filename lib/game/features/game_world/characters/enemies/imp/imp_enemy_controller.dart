import 'package:dawnforge/game/features/game_world/characters/enemies/imp/imp_enemy_model.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';

class ImpEnemyController extends DDBaseEnemyController<ImpEnemyModel> {
  ImpEnemyController({
    required super.model,
    required super.onDetectPlayerAndMoveToMeleeAttack,
  });

  @override
  void update(double dt) {
    onDetectPlayerAndMoveToMeleeAttack.call(
      closeVisionRadius: model.closeVisionRadius,
    );
  }
}
