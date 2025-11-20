import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_model.dart';

class ChestDecorationController {
  final ChestDecorationModel model;

  final void Function() onShowEmote;
  final void Function() onOpenChest;
  final void Function({
    required GameComponent player,
    required void Function(GameComponent) observed,
    required void Function() notObserved,
    required double radiusVision,
  })
  onDetectPlayerInCloseVisionRadius;

  ChestDecorationController({
    required this.model,
    required this.onShowEmote,
    required this.onOpenChest,
    required this.onDetectPlayerInCloseVisionRadius,
  });

  void update(double dt, GameComponent? player) {
    if (player == null || model.isOpened) return;
    _handlePlayerVision(player);
  }

  void dispose() {}

  // Actions
  void openChest() {
    if (!model.canBeOpened) return;
    model.markAsOpened();
    onOpenChest();
  }

  // Private helpers
  void _handlePlayerVision(GameComponent player) {
    onDetectPlayerInCloseVisionRadius(
      player: player,
      radiusVision: ChestDecorationConfig.kVisionRadius,
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
