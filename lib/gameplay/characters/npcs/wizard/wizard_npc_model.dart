/// WizardNpcModel
/// ---------------------------------------------------------------------------
/// Stores all state and business logic for the wizard NPC.
/// No knowledge of the View or Controller.
class WizardNpcModel {
  /// Whether the wizard is currently showing a conversation/dialogue
  bool isInteracted;

  WizardNpcModel({this.isInteracted = false});

  /// Mark the start of a conversation
  void startConversation() {
    isInteracted = true;
  }

  /// Mark the end of a conversation
  void finishConversation() {}
}
