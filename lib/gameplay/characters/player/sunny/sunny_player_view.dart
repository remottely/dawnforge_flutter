import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/camera/camera_fx.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_view.dart';

/// Visual representation and input handler for the Sunny player character.
///
/// This view implements the mobile player specialization, providing Sunny with
/// hybrid combat capabilities (melee + ranged) and enhanced mobility (walk + run).
///
/// Combat System:
/// - Synchronized attack controllers for cooldown management
/// - Frame-precise animation execution
/// - Dynamic hitbox positioning
/// - Visual and audio feedback coordination
///
/// Mobility System:
/// - Dynamic speed adjustment (walk/run)
/// - Animation set switching
/// - Movement locking during attacks
/// - Buffered input restoration
class SunnyPlayerView
    extends DDMobilePlayerView<SunnyPlayerController, SunnyPlayerModel> {
  late final SynchronizedAttackController _meleeAttackController;
  late final SynchronizedAttackController _rangedAttackController;

  /// Tracks the number of active movement locks.
  int _activeMovementLockCount = 0;

  /// Caches the last joystick directional input for restoration.
  JoystickDirectionalEvent? _bufferedDirectionalInput;

  /// Determines if movement is currently restricted.
  bool get _isMovementRestricted => _activeMovementLockCount > 0;

  SunnyPlayerView({required super.position, required super.model})
    : super(
        animation: SunnyPlayerConfig.createWalkAnimation(),
        size: SunnyPlayerConfig.componentSize,
        life: SunnyPlayerConfig.kLife,
        speed: SunnyPlayerConfig.kSpeed,
      );

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeCombatSystems();
  }

  @override
  void onRemove() {
    _meleeAttackController.dispose();
    _rangedAttackController.dispose();
    super.onRemove();
  }

  // ============================================================================
  // Factory Methods - Configuration
  // ============================================================================

  @override
  SunnyPlayerController createMobileController({
    required SunnyPlayerModel model,
    required void Function(bool isRunning) onRunChange,
    required bool Function(double damage) onPrimaryAttack,
    required bool Function(double damage) onRangedAttack,
    required void Function() onShowExclamation,
    required void Function({
      required double visionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onCheckEnemyVision,
  }) {
    return SunnyPlayerController(
      model: model,
      onRunChange: onRunChange,
      onPrimaryAttack: onPrimaryAttack,
      onRangedAttack: onRangedAttack,
      onShowExclamation: onShowExclamation,
      onCheckEnemyVision: onCheckEnemyVision,
    );
  }

  @override
  RectangleHitbox createHitbox() => SunnyPlayerConfig.hitbox;

  @override
  LightingConfig get lightingConfig => SunnyPlayerConfig.lightingConfig;

  @override
  GameDecoration createDeathMarker(Vector2 position) =>
      SunnyPlayerConfig.createCryptComponent(position);

  @override
  SimpleDirectionAnimation createWalkAnimation() =>
      SunnyPlayerConfig.createWalkAnimation();

  @override
  SimpleDirectionAnimation createRunAnimation() =>
      SunnyPlayerConfig.createRunAnimation();

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initializes the synchronized attack system controllers for combat.
  void _initializeCombatSystems() {
    _meleeAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
    _rangedAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
  }

  // ============================================================================
  // Input Handling Override - Movement Locking
  // ============================================================================

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    _bufferedDirectionalInput = JoystickDirectionalEvent(
      directional: event.directional,
      intensity: event.intensity,
      radAngle: event.radAngle,
    );

    if (_isMovementRestricted) {
      stopMove(forceIdle: true);
      return;
    }

    super.onJoystickChangeDirectional(event);
  }

  // ============================================================================
  // Combat Execution Implementation
  // ============================================================================

  @override
  bool executePrimaryAttack(double damage) {
    final AttackExecutionInfo? executionInfo = _meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playExecutionOnceWithIdle(
          SunnyPlayerConfig.loadRightAttackAnimation(),
          currentAnimation: animation,
          movementComponent: this,
          executionStartFrame: 4,
          onActionStart: _lockMovementForAction,
          onActionEnd: _unlockMovementForAction,
          onExecutionFrames: () {
            _applyMeleeDamageHitbox(damage);
            _triggerMeleeAttackEffects();
          },
        );
      },
    );

    return executionInfo != null;
  }

  @override
  bool executeRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = _rangedAttackController.execute(
      AttackType.ranged,
      () {
        _spawnFireballProjectile(damage);
        _triggerFireballAttackEffects();
      },
    );

    return executionInfo != null;
  }

  /// Applies the melee damage hitbox with proper positioning.
  void _applyMeleeDamageHitbox(double damage) {
    final Vector2 attackCenterOffset = OffsetHelper.getCenterOffset(
      Vector2(6, 0),
      lastDirection,
    );

    simpleAttackMelee(
      damage: damage,
      animationRight:
          CharacterPrimaryAttackConfig.createPlayerExecutionAnimation(),
      size: CharacterPrimaryAttackConfig.kPlayerPrimaryAttackFxSize,
      centerOffset: attackCenterOffset,
    );
  }

  /// Triggers all visual and audio effects for melee attacks.
  void _triggerMeleeAttackEffects() {
    CameraFx.primaryAttackShake(gameRef);
    AudioManager.instance.playPlayerPrimaryAttackSfx();
    addParticle(
      CharacterFxParticlesAnimationsConfig.createPrimaryAttackParticles(),
      position: size,
    );
    lockAnimationForAction();
  }

  /// Spawns the fireball projectile with all configured properties.
  void _spawnFireballProjectile(double damage) {
    CharacterFireballAttackConfig.playerExecute(player: this, damage: damage);
  }

  /// Triggers visual and audio effects for fireball attack execution.
  void _triggerFireballAttackEffects() {
    addParticle(
      CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
      position: size,
    );
    CharacterFireballAttackConfig.playExecutionAudio();
  }

  // ============================================================================
  // Movement Lock Management
  // ============================================================================

  /// Locks player movement during action execution.
  void _lockMovementForAction() {
    if (_activeMovementLockCount == 0) {
      stopMove(forceIdle: true);
    }
    _activeMovementLockCount += 1;
    lockAnimationForAction();
  }

  /// Unlocks player movement after action completion.
  void _unlockMovementForAction() {
    if (_activeMovementLockCount == 0) return;

    _activeMovementLockCount -= 1;

    if (_activeMovementLockCount == 0) {
      _restoreBufferedMovementInput();
    }

    unlockAnimationForAction();
  }

  /// Restores buffered directional input after movement unlock.
  void _restoreBufferedMovementInput() {
    stopMove(forceIdle: true);

    final JoystickDirectionalEvent? bufferedEvent = _bufferedDirectionalInput;
    if (bufferedEvent != null &&
        bufferedEvent.directional != JoystickMoveDirectional.IDLE) {
      _forwardDirectionalInputEvent(bufferedEvent);
    }
  }

  /// Forwards a directional input event to the base player system.
  void _forwardDirectionalInputEvent(JoystickDirectionalEvent event) {
    final forwardedEvent = JoystickDirectionalEvent(
      directional: event.directional,
      intensity: event.intensity,
      radAngle: event.radAngle,
    );
    _bufferedDirectionalInput = forwardedEvent;
    super.onJoystickChangeDirectional(forwardedEvent);
  }
}
