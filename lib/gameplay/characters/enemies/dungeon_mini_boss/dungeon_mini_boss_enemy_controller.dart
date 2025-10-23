import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
// import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';

class DungeonMiniBossEnemyController {
  late DungeonMiniBossEnemyView _view;

  void attachView(DungeonMiniBossEnemyView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    // Lógica de movimentação e ataque
    _view.seePlayerAndAct();
  }

  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _view.showDamageEffect(damage);
  }

  void onDie() {
    _view.handleDeathEffects();
  }

  void onJoystickAction(JoystickActionEvent event) {
    // Inimigos normalmente não usam joystick, mas pode ser estendido
  }
}
