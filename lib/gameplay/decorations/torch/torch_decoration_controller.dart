// lib/gameplay/decorations/torch/torch_decoration_controller.dart (COMPLETO)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/decorations/torch/torch_decoration_config.dart';
import 'package:dawnforge/gameplay/decorations/torch/torch_decoration_model.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';

class TorchDecorationController {
  final TorchDecorationModel model;

  final void Function() onDisplayExclamationEmote;
  final void Function() onToggleTorchState;
  
  // ✅ NOVO: Callback para resetar torch regen
  final void Function() onResetPlayerTorchRegen;

  final void Function({
    required DemoPlayer player,
    required void Function(DemoPlayer) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  })
  onDetectPlayerInCloseVisionRadius;

  // ✅ Cache do player para evitar queries repetidas
  DemoPlayer? _cachedPlayer;

  TorchDecorationController({
    required this.model,
    required this.onDisplayExclamationEmote,
    required this.onToggleTorchState,
    required this.onDetectPlayerInCloseVisionRadius,
    required this.onResetPlayerTorchRegen, // ✅ Adiciona callback
  });

  void update(double dt, DemoPlayer? player) {
    if (player == null) return;
    
    // ✅ Atualiza cache do player
    _cachedPlayer = player;
    
    _handleDetectPlayerInCloseVisionRadius(player);
    _updateStaminaRegeneration(dt, player);
  }

  void _updateStaminaRegeneration(double dt, DemoPlayer player) {
    // ✅ Regenera stamina APENAS se:
    // - Player está no range (isDetectPlayer)
    // - Tocha está acesa (isOn)
    if (model.isDetectPlayer && model.isOn) {
      player.processStaminaRegeneration();
    }
  }

  void dispose() {
    _cachedPlayer = null;
  }

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

  void _handlePlayerEntersRange(GameComponent player) {
    if (!model.isDetectPlayer) {
      model.setIsDetectPlayer(true);
      onDisplayExclamationEmote();
    }
  }

  void _handlePlayerExitsRange() {
    if (model.isDetectPlayer) {
      model.setIsDetectPlayer(false);
      
      // ✅ Reseta a regeneração quando player sai do range
      _resetPlayerTorchRegen();
    }
  }
  
  /// ✅ IMPLEMENTADO: Usa player cacheado ou callback
  void _resetPlayerTorchRegen() {
    // Estratégia 1: Usa player cacheado (mais eficiente)
    if (_cachedPlayer != null) {
      _cachedPlayer!.resetTorchRegeneration();
      return;
    }
    
    // Estratégia 2: Fallback - chama callback da view
    onResetPlayerTorchRegen();
  }
}
