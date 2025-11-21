import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';

class WizardNpcController {
  final WizardNpcModel model;
  late WizardNpcView _view;

  WizardNpcController({required WizardNpcModel model}) : this.model = model;

  void attachView(WizardNpcView view) => _view = view;

  void onUpdate(double dt) {
    _view.onDetectPlayerInCloseVisionRadius();
  }

  void onPlayerDetected(Player player, {bool interactionRequested = false}) {
    if (!model.hasBeenFirstInteraction ||
        (model.hasBeenFirstInteraction && interactionRequested)) {
      _view.add(
        EmoteManager.displayEmoteAboveCharacter(
          asset: EmoteManager.kQuestionEmoteAsset,
          amount: 8,
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
