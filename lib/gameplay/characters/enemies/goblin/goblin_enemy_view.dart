import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';

/// A View (Componente Bonfire)
/// Responsável apenas por exibir elementos visuais, animações, sons
/// e capturar entradas, delegando toda a lógica para o Controller.
class GoblinEnemyView extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final GoblinEnemyController _controller;

  GoblinEnemyView(Vector2 position, {required GoblinEnemyController controller})
    : _controller = controller,
      super(
        animation: GoblinEnemyConfig.buildDirectionalAnimation,
        position: position,
        size: GoblinEnemyConfig.spriteSize,
        speed: GoblinEnemyConfig.speed,
        life: GoblinEnemyConfig.life,
      ) {
    _controller.attachView(this);
  }

  @override
  Future<void> onLoad() {
    GoblinEnemyConfig.buildHitBox(this);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _controller.onReceiveDamage(attacker, damage, id);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _controller.onDie();
    super.onDie();
  }
}
