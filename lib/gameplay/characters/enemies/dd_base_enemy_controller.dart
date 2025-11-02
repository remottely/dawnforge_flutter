import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';

/// Controller base abstrato para todos os inimigos.
/// Não conhece detalhes de implementação da View.
abstract class DDBaseEnemyController<M extends DDBaseEnemyModel> {
  final M model;
  final void Function({
    required double radiusVision,
    required void Function(Player) closePlayer,
  })?
  onSeeAndMoveToMeleeAttack;
  final void Function({
    required double radiusVision,
    required void Function(Player) positioned,
  })?
  onSeeAndMoveToRangeAttack;

  DDBaseEnemyController({
    required this.model,
    this.onSeeAndMoveToMeleeAttack,
    this.onSeeAndMoveToRangeAttack,
  });

  void update(double dt);

  void dispose() {}
}
