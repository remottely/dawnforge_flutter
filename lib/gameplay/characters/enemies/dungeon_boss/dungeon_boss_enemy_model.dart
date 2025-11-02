import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_config.dart';

/// Model: Contém dados e validações do Boss.
/// Este inimigo tem sistema de spawn de minions baseado em vida.
class DungeonBossEnemyModel extends DDBaseEnemyModel {
  List<Enemy> spawnedEnemies = [];
  bool hasSeenPlayerFirst = false;
  bool hasSpawnedFirstWave = false;
  bool hasSpawnedSecondWave = false;
  bool hasSpawnedThirdWave = false;

  DungeonBossEnemyModel()
    : super(
        closeVisionRadius: DungeonBossEnemyConfig.kCloseVisionRadius,
        primaryAttackDamage: DungeonBossEnemyConfig.kPrimaryAttackDamage,
        primaryAttackInterval: DungeonBossEnemyConfig.kPrimaryAttackInterval,
      );

  bool shouldSpawnMinions(double currentLife) {
    if (currentLife < 150 && spawnedEnemies.isEmpty && !hasSpawnedFirstWave) {
      hasSpawnedFirstWave = true;
      return true;
    }
    if (currentLife < 100 &&
        spawnedEnemies.length == 1 &&
        !hasSpawnedSecondWave) {
      hasSpawnedSecondWave = true;
      return true;
    }
    if (currentLife < 50 &&
        spawnedEnemies.length == 2 &&
        !hasSpawnedThirdWave) {
      hasSpawnedThirdWave = true;
      return true;
    }
    return false;
  }

  void addSpawnedEnemy(Enemy enemy) {
    spawnedEnemies.add(enemy);
  }

  void clearDeadEnemies() {
    spawnedEnemies.removeWhere((e) => e.isDead);
  }
}
