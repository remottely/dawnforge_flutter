import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_model.dart';

/// Controller for players with enhanced mobility options.
///
/// Extends hybrid combat controller to add run state management,
/// coordinating run toggle input with the view layer for animation
/// and speed changes.
abstract class DDMobilePlayerController<M extends DDMobilePlayerModel>
    extends DDHybridCombatPlayerController<M> {
  /// Callback invoked when the run state changes.
  final void Function(bool isRunning) onRunChange;

  /// Indicates whether the run button/key is currently pressed.
  bool _isRunInputActive = false;

  DDMobilePlayerController({
    required super.model,
    required this.onRunChange,
    required super.onPrimaryAttack,
    required super.onRangedAttack,
    required super.onShowExclamation,
    required super.onCheckEnemyVision,
  });

  /// Indicates whether the run input is currently active.
  bool get isRunButtonPressed => _isRunInputActive;

  // ============================================================================
  // Abstract Input Configuration
  // ============================================================================

  /// Determines if the action ID corresponds to the run action.
  bool isRunAction(dynamic actionId);

  // ============================================================================
  // Input Processing
  // ============================================================================

  @override
  void handleInputAction(JoystickActionEvent event) {
    // Handle run toggle (requires both DOWN and UP events)
    if (isRunAction(event.id)) {
      _handleRunInput(event.event);
      return;
    }

    // Delegate other inputs to parent
    super.handleInputAction(event);
  }

  /// Handles run input state changes.
  void _handleRunInput(ActionEvent eventType) {
    if (eventType == ActionEvent.DOWN) {
      _isRunInputActive = true;
      model.isRunning = true;
      onRunChange(true);
    } else if (eventType == ActionEvent.UP) {
      _isRunInputActive = false;
      model.isRunning = false;
      onRunChange(false);
    }
  }
}
