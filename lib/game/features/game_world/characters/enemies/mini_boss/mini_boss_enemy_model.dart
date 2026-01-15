import 'package:dawnforge/game/features/game_world/characters/enemies/mini_boss/mini_boss_enemy_def.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

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
