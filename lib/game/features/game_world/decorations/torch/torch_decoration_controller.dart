import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/decorations/torch/torch_decoration_config.dart';
import 'package:dawnforge/game/features/game_world/decorations/torch/torch_decoration_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class TorchDecorationController {
  final TorchDecorationModel model;

  final void Function() onDisplayExclamationEmote;

  final void Function() onToggleTorchState;

  final void Function({
    required DDBasePlayerView player,
    required void Function(DDBasePlayerView) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  })
  onDetectPlayerInCloseVisionRadius;

  // Stamina regeneration system for torches
  // bool _isPlayerInRange = false;
  // double _staminaRegenTimer = 0.0;
  // static const double kStaminaRegenInterval = 2.0; // seconds
  // static const int kStaminaRegenAmount = 5; // stamina points per interval

  TorchDecorationController({
    required this.model,
    required this.onDisplayExclamationEmote,
    required this.onToggleTorchState,
    required this.onDetectPlayerInCloseVisionRadius,
  });

  void update(double dt, DDBasePlayerView? player) {
    if (player == null) return;
    _handleDetectPlayerInCloseVisionRadius(player);
    _updateStaminaRegeneration(dt, player);
  }

  void _updateStaminaRegeneration(double dt, DDBasePlayerView player) {
    if (model.isDetectPlayer && model.isOn)
      player.controller.processStaminaRegeneration();
  }

  void dispose() {}

  void toggleTorchState() {
    if (!model.canInteract) return;

    model.toggleIsOn();
    onToggleTorchState();
  }

  void _handleDetectPlayerInCloseVisionRadius(DDBasePlayerView player) {
    onDetectPlayerInCloseVisionRadius.call(
      player: player,
      closeVisionRadius: TorchDecorationDef.kCloseVisionRadius,
      observed: _handlePlayerEntersRange,
      notObserved: _handlePlayerExitsRange,
    );
  }

  void _handlePlayerEntersRange(GameComponent _) {
    if (!model.isDetectPlayer) {
      model.setIsDetectPlayer(true);
      onDisplayExclamationEmote();
    }
  }

  void _handlePlayerExitsRange() {
    if (model.isDetectPlayer) {
      model.setIsDetectPlayer(false);
    }
  }
}
