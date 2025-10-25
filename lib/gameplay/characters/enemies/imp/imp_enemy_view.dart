import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_controller.dart';

/// ImpEnemyView
/// ---------------------------------------------------------------------------
/// Visual and interaction layer for Imp enemy. Handles rendering, collision, and delegates logic to the controller.
class ImpEnemyView extends SimpleEnemy with BlockMovementCollision, UseLifeBar {
  /// Controller orchestrates logic and communication
  final ImpEnemyController _controller = ImpEnemyController();

  /// Creates the Imp enemy at the given position
  ImpEnemyView(Vector2 position)
    : super(
        animation: ImpEnemyConfig.buildDirectionalAnimation,
        position: position,
        size: ImpEnemyConfig.spriteSize,
        speed: ImpEnemyConfig.speed,
        life: ImpEnemyConfig.life,
      );

  /// Called when the component is added to the game
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _controller.attachView(this);
    ImpEnemyConfig.buildHitBox(this);
  }

  /// Called every game tick
  @override
  void update(double dt) {
    super.update(dt);
    _controller.onUpdate(dt);
  }

  /// Called when the Imp receives damage
  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    _controller.onReceiveDamage(attacker, damage, id);
    super.onReceiveDamage(attacker, damage, id);
  }

  /// Called when the Imp dies
  @override
  void onDie() {
    _controller.onDie();
    super.onDie();
  }
}
