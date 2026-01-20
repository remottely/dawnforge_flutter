import 'package:dawnforge/game/modules/characters/enemies/goblin/goblin_enemy_def.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class GoblinEnemyModel extends DDBaseEnemyModel {
  GoblinEnemyModel()
    : super(
        closeVisionRadius: GoblinEnemyDef.kPrimaryAttackVisionRadius,
        primaryAttackDamage: GoblinEnemyDef.kPrimaryAttackDamage,
        primaryAttackInterval: GoblinEnemyDef.kPrimaryAttackInterval,
      );
}
