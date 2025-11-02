import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';

/// Controller base abstrato para todos os inimigos.
/// Não conhece detalhes de implementação da View.
abstract class DDBaseEnemyController<T extends DDBaseEnemyModel> {
  final T model;
  final void Function({
    required double radiusVision,
    required void Function(Player) closePlayer,
  })?
  onSeeAndMoveToPlayer;
  final void Function({
    required double radiusVision,
    required void Function(Player) positioned,
  })?
  onSeeAndMoveToAttackRange;

  DDBaseEnemyController({
    required this.model,
    this.onSeeAndMoveToPlayer,
    this.onSeeAndMoveToAttackRange,
  });

  // Lifecycle - deve ser implementado pelas subclasses
  void update(double dt);

  // Método dispose comum
  void dispose() {
    // Cleanup if needed
  }
}
