import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';

/// Model: Contém dados e validações do MiniBoss.
/// Este inimigo tem ataques corpo-a-corpo e à distância.
class DungeonMiniBossEnemyModel extends DDBaseEnemyModel {
  final double longVisionRadius;

  DungeonMiniBossEnemyModel()
    : longVisionRadius = DungeonMiniBossEnemyConfig.kLongVisionRadius,
      super(
        closeVisionRadius: DungeonMiniBossEnemyConfig.kCloseVisionRadius,
        primaryAttackDamage: DungeonMiniBossEnemyConfig.kPrimaryAttackDamage,
        primaryAttackInterval:
            DungeonMiniBossEnemyConfig.kPrimaryAttackInterval,
      );

  double get fireballAttackDamage =>
      primaryAttackDamage /
      DungeonMiniBossEnemyConfig.kFireballAttackDamageReduction;
}
