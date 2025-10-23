class WizardNpcModel {
  bool isShowingConversation;

  WizardNpcModel({this.isShowingConversation = false});

  void startConversation() {
    isShowingConversation = true;
  }

  void finishConversation() {
    // isShowingConversation = false;
  }
}
