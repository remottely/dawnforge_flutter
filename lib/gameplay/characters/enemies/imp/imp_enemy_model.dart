import 'package:dawnforge/gameplay/characters/enemies/imp/imp_enemy_Def.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class ImpEnemyModel extends DDBaseEnemyModel {
  ImpEnemyModel()
    : super(
        closeVisionRadius: ImpEnemyDef.kPrimaryAttackVisionRadius,
        primaryAttackDamage: ImpEnemyDef.kPrimaryAttackDamage,
        primaryAttackInterval: ImpEnemyDef.kPrimaryAttackInterval,
      );
}
