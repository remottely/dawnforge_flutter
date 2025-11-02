import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_model.dart';

/// Controller: Lógica de negócio do MiniBoss
/// Gerencia ataques corpo-a-corpo e à distância
class DungeonMiniBossEnemyController
    extends DDBaseEnemyController<DungeonMiniBossEnemyModel> {
  bool _seePlayerClose = false;

  DungeonMiniBossEnemyController({
    required super.model,
    required super.onSeeAndMoveToPlayer,
    required super.onSeeAndMoveToAttackRange,
  });

  @override
  void update(double dt) {
    _seePlayerClose = false;

    // Primeiro tenta ataque corpo-a-corpo
    onSeeAndMoveToPlayer!(
      radiusVision: model.closeVisionRadius,
      closePlayer: (_) {
        _seePlayerClose = true;
      },
    );

    // Se não está perto, tenta ataque à distância
    if (!_seePlayerClose) {
      onSeeAndMoveToAttackRange!(
        radiusVision: model.longVisionRadius,
        positioned: (_) {},
      );
    }
  }
}
