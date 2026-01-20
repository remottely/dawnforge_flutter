import 'package:dawnforge/game/modules/decorations/chest/chest_decoration_def.dart';
import 'package:dawnforge/game/modules/decorations/chest/chest_decoration_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class ChestDecorationController {
  final ChestDecorationModel model;

  final void Function() onOpenChest;
  final void Function() onDisplayExclamationEmote;
  final void Function({
    required DDBasePlayerView player,
    required void Function(DDBasePlayerView) observed,
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

  void update(double dt, DDBasePlayerView? player) {
    if (player == null || model.isOpened) return;
    _handleDetectPlayerInCloseVisionRadius(player);
  }

  void dispose() {}

  void openChest() {
    if (!model.canInteract) return;
    model.markAsOpened();
    onOpenChest();
  }

  void _handleDetectPlayerInCloseVisionRadius(DDBasePlayerView player) {
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
