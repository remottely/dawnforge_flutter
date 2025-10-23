import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_controller.dart';

/// A View (Componente Bonfire)
/// Responsável apenas por exibir elementos visuais, animações, sons
/// e capturar entradas, delegando toda a lógica para o Controller.
class ImpEnemyView extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  final ImpEnemyController _controller;

  ImpEnemyView(Vector2 position, {required ImpEnemyController controller})
    : _controller = controller,
      super(
        animation: ImpEnemyConfig.buildDirectionalAnimation,
        position: position,
        size: ImpEnemyConfig.spriteSize,
        speed: ImpEnemyConfig.speed,
        life: ImpEnemyConfig.life,
      ) {
    _controller.attachView(this);
  }

  @override
  Future<void> onLoad() {
    ImpEnemyConfig.buildHitBox(this);
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
