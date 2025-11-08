import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';

class SunnyPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  SunnyPlayerView(Vector2 position, {required SunnyPlayerModel model})
    : _model = model,
      super(
        animation: SunnyPlayerConfig.animation,
        size: SunnyPlayerConfig.componentSize,
        position: position,
        life: SunnyPlayerConfig.kLife,
        speed: SunnyPlayerConfig.kSpeed,
      ) {
    anchor = Anchor.center;
  }

  final SunnyPlayerModel _model;
  late final SunnyPlayerController _controller;
  late final SynchronizedAttackController _primaryAttackController;
  late final SynchronizedAttackController _fireballAttackController;
  int _movementLockCount = 0;
  JoystickDirectionalEvent? _lastJoystickDirectionalEvent;

  bool get _isMovementLocked => _movementLockCount > 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _initializeVisualConfiguration();
    _initializeController();
    add(SunnyPlayerConfig.hitbox);
    _initializeSynchronizedAttackSystem();
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _controller.update(dt);
    _updateSpriteDirection();
    super.update(dt);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;
    _controller.handleInputAction(event);
    super.onJoystickAction(event);
  }

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    _showDamageFx(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _showDeathFx();
    removeFromParent();
    super.onDie();
  }

  @override
  void onRemove() {
    _primaryAttackController.dispose();
    _fireballAttackController.dispose();
    _controller.dispose();
    super.onRemove();
  }

  // Public API for external interaction
  // void useTool() => _controller.useTool();
  // void switchTool(FarmTool newTool) => _controller.switchTool(newTool);
  // void restoreEnergy() => _controller.restoreEnergy();
  SunnyPlayerModel get model => _controller.model;

  void _updateSpriteDirection() {
    if (velocity.x < 0 && !isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && isFlippedHorizontally) {
      flipHorizontallyAroundCenter();
    }
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    _lastJoystickDirectionalEvent = JoystickDirectionalEvent(
      directional: event.directional,
      intensity: event.intensity,
      radAngle: event.radAngle,
    );
    if (_isMovementLocked) {
      stopMove(forceIdle: true);
      return;
    }
    super.onJoystickChangeDirectional(event);
  }

  void _initializeSynchronizedAttackSystem() {
    _primaryAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
    _fireballAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
  }

  void _initializeVisualConfiguration() {
    setupLighting(SunnyPlayerConfig.lightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
  }

  void _initializeController() {
    _controller = SunnyPlayerController(
      model: _model,
      onPrimaryAttack: _onPlayPrimaryAttack,
      onFireballAttack: _onPlayFireballAttack,
      onToolUse: _onPlayToolAnimation,
      onShowExclamation: _onShowExclamationEmote,
      onCheckEnemyVision: _onCheckEnemyVision,
    );
  }

  /// Private helper methods
  void _showDamageFx(double damage) => showDamage(
    damage,
    config: CharacterFxParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
    gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
    initVelocityVertical:
        CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
  );

  void _showDeathFx() =>
      gameRef.add(SunnyPlayerConfig.createCryptComponent(position));

  /// Controller callback implementations
  bool _onPlayPrimaryAttack(double damage) {
    final executed = _primaryAttackController.execute(AttackType.melee, () {
      CharacterActionSpriteAnimationHelper.playActionAnimation(
        SunnyPlayerConfig.rightAttackAnimation,
        currentAnimation: animation,
        movementComponent: this,
        executionStartFrame: 4,
        // executionEndFrame: 8,
        onActionStart: _lockMovementForAction,
        onActionEnd: _unlockMovementForAction,
        onExecutionFrames: () {
          final Vector2 centerOffset = OffsetHelper.getCenterOffset(
            Vector2(6, 0),
            lastDirection,
          );
          simpleAttackMelee(
            damage: damage,
            animationRight:
                CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
            size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
            centerOffset: centerOffset,
          );

          CameraFx.primaryAttackShake(gameRef);
          AudioManager.instance.playPlayerPrimaryAttackSfx();
          addParticle(
            CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
            position: size,
          );
        },
      );
    });

    if (executed == null) {
      return false;
    }
    return true;
  }

  bool _onPlayFireballAttack(double damage) {
    final executed = _fireballAttackController.execute(AttackType.ranged, () {
      addParticle(
        CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
        position: size,
      );

      final Vector2 centerOffset = OffsetHelper.getCenterOffset(
        Vector2(-16, 0),
        lastDirection,
      );

      simpleAttackRangeByDirection(
        direction: lastDirection,
        damage: damage,
        speed: CharacterFireballAttackConfig.kSpeed,
        animationRight:
            CharacterFireballAttackConfig.createExecutionAnimation(),
        size: CharacterFireballAttackConfig.componentSize,
        // collision: CharacterFireballAttackConfig.createHitbox(),
        lightingConfig: CharacterFireballAttackConfig.lightingConfig,
        animationDestroy:
            CharacterFireballAttackConfig.createDestroyAnimation(),
        onDestroy: () {
          CharacterFireballAttackConfig.playDestroyAudio();
          CameraFx.fireballExplosionShake(gameRef);
        },
        centerOffset: centerOffset,
        attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
      );
      CharacterFireballAttackConfig.playExecutionAudio();
    });

    if (executed == null) {
      return false;
    }
    return true;
  }

  // Vector2 getOffset(Vector2 rightOffset) {
  //   switch (lastDirection) {
  //     case Direction.left:
  //     case Direction.right:
  //     case Direction.up:
  //     case Direction.down:
  //     case Direction.upLeft:
  //     case Direction.upRight:
  //     case Direction.downLeft:
  //     case Direction.downRight:
  //   }
  // }

  void _onPlayToolAnimation() {
    // TODO: Implementar animação de ferramenta
  }

  void _onShowExclamationEmote() {
    add(
      CharacterEmoteManager.displayEmoteAboveCharacter(
        asset: CharacterEmoteManager.kExclamationEmoteAsset,
        amount: 8,
        target: this,
      ),
    );
  }

  void _onCheckEnemyVision({
    required double visionRadius,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  }) {
    seeEnemy(
      radiusVision: visionRadius,
      notObserved: notObserved,
      observed: observed,
    );
  }

  void _lockMovementForAction() {
    if (_movementLockCount == 0) {
      stopMove(forceIdle: true);
    }
    _movementLockCount += 1;
  }

  void _unlockMovementForAction() {
    if (_movementLockCount == 0) {
      return;
    }
    _movementLockCount -= 1;
    if (_movementLockCount == 0) {
      stopMove(forceIdle: true);
      final JoystickDirectionalEvent? event = _lastJoystickDirectionalEvent;
      if (event != null && event.directional != JoystickMoveDirectional.IDLE) {
        _forwardDirectionalEvent(event);
      }
    }
  }

  void _forwardDirectionalEvent(JoystickDirectionalEvent event) {
    final forwardedEvent = JoystickDirectionalEvent(
      directional: event.directional,
      intensity: event.intensity,
      radAngle: event.radAngle,
    );
    _lastJoystickDirectionalEvent = forwardedEvent;
    super.onJoystickChangeDirectional(forwardedEvent);
  }
}
