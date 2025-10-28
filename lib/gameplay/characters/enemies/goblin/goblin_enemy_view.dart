import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';

class GoblinEnemyView extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  final GoblinEnemyController _controller = GoblinEnemyController();

  GoblinEnemyView(Vector2 position)
    : super(
        animation: GoblinEnemyConfig.fDirectionalAnimation,
        position: position,
        size: GoblinEnemyConfig.fComponentSize,
        speed: GoblinEnemyConfig.kSpeed,
        life: GoblinEnemyConfig.kLife,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _controller.attachView(this);
    add(GoblinEnemyConfig.buildHitbox());
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
