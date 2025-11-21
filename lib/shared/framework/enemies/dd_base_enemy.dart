import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/enemy_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy_model.dart';

abstract class DDBaseEnemy<
  C extends DDBaseEnemyController,
  M extends DDBaseEnemyModel
>
    extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  late final C controller;

  DDBaseEnemy({
    required super.position,
    required super.size,
    required super.animation,
    required super.speed,
    required super.life,
  });

  C createController(M model);

  M createModel();

  RectangleHitbox createHitbox();

  @override
  Future<void> onLoad() {
    final model = createModel();
    controller = createController(model);
    add(createHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    controller.update(dt);
    super.update(dt);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    showDamageFx(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    handleDeathFx();
    removeFromParent();
    super.onDie();
  }

  @override
  void onRemove() {
    controller.dispose();
    super.onRemove();
  }

  void showDamageFx(double damage) {
    showDamage(
      damage,
      config: CharacterFxParticlesAnimationsConfig.kEnemyShowDamageTextStyle,
      gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
      initVelocityVertical:
          CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
    );
  }

  void handleDeathFx() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterFxSpriteAnimationsConfig.createExplosionRight7(),
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
    EnemyPrimaryAttackConfig.execute(
      enemy: this,
      damage: controller.model.primaryAttackDamage,
      interval: controller.model.primaryAttackInterval,
      closeVisionRadius: closeVisionRadius,
      onCloseToPlayer: onCloseToPlayer,
    );
  }
}
