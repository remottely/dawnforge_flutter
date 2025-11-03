/// Model: Dados e estado do Chest
/// Contém apenas dados, sem lógica de negócio ou referências externas
class ChestInteractableModel {
  bool _observedPlayer;
  bool _isOpened;

  ChestInteractableModel({bool? initialObservedPlayer, bool? initialIsOpened})
    : _observedPlayer = initialObservedPlayer ?? false,
      _isOpened = initialIsOpened ?? false;

  // Getters
  bool get observedPlayer => _observedPlayer;
  bool get isOpened => _isOpened;

  // Validations
  bool get canBeOpened => _observedPlayer && !_isOpened;

  // State mutations
  void setObservedPlayer(bool value) => _observedPlayer = value;
  void markAsOpened() => _isOpened = true;
}
