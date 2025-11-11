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
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/offset_helper.dart';

/// Visual representation and input handler for the Sunny player character.
///
/// This view component manages rendering, animations, player input, combat mechanics,
/// and visual effects for the main player character. It follows the MVC pattern as
/// the View layer, delegating business logic to the controller while handling all
/// presentation concerns.
///
/// Features:
/// - Dynamic lighting effects
/// - Collision detection and movement blocking
/// - Synchronized combat system integration
/// - Animation state management (walk, run, attack)
/// - Input handling (joystick and keyboard)
/// - Visual effects (damage, death, particles)
class SunnyPlayerView extends SimplePlayer
    with Lighting, BlockMovementCollision {
  final SunnyPlayerModel _playerModel;
  late final SunnyPlayerController _playerController;
  late final SynchronizedAttackController _meleeAttackController;
  late final SynchronizedAttackController _rangedAttackController;

  /// Tracks the number of active action locks preventing movement.
  ///
  /// Multiple systems can lock movement simultaneously (e.g., attack animations,
  /// cutscenes). Movement is only restored when all locks are released.
  int _activeMovementLockCount = 0;

  /// Caches the last joystick directional input for restoration after movement unlock.
  JoystickDirectionalEvent? _bufferedDirectionalInput;

  /// Indicates whether the character is currently in running state.
  bool _isInRunningState = false;

  /// Creates a Sunny player view with the specified position and data model.
  ///
  /// [position] The initial world position for the player character.
  /// [model] The data model containing player state and statistics.
  SunnyPlayerView({required super.position, required SunnyPlayerModel model})
    : _playerModel = model,
      super(
        animation: SunnyPlayerConfig.createWalkAnimation(),
        size: SunnyPlayerConfig.componentSize,
        life: SunnyPlayerConfig.kLife,
        speed: SunnyPlayerConfig.kSpeed,
      ) {
    anchor = Anchor.center;
  }

  /// Provides read-only access to the player's data model.
  SunnyPlayerModel get model => _playerController.model;

  /// Determines if movement is currently restricted by active action locks.
  bool get _isMovementRestricted => _activeMovementLockCount > 0;

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _configureVisualEffects();
    _initializePlayerController();
    _initializeCombatSystems();

    add(SunnyPlayerConfig.hitbox);
  }

  @override
  void update(double dt) {
    if (isDead) return;

    _playerController.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _meleeAttackController.dispose();
    _rangedAttackController.dispose();
    _playerController.dispose();
    super.onRemove();
  }

  // ============================================================================
  // Input Handling
  // ============================================================================

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isDead) return;

    _playerController.handleInputAction(event);
    super.onJoystickAction(event);
  }

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
  // Combat & Damage Handling
  // ============================================================================

  @override
  void onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;

    _displayDamageVisualEffects(damage);
    super.onReceiveDamage(attacker, damage, id);
  }

  @override
  void onDie() {
    _displayDeathVisualEffects();
    removeFromParent();
    super.onDie();
  }

  // ============================================================================
  // Initialization Methods
  // ============================================================================

  /// Configures visual effects such as lighting and joystick-based movement.
  void _configureVisualEffects() {
    setupLighting(SunnyPlayerConfig.lightingConfig);
    setupMovementByJoystick(intensityEnabled: true);
  }

  /// Initializes the player controller with all required callback handlers.
  void _initializePlayerController() {
    _playerController = SunnyPlayerController(
      model: _playerModel,
      onRunChange: _handleRunStateChange,
      onPrimaryAttack: _executeMeleeAttack,
      onFireballAttack: _executeRangedAttack,
      onToolUse: _executeToolAction,
      onShowExclamation: _displayExclamationEmote,
      onCheckEnemyVision: _evaluateEnemyVisibility,
    );
  }

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
  // Visual Effects
  // ============================================================================

  /// Displays damage number and particle effects when the player takes damage.
  ///
  /// [damage] The amount of damage received.
  void _displayDamageVisualEffects(double damage) => showDamage(
    damage,
    config: CharacterFxParticlesAnimationsConfig.kPlayerShowDamageTextStyle,
    gravity: CharacterFxParticlesAnimationsConfig.kShowDamageGravity,
    initVelocityVertical:
        CharacterFxParticlesAnimationsConfig.kShowDamageInitVelocityVertical,
  );

  /// Displays death effects including crypt sprite placement.
  void _displayDeathVisualEffects() =>
      gameRef.add(SunnyPlayerConfig.createCryptComponent(position));

  // ============================================================================
  // Animation Management
  // ============================================================================

  /// Handles transitions between walking and running states.
  ///
  /// Updates movement speed and switches animation sets accordingly.
  /// Prevents animation switching during active action locks to preserve
  /// animation callbacks.
  ///
  /// [shouldRun] Whether the character should be in running state.
  void _handleRunStateChange(bool shouldRun) {
    if (_isInRunningState == shouldRun) {
      return;
    }

    _isInRunningState = shouldRun;

    if (shouldRun) {
      speed = SunnyPlayerConfig.kSpeed * SunnyPlayerConfig.kRunSpeedMultiplier;
      _transitionToRunAnimation();
    } else {
      speed = SunnyPlayerConfig.kSpeed;
      _transitionToWalkAnimation();
    }
  }

  /// Transitions to the running animation set.
  ///
  /// Skips transition during action locks to prevent interrupting
  /// attack animations and breaking their execution callbacks.
  void _transitionToRunAnimation() {
    if (_isMovementRestricted) return;

    replaceAnimation(SunnyPlayerConfig.createRunAnimation(), doIdle: isIdle);
  }

  /// Transitions to the walking animation set.
  ///
  /// Skips transition during action locks to prevent interrupting
  /// attack animations and breaking their execution callbacks.
  void _transitionToWalkAnimation() {
    if (_isMovementRestricted) return;

    replaceAnimation(SunnyPlayerConfig.createWalkAnimation(), doIdle: isIdle);
  }

  // ============================================================================
  // Controller Callback Implementations - Combat Actions
  // ============================================================================

  /// Executes the primary melee attack with visual effects and damage application.
  ///
  /// This method coordinates:
  /// - Animation playback with precise frame timing
  /// - Movement locking during attack execution
  /// - Damage hitbox creation and positioning
  /// - Visual effects (particles, camera shake)
  /// - Audio feedback
  ///
  /// [damage] The amount of damage to inflict on hit targets.
  ///
  /// Returns `true` if the attack was successfully executed, `false` if on cooldown.
  bool _executeMeleeAttack(double damage) {
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

  /// Applies the melee damage hitbox with proper positioning and effects.
  ///
  /// [damage] The damage value to apply on hit.
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
  }

  /// Executes the ranged fireball attack with projectile spawning and effects.
  ///
  /// This method handles:
  /// - Projectile creation and trajectory
  /// - Lighting effects on the projectile
  /// - Destruction animation and effects
  /// - Audio feedback
  /// - Camera shake on impact
  ///
  /// [damage] The amount of damage the fireball inflicts on hit.
  ///
  /// Returns `true` if the attack was successfully executed, `false` if on cooldown.
  bool _executeRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = _rangedAttackController.execute(
      AttackType.ranged,
      () {
        _spawnFireballProjectile(damage);
        _triggerFireballAttackEffects();
      },
    );

    return executionInfo != null;
  }

  /// Spawns the fireball projectile with all configured properties.
  ///
  /// [damage] The damage value for the projectile.
  void _spawnFireballProjectile(double damage) {
    final Vector2 projectileOffset = OffsetHelper.getCenterOffset(
      Vector2(-16, 0),
      lastDirection,
    );

    simpleAttackRangeByDirection(
      direction: lastDirection,
      damage: damage,
      speed: CharacterFireballAttackConfig.kSpeed,
      animationRight: CharacterFireballAttackConfig.createExecutionAnimation(),
      size: CharacterFireballAttackConfig.componentSize,
      lightingConfig: CharacterFireballAttackConfig.lightingConfig,
      animationDestroy: CharacterFireballAttackConfig.createDestroyAnimation(),
      onDestroy: _handleFireballDestruction,
      centerOffset: projectileOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }

  /// Triggers visual and audio effects for fireball attack execution.
  void _triggerFireballAttackEffects() {
    addParticle(
      CharacterFxParticlesAnimationsConfig.createFireballAttackParticles(),
      position: size,
    );
    CharacterFireballAttackConfig.playExecutionAudio();
  }

  /// Handles effects when a fireball projectile is destroyed.
  void _handleFireballDestruction() {
    CharacterFireballAttackConfig.playDestroyAudio();
    CameraFx.fireballExplosionShake(gameRef);
  }

  // ============================================================================
  // Controller Callback Implementations - Utility Actions
  // ============================================================================

  /// Executes the tool action animation and logic.
  ///
  /// TODO: Implement tool-specific animations and effects (hoe, watering can, etc.)
  void _executeToolAction() {
    // Future implementation: Tool-specific animations and game logic
  }

  /// Displays an exclamation emote above the character's head.
  ///
  /// Typically used when detecting enemies or interactive objects.
  void _displayExclamationEmote() {
    add(
      EmoteManager.displayEmoteAboveCharacter(
        asset: EmoteManager.kExclamationEmoteAsset,
        amount: 8,
        target: this,
      ),
    );
  }

  /// Evaluates enemy visibility within the specified radius.
  ///
  /// Provides an abstraction layer between the controller and the
  /// Bonfire framework's enemy detection system.
  ///
  /// [visionRadius] The detection radius in world units.
  /// [notObserved] Callback invoked when no enemies are in range.
  /// [observed] Callback invoked when enemies are detected, providing the list.
  void _evaluateEnemyVisibility({
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

  // ============================================================================
  // Movement Lock Management
  // ============================================================================

  /// Locks player movement during action execution.
  ///
  /// Implements a counting mechanism allowing multiple simultaneous locks.
  /// Movement is halted immediately and buffered input is preserved for
  /// restoration after all locks are released.
  void _lockMovementForAction() {
    if (_activeMovementLockCount == 0) {
      stopMove(forceIdle: true);
    }
    _activeMovementLockCount += 1;
  }

  /// Unlocks player movement after action completion.
  ///
  /// Decrements the lock counter and restores movement only when all locks
  /// are released. Automatically resumes buffered directional input if the
  /// player was attempting to move during the lock period.
  void _unlockMovementForAction() {
    if (_activeMovementLockCount == 0) return;

    _activeMovementLockCount -= 1;

    if (_activeMovementLockCount == 0) {
      _restoreBufferedMovementInput();
    }
  }

  /// Restores buffered directional input after movement unlock.
  ///
  /// If the player was holding a directional input during the lock period,
  /// this method re-applies that input to resume movement seamlessly.
  void _restoreBufferedMovementInput() {
    stopMove(forceIdle: true);

    final JoystickDirectionalEvent? bufferedEvent = _bufferedDirectionalInput;
    if (bufferedEvent != null &&
        bufferedEvent.directional != JoystickMoveDirectional.IDLE) {
      _forwardDirectionalInputEvent(bufferedEvent);
    }
  }

  /// Forwards a directional input event to the base player system.
  ///
  /// Creates a fresh event instance to avoid reference issues and updates
  /// the buffered input for future lock/unlock cycles.
  ///
  /// [event] The directional event to forward.
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
