import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_model.dart';
import 'package:flutter/foundation.dart';

/// Abstract view for players with enhanced mobility (walk + run).
///
/// Extends hybrid combat player to add run state management and animation
/// switching. This class coordinates run input with speed changes and
/// animation transitions while maintaining all combat capabilities.
///
/// Features:
/// - Dynamic speed adjustment based on run state
/// - Animation set switching (walk ↔ run)
/// - Movement lock awareness (prevents animation changes during attacks)
///
/// Type Parameters:
/// - [C] The specific controller type extending DDMobilePlayerController
/// - [M] The specific model type extending DDMobilePlayerModel
abstract class DDMobilePlayerView<
  C extends DDMobilePlayerController<M>,
  M extends DDMobilePlayerModel
>
    extends DDHybridCombatPlayerView<C, M> {
  /// Base movement speed (walking speed).
  final double _baseSpeed; // TODO(Kevin): use the bonfire speed?

  /// Tracks whether the character is currently in running state.
  bool _isInRunningState = false;

  /// Tracks the number of active action locks preventing movement and animation changes.
  /// When > 0, the character cannot move or switch between walk/run animations.
  int _activeActionLockCount = 0;

  /// When true, an animation transition is pending and should be applied
  /// as soon as action locks are released (checked in update()).
  bool _pendingAnimationChange = false;

  late final SimpleDirectionAnimation _walkAnimation;
  late final SimpleDirectionAnimation _runAnimation;

  DDMobilePlayerView({
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required double speed,
  }) : _baseSpeed = speed,
       super(speed: speed, animation: null);

  /// Determines if actions (movement + animation changes) are currently locked.
  @protected
  bool get isActionLocked => _activeActionLockCount > 0;

  /// Caches the last joystick directional input for restoration.
  JoystickDirectionalEvent? _bufferedDirectionalInput;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _walkAnimation = getWalkAnimation();
    _runAnimation = getRunAnimation();
    replaceAnimation(_walkAnimation);
  }

  // ============================================================================
  // Abstract Animation Factory Methods
  // ============================================================================

  /// Creates the walking animation get.
  SimpleDirectionAnimation getWalkAnimation();

  /// Creates the running animation get.
  SimpleDirectionAnimation getRunAnimation();

  // ============================================================================
  // Controller Factory Override - Add Run Callback
  // ============================================================================

  @override
  C createCombatController({
    required M model,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  }) {
    return createMobileController(
      model: model,
      onChangeRunState: _handleChangeRunState,
      onExecutePrimaryAttack: onExecutePrimaryAttack,
      onExecuteRangedAttack: onExecuteRangedAttack,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
    );
  }

  /// Creates the mobile controller with all required callbacks.
  C createMobileController({
    required M model,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
  });

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

    if (isActionLocked) return;

    super.onJoystickChangeDirectional(event);
  }

  // ============================================================================
  // Run State Management
  // ============================================================================

  /// Handles transitions between walking and running states.
  ///
  /// Updates movement speed and switches animation sets accordingly.
  /// Prevents animation switching during active action locks to preserve
  /// attack animation callbacks.
  ///
  /// [shouldRun] Whether the character should be in running state.
  void _handleChangeRunState(bool shouldRun) {
    if (_isInRunningState == shouldRun) return;

    _isInRunningState = shouldRun;

    if (shouldRun) {
      // Update speed immediately so movement (when restored) uses correct speed
      speed = _baseSpeed * model.runSpeedMultiplier;
      // If currently locked, defer the animation change until update/unlock
      if (isActionLocked) {
        _pendingAnimationChange = true;
      } else {
        transitionToRunAnimation();
      }
    } else {
      speed = _baseSpeed;
      if (isActionLocked) {
        _pendingAnimationChange = true;
      } else {
        transitionToWalkAnimation();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_pendingAnimationChange && !isActionLocked) {
      _pendingAnimationChange = false;
      if (_isInRunningState) {
        transitionToRunAnimation();
      } else {
        transitionToWalkAnimation();
      }
    }
  }

  /// Transitions to the running animation set.
  ///
  /// Skips transition during action locks to prevent interrupting
  /// attack animations and breaking their execution callbacks.
  void transitionToRunAnimation() {
    if (isActionLocked) return;

    replaceAnimation(_runAnimation, doIdle: isIdle);
  }

  /// Transitions to the walking animation set.
  ///
  /// Skips transition during action locks to prevent interrupting
  /// attack animations and breaking their execution callbacks.
  void transitionToWalkAnimation() {
    if (isActionLocked) return;

    replaceAnimation(_walkAnimation, doIdle: isIdle);
  }

  // ============================================================================
  // Action Lock Management - Protected API for Attack Implementations
  // ============================================================================

  /// Locks actions (movement + animation changes) during attack execution.
  ///
  /// Should be called by attack implementations at the start of their
  /// animation sequences to prevent movement and run/walk transitions.
  void lockAction() {
    _activeActionLockCount += 1;
  }

  /// Unlocks actions (movement + animation changes) after attack completion.
  ///
  /// Should be called by attack implementations at the end of their
  /// animation sequences to allow normal behavior to resume.
  void unlockAction() {
    if (_activeActionLockCount > 0) {
      _activeActionLockCount -= 1;

      // Notify subclass when fully unlocked for movement restoration
      if (_activeActionLockCount == 0) {
        onActionFullyUnlocked();
      }
    }
  }

  /// Called when all action locks are released.
  ///
  /// Subclasses can override to restore buffered movement or perform
  /// other cleanup actions. After this callback, the animation will be
  /// synchronized with the current run state if the character is moving.
  @protected
  void onActionFullyUnlocked() {
    _restoreBufferedMovementInput();
  }

  /// Restores buffered directional input after action unlock.
  void _restoreBufferedMovementInput() {
    final JoystickDirectionalEvent? bufferedEvent = _bufferedDirectionalInput;
    if (bufferedEvent != null &&
        bufferedEvent.directional != JoystickMoveDirectional.IDLE) {
      super.onJoystickChangeDirectional(bufferedEvent);
    }
  }
}
