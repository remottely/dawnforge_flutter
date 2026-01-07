import 'package:darkness_dungeon/gameplay/characters/enemies/skeleton/skeleton_enemy_def.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class SkeletonEnemyModel extends DDBaseEnemyModel {
  SkeletonEnemyModel()
    : super(
        closeVisionRadius: SkeletonEnemyDef.kPrimaryAttackVisionRadius,
        primaryAttackDamage: SkeletonEnemyDef.kPrimaryAttackDamage,
        primaryAttackInterval: SkeletonEnemyDef.kPrimaryAttackInterval,
      );
}
