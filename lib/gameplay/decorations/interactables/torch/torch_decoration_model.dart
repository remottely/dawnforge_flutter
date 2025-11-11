/// Represents the data model for a torch decoration component.
///
/// This model encapsulates the state and business logic related to torch
/// decorations, following the MVC pattern as the Model layer. It manages
/// the torch's on/off state and player observation status.
class TorchDecorationModel {
  bool _isPlayerObserving;
  bool _isTorchLit;

  /// Creates a torch decoration model with optional initial state.
  ///
  /// [initialObservedPlayer] Initial player observation state. Defaults to `false`.
  /// [initialIsOn] Initial torch lighting state. Defaults to `false`.
  TorchDecorationModel({bool? initialObservedPlayer, bool? initialIsOn})
    : _isPlayerObserving = initialObservedPlayer ?? false,
      _isTorchLit = initialIsOn ?? false;

  // ============================================================================
  // Public Accessors
  // ============================================================================

  /// Indicates whether the player is currently observing this torch.
  ///
  /// Returns `true` when the player is within vision range of the torch.
  bool get observedPlayer => _isPlayerObserving;

  /// Indicates whether the torch is currently lit and emitting light.
  ///
  /// Returns `true` when the torch is in the "on" state.
  bool get isOn => _isTorchLit;

  // ============================================================================
  // Business Logic Validations
  // ============================================================================

  /// Determines whether the torch can be interacted with by the player.
  ///
  /// Currently requires the player to be observing the torch.
  /// Future enhancement: Add check for player having a fire source.
  ///
  /// Returns `true` if interaction is allowed.
  bool get canBeInteract => _isPlayerObserving; // && playerHasFireSource;

  // ============================================================================
  // State Mutations
  // ============================================================================

  /// Updates the player observation state.
  ///
  /// This should be called when the player enters or exits the torch's
  /// detection radius.
  ///
  /// [value] The new observation state.
  void setObservedPlayer(bool value) => _isPlayerObserving = value;

  /// Lights the torch, enabling its lighting effects.
  ///
  /// This method transitions the torch to the "on" state, which typically
  /// triggers visual lighting effects in the view layer.
  void turnOn() => _isTorchLit = true;

  /// Extinguishes the torch, disabling its lighting effects.
  ///
  /// This method transitions the torch to the "off" state, which typically
  /// removes visual lighting effects in the view layer.
  void turnOff() => _isTorchLit = false;
}
