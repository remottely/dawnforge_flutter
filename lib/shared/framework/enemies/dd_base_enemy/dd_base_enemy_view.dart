import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/controllers/enemy_combat_action_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/death/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';

abstract class DDBaseEnemyView<
  C extends DDBaseEnemyController<M>,
  M extends DDBaseEnemyModel
>
    extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  late final C _controller;

  DDBaseEnemyView({
    required super.position,
    required super.size,
    required super.animation,
    required super.speed,
    required super.life,
  });

  M get model => _controller.model;
  C get controller => _controller;

  M createModel();
  C createController(M model);
  RectangleHitbox getHitbox();

  @override
  Future<void> onLoad() {
    _controller = createController(createModel());
    add(getHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    _executeDamageFx(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _executeDieFx();
    removeFromParent();
    super.onDie();
  }

  void _executeDamageFx(double damage) {
    showDamage(
      damage,
      config: CharacterFxParticlesAnimationsConfig.kEnemyShowDamageTextStyle,
      gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
      initVelocityVertical:
          CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
    );
  }

  void _executeDieFx() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterFxSpriteAnimationsConfig.loadExplosionRight7(),
        position: position,
        size: size,
        loop: false,
      ),
    );
  }

  void onDetectPlayerAndMoveToPrimaryAttack({
    required double closeVisionRadius,
    void Function(Player)? onCloseToPlayer,
  }) {
    EnemyCombatActionController.executePrimaryAttack(
      enemy: this,
      damage: _controller.model.primaryAttackDamage,
      interval: _controller.model.primaryAttackInterval,
      closeVisionRadius: closeVisionRadius,
      onCloseToPlayer: onCloseToPlayer,
    );
  }
}
