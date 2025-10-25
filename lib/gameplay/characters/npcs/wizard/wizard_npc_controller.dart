import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';

/// WizardNpcController
/// ---------------------------------------------------------------------------
/// Orchestrates logic, timers, and communication between Model (data) and View (Bonfire component).
class WizardNpcController {
  final WizardNpcModel _model;
  late WizardNpcView _view;

  WizardNpcController({required WizardNpcModel model}) : _model = model;

  /// Attach the View to the Controller
  void attachView(WizardNpcView view) {
    _view = view;
  }

  /// Called every game tick by the View
  void onUpdate(double dt) {
    _view.checkPlayerProximity();
  }

  /// Called when the player is detected near the wizard
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

  /// Called when the dialogue changes (player advances conversation)
  void onDialogueChanged(int index) {
    GameplayAudioManager.playInteraction();
  }

  /// Called when the conversation finishes
  void onConversationFinished() {
    GameplayAudioManager.playInteraction();
    _model.finishConversation();
  }
}
