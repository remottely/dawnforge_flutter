import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch_new/torch_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch_new/torch_decoration_controller.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch_new/torch_decoration_model.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_interactable_decoration.dart';
import 'package:flutter/services.dart';

class TorchDecorationView extends DDInteractableDecoration {
  late final TorchDecorationController _controller;
  late final TextPaint _textConfig;

  TorchDecorationView(Vector2 position, {TorchDecorationModel? model})
    : super.withAnimation(
        animation: TorchDecorationConfig.loadSpriteAnimation(),
        size: TorchDecorationConfig.componentSize,
        position: position,
      ) {
    setupLighting(TorchDecorationConfig.lightingConfig);
    lightingEnabled = true;
    _textConfig = TorchDecorationConfig.createTextConfig(width);
    _initializeController(model ?? TorchDecorationModel());
    _controller.model.markAsOpened();
  }

  TorchDecorationView.empty(Vector2 position, {TorchDecorationModel? model})
    : super.withAnimation(
        animation: TorchDecorationConfig.loadSpriteAnimation(),
        size: TorchDecorationConfig.componentSize,
        position: position,
      ) {
    setupLighting(TorchDecorationConfig.lightingConfig);
    lightingEnabled = false;
    _textConfig = TorchDecorationConfig.createTextConfig(width);
    _initializeController(model ?? TorchDecorationModel());
    _controller.model.markAsClosed();
  }

  // Public API for external interaction
  TorchDecorationModel get model => _controller.model;

  void _initializeController(TorchDecorationModel model) {
    _controller = TorchDecorationController(
      model: model,
      onShowEmote: _showEmote,
      onTorchInteraction: _onTorchInteraction,
      onCheckPlayerVision: _checkPlayerVision,
    );
  }

  @override
  void update(double dt) {
    if (checkInterval(
      TorchDecorationConfig.kVisionCheckIntervalId,
      TorchDecorationConfig.kVisionCheckInterval,
      dt,
    )) {
      _controller.update(dt, gameRef.player);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_controller.model.observedPlayer && !_controller.model.isOn) {
      final textPosition = TorchDecorationConfig.getTextPosition(width, height);
      _textConfig.render(
        canvas,
        TorchDecorationConfig.kInteractionPromptText,
        textPosition,
      );
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_controller.model.canBeInteract &&
        event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kInteractionKey) {
      _controller.openTorch();
      return true;
    }
    return false;
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  /// Private helper methods - Controller callbacks implementation
  void _showEmote() {
    add(EmoteManager.getDecorationAnimatedObject(size));
  }

  void _onTorchInteraction() {
    if (model.isOn) {
      lightingEnabled = true;
    } else {
      lightingEnabled = false;
    }
  }

  void _checkPlayerVision({
    required GameComponent player,
    required void Function(GameComponent) observed,
    required void Function() notObserved,
    required double radiusVision,
  }) {
    seeComponent(
      player,
      observed: observed,
      notObserved: notObserved,
      radiusVision: radiusVision,
    );
  }
}
