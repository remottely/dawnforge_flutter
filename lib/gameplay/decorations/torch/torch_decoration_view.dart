// lib/gameplay/decorations/torch/torch_decoration_view.dart (ATUALIZADO)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/core/modules/ui/emote_manager.dart';
import 'package:dawnforge/gameplay/decorations/torch/torch_decoration_config.dart';
import 'package:dawnforge/gameplay/decorations/torch/torch_decoration_controller.dart';
import 'package:dawnforge/gameplay/decorations/torch/torch_decoration_model.dart';
import 'package:dawnforge/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_view.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';

class TorchDecorationView extends DDInputReceiverDecorationView {
  late final TorchDecorationController _controller;
  late final TextPaint _interactionPromptTextPaint;

  TorchDecorationView.lightingEnabled({
    required super.position,
    required TorchDecorationModel model,
  }) : super.withAnimation(
         animation: TorchDecorationDef.loadAnimation(),
         size: TorchDecorationDef.componentSize,
       ) {
    _initializeController(model);
  }

  TorchDecorationView.lightingDisabled({
    required super.position,
    required TorchDecorationModel model,
  }) : super.withAnimation(
         animation: TorchDecorationDef.loadAnimation(),
         size: TorchDecorationDef.componentSize,
       ) {
    _initializeController(model);
  }

  TorchDecorationModel get model => _controller.model;

  void _initializeController(TorchDecorationModel model) {
    _controller = TorchDecorationController(
      model: model,
      onDisplayExclamationEmote: _onDisplayExclamationEmote,
      onToggleTorchState: _onToggleTorchState,
      onDetectPlayerInCloseVisionRadius: _onDetectPlayerInCloseVisionRadius,
      onResetPlayerTorchRegen: _onResetPlayerTorchRegen, // ✅ Adiciona callback
    );
  }

  @override
  Future<void> onLoad() {
    setupLighting(TorchDecorationDef.lighting);
    _interactionPromptTextPaint = TorchDecorationDef.createTextConfig(width);

    if (model.isOn) {
      lightingEnabled = true;
    } else {
      lightingEnabled = false;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (checkInterval(
      TorchDecorationDef.kVisionCheckIntervalId,
      TorchDecorationDef.kVisionCheckInterval,
      dt,
    )) {
      _controller.update(dt, gameRef.player as DemoPlayer?);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_shouldDisplayInteractionPrompt()) {
      _renderInteractionPrompt(canvas);
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (_controller.model.canInteract &&
        event.event == ActionEvent.DOWN &&
        InputDef.isInteractionAction(event.id)) {
      _controller.toggleTorchState();
    }
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  bool _shouldDisplayInteractionPrompt() {
    return _controller.model.isDetectPlayer && !_controller.model.isOn;
  }

  void _renderInteractionPrompt(Canvas canvas) {
    final textPosition = TorchDecorationDef.getTextPosition(width, height);
    _interactionPromptTextPaint.render(
      canvas,
      TorchDecorationDef.interactionPromptText,
      textPosition,
    );
  }

  void _onDisplayExclamationEmote() {
    add(EmoteManager.displayEmoteAboveDecoration(size));
  }

  void _onToggleTorchState() {
    lightingEnabled = model.isOn;
  }

  void _onDetectPlayerInCloseVisionRadius({
    required DemoPlayer player,
    required void Function(DemoPlayer) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  }) {
    seeComponent(
      player as GameComponent,
      radiusVision: closeVisionRadius,
      observed: (GameComponent comp) {
        final playerView = comp as DemoPlayer;
        // Register to receive player controller events when player is nearby
        final playerController = gameRef.playerControllers?.firstOrNull;
        if (playerController != null) {
          registerToPlayerController(playerController);
        }
        observed(playerView);
      },
      notObserved: () {
        // Unregister when player leaves
        unregisterFromPlayerController();
        notObserved();
      },
    );
  }

  // ✅ NOVO: Implementação do callback de reset
  void _onResetPlayerTorchRegen() {
    // Pega o player atual e reseta regeneração
    final player = gameRef.player as DemoPlayer?;
    player?.resetTorchRegeneration();
  }
}
