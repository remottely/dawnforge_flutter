import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_model.dart';

class TorchDecorationController {
  final TorchDecorationModel model;

  final void Function() onShowEmote;
  final void Function() onTorchInteraction;
  final void Function({
    required GameComponent player,
    required void Function(GameComponent) observed,
    required void Function() notObserved,
    required double radiusVision,
  })
  onCheckPlayerVision;

  TorchDecorationController({
    required this.model,
    required this.onShowEmote,
    required this.onTorchInteraction,
    required this.onCheckPlayerVision,
  });

  void update(double dt, GameComponent? player) {
    if (player == null) return;
    _handlePlayerVision(player);
  }

  void dispose() {}

  // Actions
  void openTorch() {
    if (!model.canBeInteract) return;
    if (model.isOn) {
      model.turnOff();
    } else {
      model.turnOn();
    }
    onTorchInteraction();
  }

  // Private helpers
  void _handlePlayerVision(GameComponent player) {
    onCheckPlayerVision(
      player: player,
      radiusVision: TorchDecorationConfig.kVisionRadius,
      observed: (observedPlayer) {
        if (!model.observedPlayer) {
          model.setObservedPlayer(true);
          onShowEmote();
        }
      },
      notObserved: () {
        if (model.observedPlayer) {
          model.setObservedPlayer(false);
        }
      },
    );
  }
}
