import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/characters/enemies/boss/boss_enemy_def.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

class BossEnemyModel extends DDBaseEnemyModel {
  BossEnemyModel()
    : super(
        closeVisionRadius: BossEnemyDef.kPrimaryAttackVisionRadius,
        primaryAttackDamage: BossEnemyDef.kPrimaryAttackDamage,
        primaryAttackInterval: BossEnemyDef.kPrimaryAttackInterval,
      );

  List<Enemy> spawnedEnemies = [];

  bool _isPlayerFirstDetection = false;
  bool get isPlayerFirstDetection => _isPlayerFirstDetection;
  void registerFirstPlayerSighting() {
    if (_isPlayerFirstDetection) return;
    _isPlayerFirstDetection = true;
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
