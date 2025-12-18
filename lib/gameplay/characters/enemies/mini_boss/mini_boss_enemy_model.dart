import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_def.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class MiniBossEnemyModel extends DDBaseEnemyModel {
  final double longVisionRadius;

  MiniBossEnemyModel()
    : longVisionRadius = MiniBossEnemyDef.kFireballAttackVisionRadius,
      super(
        closeVisionRadius: MiniBossEnemyDef.kPrimaryAttackVisionRadius,
        primaryAttackDamage: MiniBossEnemyDef.kPrimaryAttackDamage,
        primaryAttackInterval: MiniBossEnemyDef.kPrimaryAttackInterval,
      );

  double get fireballAttackDamage =>
      primaryAttackDamage / MiniBossEnemyDef.kFireballAttackDamageReduction;
}
