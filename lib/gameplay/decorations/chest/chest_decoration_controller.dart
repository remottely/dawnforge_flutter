import 'package:dawnforge/gameplay/decorations/chest/chest_decoration_def.dart';
import 'package:dawnforge/gameplay/decorations/chest/chest_decoration_model.dart';
import 'package:dawnforge/shared/framework/character/character.dart';

class ChestDecorationController {
  final ChestDecorationModel model;

  final void Function() onOpenChest;
  final void Function() onDisplayExclamationEmote;
  final void Function({
    required Character player,
    required void Function(Character) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  })
  onDetectPlayerInCloseVisionRadius;

  ChestDecorationController({
    required this.model,
    required this.onOpenChest,
    required this.onDisplayExclamationEmote,
    required this.onDetectPlayerInCloseVisionRadius,
  });

  void update(double dt, Character? player) {
    if (player == null || model.isOpened) return;
    _handleDetectPlayerInCloseVisionRadius(player);
  }

  void dispose() {}

  void openChest() {
    if (!model.canInteract) return;
    model.markAsOpened();
    onOpenChest();
  }

  void _handleDetectPlayerInCloseVisionRadius(Character player) {
    onDetectPlayerInCloseVisionRadius.call(
      player: player,
      closeVisionRadius: ChestDecorationConfig.kCloseVisionRadius,
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
