import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';

/// WizardNpcController
/// ---------------------------------------------------------------------------
/// Gerencia a lógica de interação, timers e a comunicação
/// entre o Model (dados) e a View (componente Bonfire).
class WizardNpcController {
  final WizardNpcModel model;
  WizardNpcView? _view;

  WizardNpcController({required this.model});

  void attachView(WizardNpcView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _view?.checkPlayerProximity();
  }

  void onPlayerDetected(Component player) {
    if (!model.isShowingConversation) {
      _view?.idlePlayer();
      model.startConversation();
      CharacterEmoteController.displayEmoteAboveCharacter(
        gameRef: _view!.gameRef,
        target: _view!,
        assetPath: CharacterEmoteController.kQuestionEmoteAssetPath,
      );
      _view?.initializeDialogue();
    }
  }

  void onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  void onConversationFinished() {
    GameplayAudioManager.playInteraction();
    model.finishConversation();
  }
}
