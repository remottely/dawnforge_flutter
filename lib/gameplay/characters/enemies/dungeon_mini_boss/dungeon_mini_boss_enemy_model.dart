import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';

/// Model: Contém dados e validações do MiniBoss.
/// Este inimigo tem ataques corpo-a-corpo e à distância.
class DungeonMiniBossEnemyModel extends DDBaseEnemyModel {
  final double closeVisionRadius;
  final double longVisionRadius;
  final double primaryDamageReduction;

  DungeonMiniBossEnemyModel()
    : closeVisionRadius = DungeonMiniBossEnemyConfig.kCloseVisionRadius,
      longVisionRadius = DungeonMiniBossEnemyConfig.kLongVisionRadius,
      primaryDamageReduction =
          DungeonMiniBossEnemyConfig.kPrimaryDamageReduction,
      super(
        attackDamage: DungeonMiniBossEnemyConfig.kPrimaryAttackDamage,
        visionRadius: DungeonMiniBossEnemyConfig.kLongVisionRadius,
        attackInterval: DungeonMiniBossEnemyConfig.kPrimaryAttackInterval,
      );

  double get meleeAttackDamage => attackDamage / primaryDamageReduction;
  double get rangedAttackDamage => attackDamage;
}
