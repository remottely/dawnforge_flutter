import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/decorations/torch/torch_decoration_config.dart';
import 'package:dawnforge/gameplay/decorations/torch/torch_decoration_model.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';

class TorchDecorationController {
  final TorchDecorationModel model;

  final void Function() onDisplayExclamationEmote;

  final void Function() onToggleTorchState;

  final void Function({
    required DemoPlayer player,
    required void Function(DemoPlayer) observed,
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

  void update(double dt, DemoPlayer? player) {
    if (player == null) return;
    _handleDetectPlayerInCloseVisionRadius(player);
    _updateStaminaRegeneration(dt, player);
  }

  void _updateStaminaRegeneration(double dt, DemoPlayer player) {
    if (model.isDetectPlayer && model.isOn)
      player.processStaminaRegeneration(); // error: The method 'processStaminaRegeneration' isn't defined for the type 'DemoPlayer'.
// Try correcting the name to the name of an existing method, or defining a method named 'processStaminaRegeneration'.
  }

  void dispose() {}

  void toggleTorchState() {
    if (!model.canInteract) return;

    model.toggleIsOn();
    onToggleTorchState();
  }

  void _handleDetectPlayerInCloseVisionRadius(DemoPlayer player) {
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
