import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_model.dart';

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

  /// Tracks the number of active action locks preventing animation changes.
  int _activeAnimationLockCount = 0;

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

  /// Determines if animation changes are currently restricted.
  bool get _isAnimationLocked => _activeAnimationLockCount > 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _walkAnimation = createWalkAnimation();
    _runAnimation = createRunAnimation();
    replaceAnimation(_walkAnimation);
  }

  // ============================================================================
  // Abstract Animation Factory Methods
  // ============================================================================

  /// Creates the walking animation set.
  SimpleDirectionAnimation createWalkAnimation();

  /// Creates the running animation set.
  SimpleDirectionAnimation createRunAnimation();

  // ============================================================================
  // Controller Factory Override - Add Run Callback
  // ============================================================================

  @override
  C createCombatController({
    required M model,
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
    return createMobileController(
      model: model,
      onRunChange: handleRunStateChange,
      onPrimaryAttack: onPrimaryAttack,
      onRangedAttack: onRangedAttack,
      onShowExclamation: onShowExclamation,
      onCheckEnemyVision: onCheckEnemyVision,
    );
  }

  /// Creates the mobile controller with all required callbacks.
  C createMobileController({
    required M model,
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
  });

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
  void handleRunStateChange(bool shouldRun) {
    if (_isInRunningState == shouldRun) return;

    _isInRunningState = shouldRun;

    if (shouldRun) {
      speed = _baseSpeed * model.runSpeedMultiplier;
      transitionToRunAnimation();
    } else {
      speed = _baseSpeed;
      transitionToWalkAnimation();
    }
  }

  /// Transitions to the running animation set.
  ///
  /// Skips transition during animation locks to prevent interrupting
  /// attack animations and breaking their execution callbacks.
  void transitionToRunAnimation() {
    if (_isAnimationLocked) return;

    replaceAnimation(_runAnimation, doIdle: isIdle);
  }

  /// Transitions to the walking animation set.
  ///
  /// Skips transition during animation locks to prevent interrupting
  /// attack animations and breaking their execution callbacks.
  void transitionToWalkAnimation() {
    if (_isAnimationLocked) return;

    replaceAnimation(_walkAnimation, doIdle: isIdle);
  }

  // ============================================================================
  // Animation Lock Management - Protected API for Attack Implementations
  // ============================================================================

  /// Locks animation changes during action execution.
  ///
  /// Should be called by attack implementations at the start of their
  /// animation sequences to prevent run/walk transitions from interrupting.
  void lockAnimationForAction() {
    _activeAnimationLockCount += 1;
  }

  /// Unlocks animation changes after action completion.
  ///
  /// Should be called by attack implementations at the end of their
  /// animation sequences to allow normal animation transitions to resume.
  void unlockAnimationForAction() {
    if (_activeAnimationLockCount > 0) {
      _activeAnimationLockCount -= 1;
    }
  }
}
