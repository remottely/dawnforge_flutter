import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/enemy_primary_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/death/character_fx_sprite_animations_def.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
import 'package:flutter/foundation.dart';

abstract class DDBaseEnemyView<
  C extends DDBaseEnemyController<M>,
  M extends DDBaseEnemyModel
>
    extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  late final C _controller;
  late final DDAnimationDirectional _attackAnimation;
  bool _isAttackPlaying = false;

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
  Future<void> onLoad() async {
    _controller = createController(createModel());
    add(getHitbox());
    _attackAnimation = await _loadAttackAnimation();
    await super.onLoad();
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
    seeAndMoveToPlayer(
      radiusVision: closeVisionRadius,
      closePlayer: (player) {
        onCloseToPlayer?.call(player);
        
        // Deixa o Bonfire gerenciar o interval através do simpleAttackMelee
        // Quando o interval passar, o callback execute é chamado e aí iniciamos a animação
        simpleAttackMelee(
          size: EnemyPrimaryAttackDef.componentSize,
          damage: controller.model.primaryAttackDamage,
          interval: controller.model.primaryAttackInterval,
          animationRight: EnemyPrimaryAttackDef.loadAnimationFxRight(),
          execute: () {
            _log(
              'Attack executed: damage=${controller.model.primaryAttackDamage} '
              'time=${DateTime.now().toIso8601String()}',
            );
            AudioManager.instance.playEnemyPrimaryAttackSfx();
            
            // Inicia a animação do corpo do enemy apenas quando o ataque é realmente executado
            _playAttackBodyAnimation();
          },
        );
      },
    );
  }

  /// Override this to provide custom attack animation factory
  /// By default, returns null and will use a simple directional animation
  DDAnimationDirectionalFactory? get attackAnimationFactory => null;

  /// Override this to provide custom attack animation (fallback if no factory)
  Future<SpriteAnimation> attackAnimationFallback() {
    return EnemyPrimaryAttackDef.loadAnimationFxRight();
  }

  Future<DDAnimationDirectional> _loadAttackAnimation() async {
    final factory = attackAnimationFactory;
    
    if (factory != null) {
      // Usa o factory fornecido pelo enemy específico
      return DDCharacterActionSpriteAnimationHelper
          .loadAnimationDirectionalFromFactory(factory);
    }
    
    // Fallback: usa a mesma animação para todas as direções
    final animation = await attackAnimationFallback();
    return DDAnimationDirectional(
      right: animation,
      left: animation,
      up: animation,
      down: animation,
      rightUp: animation,
      rightDown: animation,
      leftUp: animation,
      leftDown: animation,
    );
  }

  void _playAttackBodyAnimation() {
    // Evita múltiplas animações simultâneas
    if (_isAttackPlaying) {
      return;
    }

    _isAttackPlaying = true;

    DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
      animationRight: _attackAnimation.right,
      animationLeft: _attackAnimation.left,
      animationUp: _attackAnimation.up,
      animationDown: _attackAnimation.down,
      animationRightUp: _attackAnimation.rightUp,
      animationRightDown: _attackAnimation.rightDown,
      animationLeftUp: _attackAnimation.leftUp,
      animationLeftDown: _attackAnimation.leftDown,
      currentAnimation: animation,
      target: this,
      executionStartFrame: 1,
      onActionStart: () {
        _log('Attack body animation started');
      },
      onExecutionFrames: () {
        // A animação está apenas visual, o dano já foi aplicado pelo simpleAttackMelee
      },
      onActionEnd: () {
        _isAttackPlaying = false;
        _log('Attack body animation ended');
      },
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[EnemyAttack] $message');
    }
  }
}
