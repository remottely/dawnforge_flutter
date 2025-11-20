import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';

abstract class DDBaseEnemyController<M extends DDBaseEnemyModel> {
  final M model;
  final void Function({
    required double closeVisionRadius,
    void Function(Player)? onCloseToPlayer,
  })
  onDetectPlayerAndMoveToMeleeAttack;
  final void Function({required double longVisionRadius})?
  onDetectPlayerAndMoveToRangedAttack;

  DDBaseEnemyController({
    required this.model,
    required this.onDetectPlayerAndMoveToMeleeAttack,
    this.onDetectPlayerAndMoveToRangedAttack,
  });

  void update(double dt);

  void dispose() {}
}
