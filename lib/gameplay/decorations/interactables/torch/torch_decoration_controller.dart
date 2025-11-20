import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_model.dart';

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
  final void Function() onShowEmote;

  /// Callback invoked when the torch state changes (on/off toggle).
  ///
  /// Allows the view layer to respond to lighting state changes.
  final void Function() onTorchInteraction;

  /// Callback for delegating player visibility checks to the view layer.
  ///
  /// This abstraction allows the controller to remain independent of
  /// the specific game engine's visibility detection implementation.
  final void Function({
    required GameComponent player,
    required void Function(GameComponent) observed,
    required void Function() notObserved,
    required double radiusVision,
  })
  onDetectPlayerInCloseVisionRadius;

  /// Creates a torch decoration controller with required dependencies.
  ///
  /// [model] The data model to be controlled.
  /// [onShowEmote] Callback for emote display requests.
  /// [onTorchInteraction] Callback for torch state change notifications.
  /// [onDetectPlayerInCloseVisionRadius] Callback for player visibility evaluation.
  TorchDecorationController({
    required this.model,
    required this.onShowEmote,
    required this.onTorchInteraction,
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
  void update(double dt, GameComponent? player) {
    if (player == null) return;
    _evaluatePlayerProximity(player);
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
  void openTorch() {
    if (!model.canBeInteract) return;

    _toggleTorchState();
    onTorchInteraction();
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Toggles the torch between lit and extinguished states.
  void _toggleTorchState() {
    if (model.isOn) {
      model.turnOff();
    } else {
      model.turnOn();
    }
  }

  /// Evaluates player proximity and updates observation state accordingly.
  ///
  /// Delegates actual visibility detection to the view layer while managing
  /// the observation state transitions and triggering appropriate callbacks.
  ///
  /// [player] The player component to evaluate proximity for.
  void _evaluatePlayerProximity(GameComponent player) {
    onDetectPlayerInCloseVisionRadius(
      player: player,
      radiusVision: TorchDecorationConfig.kVisionRadius,
      observed: _handlePlayerEntersRange,
      notObserved: _handlePlayerExitsRange,
    );
  }

  /// Handles the event when a player enters the torch's detection range.
  ///
  /// Shows an emote on the first observation to provide visual feedback
  /// to the player that the torch is interactive.
  ///
  /// [observedPlayer] The player component that entered range.
  void _handlePlayerEntersRange(GameComponent observedPlayer) {
    if (!model.observedPlayer) {
      model.setObservedPlayer(true);
      onShowEmote();
    }
  }

  /// Handles the event when a player exits the torch's detection range.
  ///
  /// Updates the observation state to reflect that the player is no longer
  /// in proximity to interact with the torch.
  void _handlePlayerExitsRange() {
    if (model.observedPlayer) {
      model.setObservedPlayer(false);
    }
  }
}
