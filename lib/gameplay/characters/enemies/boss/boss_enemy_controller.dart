import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';

class BossEnemyController extends DDBaseEnemyController<BossEnemyModel> {
  final void Function(Player player) onFirstPlayerSight;
  final void Function(double dt) onSpawnMinion;
  final void Function(Canvas canvas) onRenderStatusBars;
  final void Function({
    required double closeVisionRadius,
    required void Function(Player) observed,
  })
  onDetectPlayerInCloseVisionRadius;

  BossEnemyController({
    required super.model,
    required super.onDetectPlayerAndMoveToMeleeAttack,
    required this.onFirstPlayerSight,
    required this.onSpawnMinion,
    required this.onRenderStatusBars,
    required this.onDetectPlayerInCloseVisionRadius,
  });

  @override
  void update(double dt) {
    if (!model.isFirstPlayerSighted) {
      onDetectPlayerInCloseVisionRadius(
        closeVisionRadius: model.closeVisionRadius,
        observed: (player) {
          model.registerFirstPlayerSighting();
          onFirstPlayerSight(player);
        },
      );
      return;
    }

    onSpawnMinion(dt);

    onDetectPlayerAndMoveToMeleeAttack?.call(
      closeVisionRadius: model.closeVisionRadius,
      onCloseToPlayer: (_) {},
    );
  }

  void render(Canvas canvas) {
    onRenderStatusBars(canvas);
  }
}
