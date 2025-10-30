import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_emote_controller.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';

class WizardNpcController {
  final WizardNpcModel model;
  late WizardNpcView _view;

  WizardNpcController({required WizardNpcModel model}) : this.model = model;

  void attachView(WizardNpcView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _view.checkPlayerProximity();
  }

  void onPlayerDetected(Player player, {bool interactionRequested = false}) {
    if (!model.hasBeenFirstInteraction ||
        (model.hasBeenFirstInteraction && interactionRequested)) {
      // Use a flag
      _view.add(
        CharacterEmoteController.displayEmoteAboveCharacter(
          asset: CharacterEmoteController.kQuestionEmoteAsset,
          target: _view,
        ),
      );
      _view.showConversation(player);
    }
  }

  void onConversationChanged(int index) {
    GameplayAudioManager.instance.playInteraction();
  }

  void onConversationFinished() {
    GameplayAudioManager.instance.playInteraction();
  }
}
