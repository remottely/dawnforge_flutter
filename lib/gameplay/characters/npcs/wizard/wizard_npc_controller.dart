import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';

class WizardNpcController {
  final WizardNpcModel _model;
  late WizardNpcView _view;

  WizardNpcController({required WizardNpcModel model}) : _model = model;

  void attachView(WizardNpcView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _view.checkPlayerProximity();
  }

  void onPlayerDetected(Component player) {
    if (!_model.isInteracted) {
      _view.idlePlayer();
      _model.startConversation();
      CharacterEmoteController.displayEmoteAboveCharacter(
        gameRef: _view.gameRef,
        target: _view,
        assetPath: CharacterEmoteController.kQuestionEmoteAssetPath,
      );
      _view.initializeDialogue();
    }
  }

  void onDialogueChanged(int index) {
    GameplayAudioManager.instance.playInteraction();
  }

  void onConversationFinished() {
    GameplayAudioManager.instance.playInteraction();
    _model.finishConversation();
  }
}
