import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_controller.dart';

class ImpEnemyView extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  final ImpEnemyController _controller = ImpEnemyController();

  ImpEnemyView(Vector2 position)
    : super(
        animation: ImpEnemyConfig.buildDirectionalAnimation,
        position: position,
        size: ImpEnemyConfig.spriteSize,
        speed: ImpEnemyConfig.speed,
        life: ImpEnemyConfig.life,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _controller.attachView(this);
    ImpEnemyConfig.buildHitBox(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _controller.onUpdate(dt);
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
