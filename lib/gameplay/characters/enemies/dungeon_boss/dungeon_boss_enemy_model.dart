import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_config.dart';

class DungeonBossEnemyModel extends DDBaseEnemyModel {
  DungeonBossEnemyModel()
    : super(
        closeVisionRadius: DungeonBossEnemyConfig.kCloseVisionRadius,
        primaryAttackDamage: DungeonBossEnemyConfig.kPrimaryAttackDamage,
        primaryAttackInterval: DungeonBossEnemyConfig.kPrimaryAttackInterval,
      );

  List<Enemy> spawnedEnemies = [];

  bool _isFirstPlayerSighted = false;
  bool get isFirstPlayerSighted => _isFirstPlayerSighted;
  void registerFirstPlayerSighting() {
    if (_isFirstPlayerSighted) return;
    _isFirstPlayerSighted = true;
  }

  bool _hasSpawnedFirstWave = false;
  bool _hasSpawnedSecondWave = false;
  bool _hasSpawnedThirdWave = false;

  bool shouldSpawnMinions(double currentLife) {
    if (currentLife < 150 && spawnedEnemies.isEmpty && !_hasSpawnedFirstWave) {
      _hasSpawnedFirstWave = true;
      return true;
    }
    if (currentLife < 100 &&
        spawnedEnemies.length == 1 &&
        !_hasSpawnedSecondWave) {
      _hasSpawnedSecondWave = true;
      return true;
    }
    if (currentLife < 50 &&
        spawnedEnemies.length == 2 &&
        !_hasSpawnedThirdWave) {
      _hasSpawnedThirdWave = true;
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
