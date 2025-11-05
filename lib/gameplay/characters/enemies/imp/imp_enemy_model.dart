import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';

class ImpEnemyModel extends DDBaseEnemyModel {
  ImpEnemyModel()
    : super(
        closeVisionRadius: ImpEnemyConfig.kCloseVisionRadius,
        primaryAttackDamage: ImpEnemyConfig.kPrimaryAttackDamage,
        primaryAttackInterval: ImpEnemyConfig.kPrimaryAttackInterval,
      );
}
