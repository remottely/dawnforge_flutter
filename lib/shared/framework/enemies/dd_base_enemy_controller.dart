import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';

abstract class DDBaseEnemyController<M extends DDBaseEnemyModel> {
  final M model;
  final void Function({
    required double closeVisionRadius,
    required void Function(Player) closePlayer,
  })?
  onSeeAndMoveToMeleeAttack;
  final void Function({
    required double longVisionRadius,
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
