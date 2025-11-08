import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
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
    required Vector2 position,
    required Vector2 size,
    required SimpleDirectionAnimation animation,
    required double speed,
    required double life,
  }) : super(
         animation: animation,
         position: position,
         size: size,
         speed: speed,
         life: life,
       );

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

  void seeAndMoveToPrimaryAttack({
    required double closeVisionRadius,
    required void Function(Player) closePlayer,
  }) {
    seeAndMoveToPlayer(
      radiusVision: closeVisionRadius,
      closePlayer: (player) {
        closePlayer.call(player);
        simpleAttackMelee(
          size: CharacterPrimaryAttackConfig.kEnemyPrimaryAttackFxSize,
          damage: controller.model.primaryAttackDamage,
          interval: controller.model.primaryAttackInterval,
          animationRight:
              CharacterPrimaryAttackConfig.createEnemyExecutionAnimation(),
          execute: CharacterPrimaryAttackConfig.playEnemyExecutionSfx,
        );
      },
    );
  }

  void seeAndMoveToFireballAttack({
    required double longVisionRadius,
    required void Function(Player) positioned,
  }) {
    seeAndMoveToAttackRange(
      radiusVision: longVisionRadius,
      positioned: (player) {
        simpleAttackRange(
          animation: CharacterFireballAttackConfig.createExecutionAnimation(),
          animationDestroy:
              CharacterFireballAttackConfig.createDestroyAnimation(),
          size: CharacterFireballAttackConfig.componentSize,
          damage: controller.model.primaryAttackDamage,
          speed: CharacterFireballAttackConfig.kSpeed,
          execute: CharacterFireballAttackConfig.playExecutionAudio,
          onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
          collision: CharacterFireballAttackConfig.createHitbox(),
          lightingConfig: CharacterFireballAttackConfig.lightingConfig,
        );
      },
    );
  }
}
