import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_model.dart';

/// Controller: Lógica de negócio do Goblin
/// Não conhece detalhes de implementação da View
class GoblinEnemyController extends DDBaseEnemyController<GoblinEnemyModel> {
  GoblinEnemyController({
    required super.model,
    required super.onSeeAndMoveToPlayer,
  });

  @override
  void update(double dt) {
    onSeeAndMoveToPlayer!(
      radiusVision: model.visionRadius,
      closePlayer: (player) {},
    );
  }
}
