import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_model.dart';

class ChestDecorationController {
  final ChestDecorationModel model;

  final void Function() onOpenChest;
  final void Function() onDisplayExclamationEmote;
  final void Function({
    required GameComponent player,
    required void Function(GameComponent) observed,
    required void Function() notObserved,
    required double radiusVision,
  })
  onDetectPlayerInCloseVisionRadius;

  ChestDecorationController({
    required this.model,
    required this.onOpenChest,
    required this.onDisplayExclamationEmote,
    required this.onDetectPlayerInCloseVisionRadius,
  });

  void update(double dt, GameComponent? player) {
    if (player == null || model.isOpened) return;
    _handleDetectPlayerInCloseVisionRadius(player);
  }

  void dispose() {}

  // Actions
  void openChest() {
    if (!model.canInteract) return;
    model.markAsOpened();
    onOpenChest();
  }

  // Private helpers
  void _handleDetectPlayerInCloseVisionRadius(GameComponent player) {
    onDetectPlayerInCloseVisionRadius(
      player: player,
      radiusVision: ChestDecorationConfig.kVisionRadius,
      observed: (_) {
        if (!model.isDetectPlayer) {
          model.setIsDetectPlayer(true);
          onDisplayExclamationEmote();
        }
      },
      notObserved: () {
        if (model.isDetectPlayer) {
          model.setIsDetectPlayer(false);
        }
      },
    );
  }
}
