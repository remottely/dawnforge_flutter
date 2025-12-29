import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/enemy_primary_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/death/character_fx_sprite_animations_def.dart';
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
      config: CharacterFxParticlesAnimationsDef.kEnemyShowDamageTextStyle,
      gravity: CharacterFxParticlesAnimationsDef.kShowDamageGravity,
      initVelocityVertical:
          CharacterFxParticlesAnimationsDef.kShowDamageInitVelocityVertical,
    );
  }

  void _executeDieFx() {
    gameRef.add(
      AnimatedGameObject(
        animation: CharacterFxSpriteAnimationsDef.loadAnimationExplosionRight(),
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
    _executePrimaryAttack(
      enemy: this,
      damage: _controller.model.primaryAttackDamage,
      interval: _controller.model.primaryAttackInterval,
      closeVisionRadius: closeVisionRadius,
      onCloseToPlayer: onCloseToPlayer,
    );
  }

  static void _executePrimaryAttack({
    required SimpleEnemy enemy,
    required double damage,
    required int interval,
    required double closeVisionRadius,
    void Function(Player)? onCloseToPlayer,
  }) {
    enemy.seeAndMoveToPlayer(
      radiusVision: closeVisionRadius,
      closePlayer: (player) {
        onCloseToPlayer?.call(player);

        // TODO(Kevin): fix this attackDirection and attackOffset behavior
        // final attackDirection =
        //     _resolveAttackDirection(enemy, player) ?? enemy.lastDirection;
        // final attackOffset = OffsetHelper.getCenterOffset(
        //   Vector2(enemy.width / 2, 0),
        //   attackDirection,
        // );

        enemy.simpleAttackMelee(
          size: EnemyPrimaryAttackDef.componentSize,
          damage: damage,
          interval: interval,
          // direction: attackDirection,
          // centerOffset: attackOffset,
          animationRight: EnemyPrimaryAttackDef.loadAnimationFxRight(),
          execute: AudioManager.instance.playEnemyPrimaryAttackSfx,
        );
      },
    );
  }
}
