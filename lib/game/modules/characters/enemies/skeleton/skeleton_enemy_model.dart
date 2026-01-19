import 'package:dawnforge/game/modules/characters/enemies/skeleton/skeleton_enemy_def.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class SkeletonEnemyModel extends DDBaseEnemyModel {
  SkeletonEnemyModel()
    : super(
        closeVisionRadius: SkeletonEnemyDef.kPrimaryAttackVisionRadius,
        primaryAttackDamage: SkeletonEnemyDef.kPrimaryAttackDamage,
        primaryAttackInterval: SkeletonEnemyDef.kPrimaryAttackInterval,
      );
}
