import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';

/// Controls the behavior and game logic for the Sunny player character.
///
/// This controller acts as the intermediary between the Model and View layers,
/// implementing the Controller pattern in MVC architecture. It manages:
/// - Input processing and action dispatching
/// - Resource management (stamina regeneration)
/// - Enemy detection and awareness systems
/// - Coordination between model state and view presentation
///
/// The controller remains independent of rendering concerns, delegating all
/// visual feedback through callback mechanisms to maintain proper separation
/// of concerns.
class SunnyPlayerController {
  /// The data model containing player state and statistics.
  final SunnyPlayerModel model;

  // ============================================================================
  // View Layer Callbacks
  // ============================================================================

  /// Callback invoked when the run state changes.
  ///
  /// [isRunning] Whether the character should be in running state.
  final void Function(bool isRunning) onRunChange;

  /// Callback invoked to execute the primary melee attack.
  ///
  /// [damage] The damage value to apply.
  /// Returns `true` if the attack was successfully executed.
  final bool Function(double damage) onPrimaryAttack;

  /// Callback invoked to execute the fireball ranged attack.
  ///
  /// [damage] The damage value to apply.
  /// Returns `true` if the attack was successfully executed.
  final bool Function(double damage) onFireballAttack;

  /// Callback invoked to execute a farming tool action.
  final void Function() onToolUse;

  /// Callback invoked to display an exclamation emote.
  final void Function() onShowExclamation;

  /// Callback for delegating enemy visibility checks to the view layer.
  final void Function({
    required double visionRadius,
    required void Function() notObserved,
    required void Function(List<Enemy> enemies) observed,
  })
  onCheckEnemyVision;

  // ============================================================================
  // Internal State
  // ============================================================================

  /// Indicates whether stamina regeneration is currently scheduled.
  ///
  /// Prevents multiple simultaneous regeneration timers from being created.
  bool _isStaminaRegenerationPending = false;

  /// Indicates whether a tool action is currently being executed.
  ///
  /// Prevents tool spam and enforces action completion before next use.
  bool _isToolActionInProgress = false;

  /// Indicates whether the run button/key is currently pressed.
  ///
  /// Tracked separately from the view's running state to handle
  /// button release events properly.
  bool _isRunInputActive = false;

  /// Creates a player controller with required dependencies.
  ///
  /// All callbacks must be provided to enable proper coordination between
  /// the controller logic and view presentation.
  ///
  /// [model] The data model to control.
  /// [onRunChange] Callback for run state changes.
  /// [onPrimaryAttack] Callback for primary attack execution.
  /// [onFireballAttack] Callback for fireball attack execution.
  /// [onToolUse] Callback for tool action execution.
  /// [onShowExclamation] Callback for emote display.
  /// [onCheckEnemyVision] Callback for enemy detection.
  SunnyPlayerController({
    required this.model,
    required this.onRunChange,
    required this.onPrimaryAttack,
    required this.onFireballAttack,
    required this.onToolUse,
    required this.onShowExclamation,
    required this.onCheckEnemyVision,
  });

  // ============================================================================
  // Public Accessors
  // ============================================================================

  /// Indicates whether the run input is currently active.
  ///
  /// Useful for external systems that need to query input state without
  /// modifying it.
  bool get isRunButtonPressed => _isRunInputActive;

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  /// Updates the controller state each frame.
  ///
  /// Handles periodic tasks such as stamina regeneration and enemy detection.
  /// Should be called every frame from the view's update method.
  ///
  /// [dt] Delta time since the last update.
  void update(double dt) {
    _processStaminaRegeneration();
    _processEnemyDetection();
  }

  /// Cleans up resources when the controller is no longer needed.
  ///
  /// Cancels pending timers and resets internal state to prevent
  /// memory leaks and unexpected behavior after disposal.
  void dispose() {
    _isStaminaRegenerationPending = false;
  }

  // ============================================================================
  // Input Processing
  // ============================================================================

  /// Processes joystick and keyboard action inputs.
  ///
  /// Routes input events to the appropriate action handlers based on
  /// the action ID and event type. Handles both button press and release
  /// events where applicable.
  ///
  /// [event] The input action event to process.
  void handleInputAction(JoystickActionEvent event) {
    // Handle run toggle (requires both DOWN and UP events)
    if (_isRunAction(event.id)) {
      _handleRunInput(event.event);
      return;
    }

    // All other actions only respond to button press
    if (event.event != ActionEvent.DOWN) return;

    if (_isPrimaryAttackAction(event.id)) {
      executePrimaryAttack();
    } else if (_isFireballAttackAction(event.id)) {
      executeFireballAttack();
    }
  }

  /// Determines if the action ID corresponds to the run action.
  bool _isRunAction(dynamic actionId) =>
      actionId == JoystickSetup.kRunId || actionId == KeyboardSetup.kRunKey;

  /// Determines if the action ID corresponds to the primary attack action.
  bool _isPrimaryAttackAction(dynamic actionId) =>
      actionId == JoystickSetup.kPrimaryAttackId ||
      actionId == KeyboardSetup.kPrimaryAttackKey;

  /// Determines if the action ID corresponds to the fireball attack action.
  bool _isFireballAttackAction(dynamic actionId) =>
      actionId == JoystickSetup.kFireballAttackId ||
      actionId == KeyboardSetup.kFireballAttackKey;

  /// Handles run input state changes.
  ///
  /// [eventType] The type of action event (DOWN or UP).
  void _handleRunInput(ActionEvent eventType) {
    if (eventType == ActionEvent.DOWN) {
      _isRunInputActive = true;
      onRunChange(true);
    } else if (eventType == ActionEvent.UP) {
      _isRunInputActive = false;
      onRunChange(false);
    }
  }

  // ============================================================================
  // Combat Actions
  // ============================================================================

  /// Executes the primary melee attack if resources are sufficient.
  ///
  /// Validates stamina availability before delegating to the view for
  /// animation and damage application. Consumes stamina only if the
  /// attack is successfully executed.
  void executePrimaryAttack() {
    if (!model.canExecutePrimaryAttack) return;

    final bool wasExecuted = onPrimaryAttack.call(
      SunnyPlayerConfig.kPrimaryAttackDamage,
    );

    if (!wasExecuted) return;

    model.consumeStamina(SunnyPlayerConfig.kPrimaryAttackStaminaCost);
  }

  /// Executes the fireball ranged attack if resources are sufficient.
  ///
  /// Validates stamina availability before delegating to the view for
  /// projectile spawning and effects. Consumes stamina only if the
  /// attack is successfully executed.
  void executeFireballAttack() {
    if (!model.canExecuteFireballAttack) return;

    final bool wasExecuted = onFireballAttack.call(
      SunnyPlayerConfig.kFireballAttackDamage,
    );

    if (!wasExecuted) return;

    model.consumeStamina(SunnyPlayerConfig.kFireballAttackStaminaCost);
  }

  // ============================================================================
  // Farming Actions
  // ============================================================================

  /// Executes a farming tool action if resources are sufficient.
  ///
  /// Prevents tool spam through an internal cooldown mechanism. Energy
  /// is consumed immediately and the tool animation is triggered through
  /// the callback.
  ///
  /// Cooldown duration: 500ms
  void useTool() {
    if (_isToolActionInProgress || !model.canExecuteToolAction) return;

    _isToolActionInProgress = true;
    model.consumeEnergy(SunnyPlayerConfig.kToolActionEnergyCost);
    onToolUse();

    // Reset cooldown after a brief delay
    Future.delayed(
      const Duration(milliseconds: 500),
      () => _isToolActionInProgress = false,
    );
  }

  /// Switches the currently equipped farming tool.
  ///
  /// Delegates directly to the model. Tool availability validation should
  /// occur at a higher level (e.g., inventory system) before calling this method.
  ///
  /// [newTool] The tool to equip.
  void switchTool(FarmTool newTool) => model.switchTool(newTool);

  /// Restores energy to maximum value.
  ///
  /// Typically called when interacting with rest points or consuming
  /// energy restoration items.
  void restoreEnergy() => model.restoreEnergy();

  // ============================================================================
  // Passive Systems
  // ============================================================================

  /// Processes periodic stamina regeneration.
  ///
  /// Uses a debounced approach to regenerate stamina at regular intervals
  /// without creating multiple simultaneous timers. The regeneration amount
  /// and interval are configured in SunnyPlayerConfig.
  void _processStaminaRegeneration() {
    if (_isStaminaRegenerationPending) return;

    _isStaminaRegenerationPending = true;

    Future.delayed(SunnyPlayerConfig.kStaminaRegenDebounce, () {
      _isStaminaRegenerationPending = false;
      model.regenerateStamina();
    });
  }

  /// Processes enemy detection and awareness state.
  ///
  /// Continuously checks for enemies within vision range and updates the
  /// model's observation state. Triggers an exclamation emote when enemies
  /// are first detected to provide player feedback.
  void _processEnemyDetection() {
    onCheckEnemyVision(
      visionRadius: SunnyPlayerConfig.kVisionRadius,
      notObserved: () => model.isObservingEnemy = false,
      observed: (List<Enemy> detectedEnemies) {
        if (model.isObservingEnemy) return;

        model.isObservingEnemy = true;
        onShowExclamation();
      },
    );
  }
}
