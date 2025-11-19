import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
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

  // /// Stores the current input direction for combat actions.
  // ///
  // /// This direction is updated on every directional input, even during
  // /// movement locks, ensuring attacks always use the most recent player intent.
  // /// This matches professional game engine behavior (Unity/Unreal) where
  // /// input direction is decoupled from movement state.
  // Direction _currentInputDirection = Direction.right;

  /// Determines if movement is currently restricted.
  bool get _isMovementRestricted => _activeMovementLockCount > 0;

  SunnyPlayerView({required super.position, required super.model})
    : super(
        // animation: SunnyPlayerConfig.createWalkAnimation,
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
      SunnyPlayerConfig.createWalkAnimation;

  @override
  SimpleDirectionAnimation createRunAnimation() =>
      SunnyPlayerConfig.createRunAnimation;

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

    // // Update input direction for combat system
    // _updateInputDirectionFromEvent(event);

    if (_isMovementRestricted) {
      stopMove(forceIdle: true);
      return;
    }

    super.onJoystickChangeDirectional(event);
  }

  // /// Updates the current input direction based on joystick input.
  // ///
  // /// This method decouples input direction from movement state, ensuring
  // /// combat actions always reflect the player's most recent directional intent.
  // /// This matches professional game engine patterns where input is processed
  // /// independently of movement constraints.
  // void _updateInputDirectionFromEvent(JoystickDirectionalEvent event) {
  //   switch (event.directional) {
  //     case JoystickMoveDirectional.MOVE_UP:
  //       _currentInputDirection = Direction.up;
  //       break;
  //     case JoystickMoveDirectional.MOVE_UP_LEFT:
  //       _currentInputDirection = Direction.upLeft;
  //       break;
  //     case JoystickMoveDirectional.MOVE_UP_RIGHT:
  //       _currentInputDirection = Direction.upRight;
  //       break;
  //     case JoystickMoveDirectional.MOVE_RIGHT:
  //       _currentInputDirection = Direction.right;
  //       break;
  //     case JoystickMoveDirectional.MOVE_DOWN:
  //       _currentInputDirection = Direction.down;
  //       break;
  //     case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
  //       _currentInputDirection = Direction.downRight;
  //       break;
  //     case JoystickMoveDirectional.MOVE_DOWN_LEFT:
  //       _currentInputDirection = Direction.downLeft;
  //       break;
  //     case JoystickMoveDirectional.MOVE_LEFT:
  //       _currentInputDirection = Direction.left;
  //       break;
  //     case JoystickMoveDirectional.IDLE:
  //       // Preserve last direction when idle (standard game behavior)
  //       break;
  //   }
  // }

  // ============================================================================
  // Combat Execution Implementation
  // ============================================================================

  @override
  bool executePrimaryAttack(double damage) {
    final AttackExecutionInfo? executionInfo = _meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playExecutionOnceWithIdle(
          animationRight: SunnyPlayerConfig.loadRightAttackAnimation(),
          animationLeft: SunnyPlayerConfig.loadLeftAttackAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 4,
          onActionStart: _lockMovementForAction,
          onActionEnd: _unlockMovementForAction,
          onExecutionFrames: () {
            _executePrimaryAttackWithEffects(damage: damage);
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
      () => _spawnFireballProjectile(damage),
    );

    return executionInfo != null;
  }

  /// Executes the complete primary attack with all effects.
  void _executePrimaryAttackWithEffects({required double damage}) {
    // Use centralized attack execution
    PlayerPrimaryAttackConfig.execute(player: this, damage: damage);

    // Lock animation after attack
    lockAnimationForAction();
  }

  /// Spawns the fireball projectile with all configured properties.
  void _spawnFireballProjectile(double damage) {
    CharacterFireballAttackConfig.playerExecute(player: this, damage: damage);
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
