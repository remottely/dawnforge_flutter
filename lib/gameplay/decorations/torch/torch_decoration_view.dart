import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/emote_manager.dart';
import 'package:darkness_dungeon/gameplay/decorations/torch/torch_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/torch/torch_decoration_controller.dart';
import 'package:darkness_dungeon/gameplay/decorations/torch/torch_decoration_model.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/services.dart';

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
    );
  }

  @override
  Future<void> onLoad() {
    setupLighting(TorchDecorationDef.lighting);
    _interactionPromptTextPaint = TorchDecorationDef.createTextConfig(width);

    if (model.isOn)
      lightingEnabled = true;
    else
      lightingEnabled = false;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (checkInterval(
      TorchDecorationDef.kVisionCheckIntervalId,
      TorchDecorationDef.kVisionCheckInterval,
      dt,
    )) {
      _controller.update(dt, gameRef.player as DDBasePlayerView?);
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
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_isValidInteractionAttempt(event)) {
      _controller.toggleTorchState();
      return true;
    }
    return false;
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

  bool _isValidInteractionAttempt(KeyEvent event) {
    return _controller.model.canInteract &&
        event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kInteractionKey;
  }

  void _onDisplayExclamationEmote() {
    add(EmoteManager.getDecorationAnimatedObject(size));
  }

  void _onToggleTorchState() {
    lightingEnabled = model.isOn;
  }

  void _onDetectPlayerInCloseVisionRadius({
    required DDBasePlayerView player,
    required void Function(DDBasePlayerView) observed,
    required void Function() notObserved,
    required double closeVisionRadius,
  }) {
    seeComponent(
      player as GameComponent,
      radiusVision: closeVisionRadius,
      observed: (GameComponent comp) {
        observed(comp as DDBasePlayerView);
      },
      notObserved: notObserved,
    );
  }
}
