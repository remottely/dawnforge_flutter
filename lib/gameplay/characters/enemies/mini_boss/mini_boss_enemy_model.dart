import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';

class MiniBossEnemyModel extends DDBaseEnemyModel {
  final double longVisionRadius;

  MiniBossEnemyModel()
    : longVisionRadius = MiniBossEnemyConfig.kLongVisionRadius,
      super(
        closeVisionRadius: MiniBossEnemyConfig.kCloseVisionRadius,
        primaryAttackDamage: MiniBossEnemyConfig.kPrimaryAttackDamage,
        primaryAttackInterval: MiniBossEnemyConfig.kPrimaryAttackInterval,
      );

  double get fireballAttackDamage =>
      primaryAttackDamage / MiniBossEnemyConfig.kFireballAttackDamageReduction;
}
