import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_view.dart';

class DungeonBossEnemyController {
  late DungeonBossEnemyView _view;
  bool hasSeenPlayerFirst = false;
  List<Enemy> spawnedEnemies = [];

  void attachView(DungeonBossEnemyView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _view.handleBossLogic(dt);
  }

  void onDie() {
    _view.handleDeathEffects();
  }

  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _view.showDamageEffect(damage);
  }

  void onRender(Canvas canvas) {
    _view.drawBarSummonEnemy(canvas);
  }
}
