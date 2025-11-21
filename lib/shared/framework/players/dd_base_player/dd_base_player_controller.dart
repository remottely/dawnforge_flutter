import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_model.dart';

/// Abstract base controller for all player characters.
///
/// Manages the coordination between player model state and view presentation,
/// handling input processing, resource management, and enemy detection systems.
/// This controller provides common functionality while allowing specialization
/// for character-specific behaviors through abstract methods and callbacks.
///
/// Type Parameters:
/// - [M] The specific model type extending DDBasePlayerModel
abstract class DDBasePlayerController<M extends DDBasePlayerModel> {
  /// The data model containing player state and statistics.
  final M model;

  /// Callback invoked to display an exclamation emote.
  final void Function() onDisplayExclamationEmote;

  /// Callback for delegating enemy visibility checks to the view layer.
  final void Function({
    required double longVisionRadius,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  })
  onDetectEnemyInLongVisionRadius;

  /// Indicates whether stamina regeneration is currently scheduled.
  bool _isStaminaRegenerationPending = false;

  /// Controls whether stamina regeneration should be paused.
  bool _isStaminaRegenerationPaused = false;

  /// Number of active actions consuming stamina.
  int _activeStaminaConsumingActions = 0;

  /// Creates a base player controller with required dependencies.
  ///
  /// [model] The data model to control.
  /// [onDisplayExclamationEmote] Callback for emote display.
  /// [onDetectEnemyInLongVisionRadius] Callback for enemy detection.
  DDBasePlayerController({
    required this.model,
    required this.onDisplayExclamationEmote,
    required this.onDetectEnemyInLongVisionRadius,
  });

  // ============================================================================
  // Abstract Methods - Must be implemented by subclasses
  // ============================================================================

  /// Debounce duration between stamina regeneration ticks.
  Duration get staminaRegenDebounce;

  /// Handles character-specific input actions.
  ///
  /// Subclasses should implement their specific input routing logic here.
  void handleInputAction(JoystickActionEvent event);

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  /// Updates the controller state each frame.
  ///
  /// Processes common systems like stamina regeneration and enemy detection.
  /// Subclasses can override to add additional update logic but should call
  /// super.update(dt) to maintain base functionality.
  void update(double dt) {
    processStaminaRegeneration();
    processEnemyDetection();
  }

  /// Cleans up resources when the controller is no longer needed.
  ///
  /// Subclasses can override to add additional cleanup but should call
  /// super.dispose() to ensure base cleanup occurs.
  void dispose() {
    _isStaminaRegenerationPending = false;
  }

  // ============================================================================
  // Common Systems - Available to all player types
  // ============================================================================

  /// Processes periodic stamina regeneration.
  ///
  /// Uses a debounced approach to regenerate stamina at regular intervals
  /// without creating multiple simultaneous timers.
  void processStaminaRegeneration() {
    if (_isStaminaRegenerationPending || _isStaminaRegenerationPaused) return;

    _isStaminaRegenerationPending = true;

    Future.delayed(staminaRegenDebounce, () {
      _isStaminaRegenerationPending = false;
      if (!_isStaminaRegenerationPaused) {
        model.regenerateStamina();
      }
    });
  }

  /// Pauses stamina regeneration temporarily.
  ///
  /// Used when the player is performing actions that should consume stamina
  /// without automatic regeneration (e.g., shield defense).
  void pauseStaminaRegeneration() {
    _isStaminaRegenerationPaused = true;
  }

  /// Resumes stamina regeneration.
  void resumeStaminaRegeneration() {
    _isStaminaRegenerationPaused = false;
  }

  /// Registers an action that actively consumes stamina.
  ///
  /// Automatically pauses stamina regeneration when first action starts.
  /// Call [endStaminaConsumingAction] when the action completes.
  void beginStaminaConsumingAction() {
    _activeStaminaConsumingActions++;
    if (_activeStaminaConsumingActions == 1) {
      pauseStaminaRegeneration();
    }
  }

  /// Unregisters an action that was consuming stamina.
  ///
  /// Automatically resumes stamina regeneration when all actions complete.
  void endStaminaConsumingAction() {
    _activeStaminaConsumingActions--;
    if (_activeStaminaConsumingActions <= 0) {
      _activeStaminaConsumingActions = 0;
      resumeStaminaRegeneration();
    }
  }

  /// Processes enemy detection and awareness state.
  ///
  /// Continuously checks for enemies within vision range and updates the
  /// model's observation state. Triggers an exclamation emote when enemies
  /// are first detected.
  void processEnemyDetection() {
    onDetectEnemyInLongVisionRadius(
      longVisionRadius: model.longVisionRadius,
      notObserved: () => model.isObservingEnemy = false,
      observed: (List<Enemy> detectedEnemies) {
        if (model.isObservingEnemy) return;

        model.isObservingEnemy = true;
        onDisplayExclamationEmote();
      },
    );
  }

  /// Restores energy to maximum value.
  void restoreEnergy() => model.restoreEnergy();
}
