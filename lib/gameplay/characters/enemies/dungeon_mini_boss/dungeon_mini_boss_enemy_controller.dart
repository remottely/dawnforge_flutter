import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_model.dart';

class DungeonMiniBossEnemyController
    extends DDBaseEnemyController<DungeonMiniBossEnemyModel> {
  bool _seePlayerClose = false;

  DungeonMiniBossEnemyController({
    required super.model,
    required super.onSeeAndMoveToMeleeAttack,
    required super.onSeeAndMoveToRangeAttack,
  });

  @override
  void update(double dt) {
    _seePlayerClose = false;

    onSeeAndMoveToMeleeAttack!(
      closeVisionRadius: model.closeVisionRadius,
      closePlayer: (_) {
        _seePlayerClose = true;
      },
    );

    if (!_seePlayerClose) {
      onSeeAndMoveToRangeAttack!(
        longVisionRadius: model.longVisionRadius,
        positioned: (_) {},
      );
    }
  }
}
