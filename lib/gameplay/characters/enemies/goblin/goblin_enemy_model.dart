import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class GoblinEnemyModel extends DDBaseEnemyModel {
  GoblinEnemyModel()
    : super(
        closeVisionRadius: GoblinEnemyConfig.kPrimaryAttackVisionRadius,
        primaryAttackDamage: GoblinEnemyConfig.kPrimaryAttackDamage,
        primaryAttackInterval: GoblinEnemyConfig.kPrimaryAttackInterval,
      );
}
