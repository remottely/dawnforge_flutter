class WizardNpcModel {
  bool isInteracted;

  WizardNpcModel({this.isInteracted = false});

  void startConversation() {
    isInteracted = true;
  }

  void finishConversation() {}
}
