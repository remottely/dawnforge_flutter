/// WizardNpcModel
/// ---------------------------------------------------------------------------
/// Armazena todo o estado e a lógica de negócios do Wizard NPC.
/// Não tem conhecimento da View (Bonfire/Flutter).
class WizardNpcModel {
  bool isShowingConversation;

  WizardNpcModel({this.isShowingConversation = false});

  void startConversation() {
    isShowingConversation = true;
  }

  void finishConversation() {
    // isShowingConversation = false;
    // hasInteracted = true; // Removed reference to hasInteracted
  }
}
