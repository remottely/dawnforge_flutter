import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';

class MiniBossEnemyController
    extends DDBaseEnemyController<MiniBossEnemyModel> {
  bool _seePlayerClose = false;

  MiniBossEnemyController({
    required super.model,
    required super.onSeeAndMoveToMeleeAttack,
    required super.onSeeAndMoveToRangeAttack,
  });

  @override
  void update(double dt) {
    _seePlayerClose = false;

    onSeeAndMoveToMeleeAttack?.call(
      closeVisionRadius: model.closeVisionRadius,
      closePlayer: (_) {
        _seePlayerClose = true;
      },
    );

    if (!_seePlayerClose) {
      onSeeAndMoveToRangeAttack?.call(
        longVisionRadius: model.longVisionRadius,
        positioned: (_) {},
      );
    }
  }
}
