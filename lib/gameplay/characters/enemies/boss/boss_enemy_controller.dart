import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';

class BossEnemyController extends DDBaseEnemyController<BossEnemyModel> {
  final void Function(Player player) onFirstPlayerSight;
  final void Function(double dt) onSpawnMinion;
  final void Function(Canvas canvas) onRenderBars;
  final void Function({
    required double closeVisionRadius,
    required void Function(Player) observed,
  })
  onSeePlayer;

  BossEnemyController({
    required super.model,
    required super.onSeeAndMoveToMeleeAttack,
    required this.onFirstPlayerSight,
    required this.onSpawnMinion,
    required this.onRenderBars,
    required this.onSeePlayer,
  });

  @override
  void update(double dt) {
    if (!model.isFirstPlayerSighted) {
      onSeePlayer(
        closeVisionRadius: model.closeVisionRadius,
        observed: (player) {
          model.registerFirstPlayerSighting();
          onFirstPlayerSight(player);
        },
      );
      return;
    }

    onSpawnMinion(dt);

    onSeeAndMoveToMeleeAttack!(
      closeVisionRadius: model.closeVisionRadius,
      closePlayer: (_) {},
    );
  }

  void render(Canvas canvas) {
    onRenderBars(canvas);
  }
}
