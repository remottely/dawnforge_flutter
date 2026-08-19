import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:dawnforge/game/modules/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:dawnforge/game/systems/audio/audio_manager.dart';
import 'package:dawnforge/game/systems/ui/emote_manager.dart';

class WizardNpcController {
  final WizardNpcModel model;
  late WizardNpcView _view;

  WizardNpcController({required this.model});

  void attachView(WizardNpcView view) => _view = view;

  void onUpdate(double dt) {
    _view.onDetectPlayerInCloseVisionRadius();
  }

  void onPlayerDetected(Player player, {bool interactionRequested = false}) {
    if (!model.hasBeenFirstInteraction ||
        (model.hasBeenFirstInteraction && interactionRequested)) {
      _view.add(
        EmoteManager.displayEmoteAboveCharacter(
          animation: EmoteManager.loadQuestionEmote(),
          target: _view,
        ),
      );
      _view.showConversation(player);
    }
  }

  void onConversationChanged(int index) {
    AudioManager.instance.playConversationInteractionSfx();
  }

  void onConversationFinished() {
    AudioManager.instance.playConversationInteractionSfx();
  }
}
