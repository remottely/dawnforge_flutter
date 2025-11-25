import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/joysctick_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_model.dart';

/// Controller for players with enhanced mobility options.
///
/// Extends hybrid combat controller to add run state management,
/// coordinating run toggle input with the view layer for animation
/// and speed changes.
abstract class DDMobilePlayerController<M extends DDMobilePlayerModel>
    extends DDBasePlayerController<M> {
  /// Callback invoked when the run state changes.
  final void Function(bool isRunning) onChangeRunState;

  DDMobilePlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required this.onChangeRunState,
  });

  /// Determines if the action ID corresponds to the run action.
  bool isRunAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) => actionId == JoystickSetup.kRunId || actionId == KeyboardSetup.kRunKey;

  // ============================================================================
  // Input Processing
  // ============================================================================

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    // Handle run toggle (requires both DOWN and UP events)
    if (isRunAction(player: player, actionId: event.id)) {
      _handleRunInput(event.event);
      // return;
    }

    // Delegate other inputs to parent
    super.handleInputAction(player: player, event: event);
  }

  /// Handles run input state changes.
  void _handleRunInput(ActionEvent eventType) {
    if (eventType == ActionEvent.DOWN) {
      model.isRunning = true;
      onChangeRunState.call(true);
    } else if (eventType == ActionEvent.UP) {
      model.isRunning = false;
      onChangeRunState.call(false);
    }
  }
}
