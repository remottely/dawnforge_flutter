import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_Def.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class ImpEnemyModel extends DDBaseEnemyModel {
  ImpEnemyModel()
    : super(
        closeVisionRadius: ImpEnemyDef.kPrimaryAttackVisionRadius,
        primaryAttackDamage: ImpEnemyDef.kPrimaryAttackDamage,
        primaryAttackInterval: ImpEnemyDef.kPrimaryAttackInterval,
      );
}
