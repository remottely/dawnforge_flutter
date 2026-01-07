import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/enemy_primary_attack_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/attacks/character_fx_particles_animations_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/death/character_fx_sprite_animations_def.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_controller.dart';
import 'package:darkness_dungeon/shared/framework/enemies/dd_base_enemy/dd_base_enemy_model.dart';
import 'package:flutter/foundation.dart';

abstract class DDBaseEnemyView<
  C extends DDBaseEnemyController<M>,
  M extends DDBaseEnemyModel
>
    extends SimpleEnemy
    with BlockMovementCollision, UseLifeBar {
  late final List<DDAnimationDirectional> _comboAttackAnimations;
  int _comboStep = 0;
  bool _isAttackPlaying = false;
  bool _comboQueued = false;
  async.Timer? _comboResetTimer;
  static const Duration _kComboResetDelay = Duration(milliseconds: 450);
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
  Future<void> onLoad() async {
    _controller = createController(createModel());
    add(getHitbox());

    _comboAttackAnimations = await _loadComboAttackAnimations();

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
    _comboResetTimer?.cancel();
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
    _executePrimaryAttackCombo(
      damage: controller.model.primaryAttackDamage,
      interval: controller.model.primaryAttackInterval,
      closeVisionRadius: closeVisionRadius,
      onCloseToPlayer: onCloseToPlayer,
    );
  }

  Future<List<DDAnimationDirectional>> _loadComboAttackAnimations() async {
    final factories = comboAttackAnimationFactories;
    if (factories.isEmpty) {
      return [await _loadDefaultAttackAnimation()];
    }

    final animations = await Future.wait(
      factories.map(
        DDCharacterActionSpriteAnimationHelper
            .loadAnimationDirectionalFromFactory,
      ),
    );

    return animations.isNotEmpty ? animations : [await _loadDefaultAttackAnimation()];
  }

  List<DDAnimationDirectionalFactory> get comboAttackAnimationFactories => const [];

  Future<DDAnimationDirectional> _loadDefaultAttackAnimation() async {
    final animation = await EnemyPrimaryAttackDef.loadAnimationFxRight();
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

  void _executePrimaryAttackCombo({
    required double damage,
    required int interval,
    required double closeVisionRadius,
    void Function(Player)? onCloseToPlayer,
  }) {
    seeAndMoveToPlayer(
      radiusVision: closeVisionRadius,
      closePlayer: (player) {
        onCloseToPlayer?.call(player);
        _onExecutePrimaryAttack(damage: damage, interval: interval);
      },
    );
  }

  void _onExecutePrimaryAttack({required double damage, required int interval}) {
    if (_comboAttackAnimations.isEmpty) {
      return;
    }

    if (_isAttackPlaying) {
      if (_comboQueued) {
        // Already queued; avoid log spam.
        return;
      }
      _comboQueued = true;
      _log('Combo queued (animation running). damage=$damage interval=$interval');
      return;
    }

    _startComboAttack(damage: damage, interval: interval);
  }

  void _startComboAttack({required double damage, required int interval}) {
    final comboAnimation = _comboAttackAnimations[_comboStep];

    _log(
      'Start combo attack step=$_comboStep damage=$damage interval=$interval '
      'isDead=$isDead',
    );

    DDCharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
      animationRight: comboAnimation.right,
      animationLeft: comboAnimation.left,
      animationUp: comboAnimation.up,
      animationDown: comboAnimation.down,
      animationRightUp: comboAnimation.rightUp,
      animationRightDown: comboAnimation.rightDown,
      animationLeftUp: comboAnimation.leftUp,
      animationLeftDown: comboAnimation.leftDown,
      currentAnimation: animation,
      target: this,
      executionStartFrame: 1,
      onActionStart: () {
        _log('onActionStart step=$_comboStep');
        _isAttackPlaying = true;
        _comboResetTimer?.cancel();
      },
      onExecutionFrames: () {
        _log('onExecutionFrames step=$_comboStep isDead=$isDead');
        if (isDead) return;
        _applyPrimaryAttackHit(damage: damage, interval: interval);
      },
      onActionEnd: _handleAttackEnd,
    );

    _comboStep = (_comboStep + 1) % _comboAttackAnimations.length;
  }

  void _handleAttackEnd() {
    _log('onActionEnd step=$_comboStep queued=$_comboQueued');
    _isAttackPlaying = false;

    if (_comboQueued) {
      _comboQueued = false;
      _startComboAttack(
        damage: controller.model.primaryAttackDamage,
        interval: controller.model.primaryAttackInterval,
      );
      return;
    }

    _comboResetTimer?.cancel();
    _comboResetTimer = async.Timer(_kComboResetDelay, () {
      _comboStep = 0;
    });
  }

  void _applyPrimaryAttackHit({required double damage, required int interval}) {
    final player = gameRef.player;
    final Direction direction =
        player != null ? getDirectionToTarget(player) : lastDirection;
    final Vector2 centerOffset = OffsetHelper.getCenterOffset(
      Vector2(EnemyPrimaryAttackDef.componentSize.x / 2, 0),
      direction,
    );

    _log(
      'simpleAttackMelee damage=$damage interval=$interval direction=$direction '
      'offset=(${centerOffset.x.toStringAsFixed(2)},${centerOffset.y.toStringAsFixed(2)}) '
      'time=${DateTime.now().toIso8601String()}',
    );
    simpleAttackMelee(
      size: EnemyPrimaryAttackDef.componentSize,
      damage: damage,
      interval: interval,
      direction: direction,
      centerOffset: centerOffset,
      animationRight: EnemyPrimaryAttackDef.loadAnimationFxRight(),
      execute: AudioManager.instance.playEnemyPrimaryAttackSfx,
    );
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[EnemyAttack] $message');
    }
  }
}
