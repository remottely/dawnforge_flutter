import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';

class BossEnemyController extends DDBaseEnemyController<BossEnemyModel> {
  final void Function({
    required double closeVisionRadius,
    required void Function(Player) observed,
  })
  onDetectPlayerInCloseVisionRadius;
  final void Function(Player player) onPlayerFirstDetection;
  final void Function(double dt) onRequestSpawnMinion;
  final void Function(Canvas canvas) onRenderStatusBars;

  BossEnemyController({
    required super.model,
    required super.onDetectPlayerAndMoveToMeleeAttack,
    required this.onDetectPlayerInCloseVisionRadius,
    required this.onPlayerFirstDetection,
    required this.onRequestSpawnMinion,
    required this.onRenderStatusBars,
  });

  @override
  void update(double dt) {
    if (!model.isPlayerFirstDetection) {
      _handleDetectPlayerInCloseVisionRadius();
      return;
    } else {
      onRequestSpawnMinion(dt);

      onDetectPlayerAndMoveToMeleeAttack.call(
        closeVisionRadius: model.closeVisionRadius,
      );
    }
  }

  void _handleDetectPlayerInCloseVisionRadius() {
    onDetectPlayerInCloseVisionRadius.call(
      closeVisionRadius: model.closeVisionRadius,
      observed: (player) {
        model.registerFirstPlayerSighting();
        onPlayerFirstDetection(player);
      },
    );
  }

  void render(Canvas canvas) {
    onRenderStatusBars(canvas);
  }
}
