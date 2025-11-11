class TorchDecorationModel {
  bool _observedPlayer;
  bool _isOn;

  TorchDecorationModel({bool? initialObservedPlayer, bool? initialIsOn})
    : _observedPlayer = initialObservedPlayer ?? false,
      _isOn = initialIsOn ?? false;

  // Getters
  bool get observedPlayer => _observedPlayer;
  bool get isOn => _isOn;

  // Validations
  bool get canBeInteract => _observedPlayer; // && playerHasFireSource;

  // State mutations
  void setObservedPlayer(bool value) => _observedPlayer = value;
  void markAsOpened() => _isOn = true;
  void markAsClosed() => _isOn = false;
}
