import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';

class GoblinEnemyModel extends DDBaseEnemyModel {
  GoblinEnemyModel()
    : super(
        closeVisionRadius: GoblinEnemyConfig.kCloseVisionRadius,
        primaryAttackDamage: GoblinEnemyConfig.kPrimaryAttackDamage,
        primaryAttackInterval: GoblinEnemyConfig.kPrimaryAttackInterval,
      );
}
