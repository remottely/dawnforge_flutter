import 'dart:math';
import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/systems/audio/audio_manager.dart';
import 'package:dawnforge/game/core/systems/combat/attacks/enemy_primary_attack_def.dart';
import 'package:dawnforge/game/core/systems/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:dawnforge/game/core/systems/combat/death/character_fx_sprite_animations_def.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';
import 'package:dawnforge/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';
import 'package:dawnforge/shared/framework/utils/dd_animation_directional.dart';
import 'package:dawnforge/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
import 'package:flutter/material.dart';

abstract class DDBaseEnemyView<
  C extends DDBaseEnemyController<M>,
  M extends DDBaseEnemyModel
>
    extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  /// Override para definir largura fixa da barra de vida. Se null, usa size.x
  double get fixedLifeBarWidth;
  Vector2 get fixedLifeBarOffset;

  static const int _kDefaultInitialAttackDelayMs = 350;
  static const int _kContactResetGraceMs = 600;

  late final C _controller;
  late final DDAnimationDirectional? _attackAnimation;
  bool _isAttackPlaying = false;
  int _currentAttackToken = 0;
  int _interruptedAttackToken = -1;
  late final int _meleeAttackId;
  DateTime? _firstCloseContactAt;
  DateTime? _lastCloseContactAt;
  DateTime? _lastAttackAt;

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
    _meleeAttackId = Random().nextInt(0x7fffffff);
    add(getHitbox());
    _attackAnimation = await _loadAttackAnimation();
    await super.onLoad();
    // if (fixedLifeBarWidth != null) {
    // setupLifeBar(size: Vector2(fixedLifeBarWidth!, 4.0));
    // }

    setupLifeBar(
      size: Vector2(fixedLifeBarWidth, 4),
      backgroundColor: Colors.black,
      borderColor: Colors.white,
      borderWidth: 1,
      colors: [Colors.red, Colors.orange, Colors.green],
      borderRadius: BorderRadius.circular(1),
      barLifeDrawPosition: BarLifeDrawPosition.top,
      offset: fixedLifeBarOffset,
      // textOffset: Vector2(0, -5),
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 3,
        fontWeight: FontWeight.bold,
      ),
      showLifeText: true,
      barLifetextBuilder: (currentLife, maxLife) {
        return ' ${currentLife.toInt()} / ${maxLife.toInt()}';
        // return '${currentLife.toInt()}';
      },
      // padding: EdgeInsets.all(4),
    );
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _resetContactTrackingIfLost();
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
    _cancelCurrentAttack();
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
        _handleClosePlayer(player, onCloseToPlayer);
      },
    );
  }

  /// Override this to provide custom attack animation factory
  /// By default, returns null and will use a simple directional animation
  DDAnimationDirectionalFactory? get attackAnimationFactory => null;

  Future<DDAnimationDirectional?> _loadAttackAnimation() async {
    final factory = attackAnimationFactory;

    if (factory != null) {
      // Usa o factory fornecido pelo enemy específico
      return DDCharacterActionSpriteAnimationHelper.loadAnimationDirectionalFromFactory(
        factory,
      );
    }

    return null;
  }

  void _handleClosePlayer(
    Player player,
    void Function(Player)? onCloseToPlayer,
  ) {
    final now = DateTime.now();
    _lastCloseContactAt = now;
    _firstCloseContactAt ??= now;

    onCloseToPlayer?.call(player);

    if (!_hasCompletedInitialDelay(now)) {
      return;
    }

    if (!_canStartNewAttack(now)) {
      return;
    }

    _startMeleeAttack();
  }

  bool _hasCompletedInitialDelay(DateTime now) {
    final firstContact = _firstCloseContactAt;
    if (firstContact == null) {
      return false;
    }

    return now.difference(firstContact).inMilliseconds >= initialAttackDelayMs;
  }

  bool _canStartNewAttack(DateTime now) {
    if (_isAttackPlaying) {
      return false;
    }

    final lastAttack = _lastAttackAt;
    if (lastAttack == null) {
      return true;
    }

    return now.difference(lastAttack).inMilliseconds >=
        controller.model.primaryAttackInterval;
  }

  void _startMeleeAttack() {
    final attackToken = ++_currentAttackToken;
    simpleAttackMelee(
      size: EnemyPrimaryAttackDef.componentSize,
      damage: controller.model.primaryAttackDamage,
      interval: controller.model.primaryAttackInterval,
      id: _meleeAttackId,
      animationRight: _attackAnimation != null
          ? null
          : EnemyPrimaryAttackDef.loadAnimationFxRight(),
      execute: () {
        if (_interruptedAttackToken == attackToken) {
          _log('Attack canceled before execution');
          return;
        }

        final now = DateTime.now();
        _lastAttackAt = now;

        _log(
          'Attack executed: damage=${controller.model.primaryAttackDamage} '
          'time=${now.toIso8601String()}',
        );
        AudioManager.instance.playEnemyPrimaryAttackSfx();

        // Inicia a animação do corpo do enemy apenas quando o ataque é realmente executado
        _playAttackBodyAnimation();
      },
    );
  }

  void _resetContactTrackingIfLost() {
    final lastContact = _lastCloseContactAt;
    if (lastContact == null) {
      return;
    }

    final elapsed = DateTime.now().difference(lastContact).inMilliseconds;
    if (elapsed > contactResetGraceMs) {
      _firstCloseContactAt = null;
      _lastCloseContactAt = null;
    }
  }

  int get initialAttackDelayMs => _kDefaultInitialAttackDelayMs;

  int get contactResetGraceMs => _kContactResetGraceMs;

  void _cancelCurrentAttack() {
    _interruptedAttackToken = _currentAttackToken;
    _isAttackPlaying = false;
    _lastAttackAt = DateTime.now();

    // Volta para animação de idle/walk para refletir o cancelamento
    idle();
    stopMove(forceIdle: true);
  }

  void _playAttackBodyAnimation() {
    // Evita múltiplas animações simultâneas
    if (_isAttackPlaying || _attackAnimation == null) {
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
    GameLogger.debug('[EnemyAttack] $message');
  }
}
