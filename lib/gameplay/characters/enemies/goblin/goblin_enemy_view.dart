import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';

/// GoblinEnemyView
/// ---------------------------------------------------------------------------
/// Visual and interaction layer for Goblin enemy. Handles rendering, collision, and delegates logic to the controller.
class GoblinEnemyView extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  /// Controller orchestrates logic and communication
  final GoblinEnemyController _controller = GoblinEnemyController();

  /// Creates the Goblin enemy at the given position
  GoblinEnemyView(Vector2 position)
    : super(
        animation: GoblinEnemyConfig.buildDirectionalAnimation,
        position: position,
        size: GoblinEnemyConfig.spriteSize,
        speed: GoblinEnemyConfig.speed,
        life: GoblinEnemyConfig.life,
      );

  /// Called when the component is added to the game
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _controller.attachView(this);
    GoblinEnemyConfig.buildHitBox(this);
  }

  /// Called every game tick
  @override
  void update(double dt) {
    super.update(dt);
    _controller.onUpdate(dt);
  }

  /// Called when the Goblin receives damage
  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _controller.onReceiveDamage(attacker, damage, id);
    super.onReceiveDamage(attacker, damage, id);
  }

  /// Called when the Goblin dies
  @override
  void onDie() {
    _controller.onDie();
    super.onDie();
  }
}
