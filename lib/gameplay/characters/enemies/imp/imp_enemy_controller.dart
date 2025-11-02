import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_model.dart';

/// Controller: Lógica de negócio do Imp
/// Não conhece detalhes de implementação da View
class ImpEnemyController extends DDBaseEnemyController<ImpEnemyModel> {
  ImpEnemyController({
    required super.model,
    required super.onSeeAndMoveToMeleeAttack,
  });

  @override
  void update(double dt) {
    onSeeAndMoveToMeleeAttack!(
      radiusVision: model.visionRadius,
      closePlayer: (_) {},
    );
  }
}
