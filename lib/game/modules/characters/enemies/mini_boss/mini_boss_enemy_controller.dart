import 'package:dawnforge/game/modules/characters/enemies/mini_boss/mini_boss_enemy_model.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';

class MiniBossEnemyController
    extends DDBaseEnemyController<MiniBossEnemyModel> {
  bool _isPlayerClose = false;

  MiniBossEnemyController({
    required super.model,
    required super.onDetectPlayerAndMoveToMeleeAttack,
    required super.onDetectPlayerAndMoveToRangedAttack,
  });

  @override
  void update(double dt) {
    // TODO(Kevin): fix mini boss behavior
    _isPlayerClose = false;

    onDetectPlayerAndMoveToMeleeAttack.call(
      closeVisionRadius: model.closeVisionRadius,
      onCloseToPlayer: (_) {
        _isPlayerClose = true;
      },
    );

    if (!_isPlayerClose) {
      onDetectPlayerAndMoveToRangedAttack?.call(
        longVisionRadius: model.longVisionRadius,
      );
    }
  }
}
