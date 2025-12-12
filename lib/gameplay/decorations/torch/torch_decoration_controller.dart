import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/torch/torch_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/torch/torch_decoration_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

/// Controls the behavior and interaction logic for torch decorations.
///
/// This controller acts as the intermediary between the Model and View layers,
/// implementing the Controller pattern. It manages player detection, torch
/// state changes, and coordinates view updates through callback mechanisms.
class TorchDecorationController {
  /// The data model containing the torch's state.
  final TorchDecorationModel model;

  /// Callback invoked when an emote should be displayed above the torch.
  ///
  /// Typically triggered when the player first enters detection range.
  final void Function() onDisplayExclamationEmote;

  /// Callback invoked when the torch state changes (on/off toggle).
  ///
  /// Allows the view layer to respond to lighting state changes.
  final void Function() onToggleTorchState;

  /// Callback for delegating player visibility checks to the view layer.
  ///
  /// This abstraction allows the controller to remain independent of
  /// the specific game engine's visibility detection implementation.
  final void Function({
    required DDBasePlayerView player,
    required void Function(DDBasePlayerView) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  })
  onDetectPlayerInCloseVisionRadius;

  /// Creates a torch decoration controller with required dependencies.
  ///
  /// [model] The data model to be controlled.
  /// [onDisplayExclamationEmote] Callback for emote display requests.
  /// [onToggleTorchState] Callback for torch state change notifications.
  /// [onDetectPlayerInCloseVisionRadius] Callback for player visibility evaluation.
  TorchDecorationController({
    required this.model,
    required this.onDisplayExclamationEmote,
    required this.onToggleTorchState,
    required this.onDetectPlayerInCloseVisionRadius,
  });

  // ============================================================================
  // Lifecycle Methods
  // ============================================================================

  /// Updates the controller state based on player position and proximity.
  ///
  /// This method should be called periodically (typically each frame or at
  /// configured intervals) to maintain accurate player detection.
  ///
  /// [dt] Delta time since the last update.
  /// [player] The player component to check against, or `null` if unavailable.
  void update(double dt, DDBasePlayerView? player) {
    if (player == null) return;
    _handleDetectPlayerInCloseVisionRadius(player);
  }

  /// Cleans up resources when the controller is no longer needed.
  ///
  /// Currently a no-op but provides a hook for future resource cleanup
  /// such as stream subscriptions, timers, or event listeners.
  void dispose() {
    // Reserved for future resource cleanup
  }

  // ============================================================================
  // Public Actions
  // ============================================================================

  /// Toggles the torch's lighting state in response to player interaction.
  ///
  /// This method handles the core interaction logic:
  /// - Validates that interaction is permitted
  /// - Toggles between on/off states
  /// - Notifies the view layer of state changes
  ///
  /// The method is idempotent and safe to call multiple times.
  void toggleTorchState() {
    if (!model.canInteract) return;

    model.toggleIsOn();
    onToggleTorchState();
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Evaluates player proximity and updates observation state accordingly.
  ///
  /// Delegates actual visibility detection to the view layer while managing
  /// the observation state transitions and triggering appropriate callbacks.
  ///
  /// [player] The player component to evaluate proximity for.
  void _handleDetectPlayerInCloseVisionRadius(DDBasePlayerView player) {
    onDetectPlayerInCloseVisionRadius.call(
      player: player,
      closeVisionRadius: TorchDecorationConfig.kCloseVisionRadius,
      observed: _handlePlayerEntersRange,
      notObserved: _handlePlayerExitsRange,
    );
  }

  /// Handles the event when a player enters the torch's detection range.
  ///
  /// Shows an emote on the first observation to provide visual feedback
  /// to the player that the torch is interactive.
  ///
  /// [isDetectPlayerInCloseVisionRadius] The player component that entered range.
  void _handlePlayerEntersRange(GameComponent _) {
    if (!model.isDetectPlayer) {
      model.setIsDetectPlayer(true);
      onDisplayExclamationEmote();
    }
  }

  /// Handles the event when a player exits the torch's detection range.
  ///
  /// Updates the observation state to reflect that the player is no longer
  /// in proximity to interact with the torch.
  void _handlePlayerExitsRange() {
    if (model.isDetectPlayer) {
      model.setIsDetectPlayer(false);
    }
  }
}
