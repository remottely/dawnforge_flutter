import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_controller.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/torch/torch_decoration_model.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_view.dart';
import 'package:flutter/services.dart';

/// Represents a visual torch decoration component with interactive capabilities.
///
/// This view handles rendering, player interaction, and lighting effects for torch
/// decorations within the game environment. It follows the MVC pattern where this
/// class acts as the View layer.
class TorchDecorationView extends DDInputReceiverDecorationView {
  late final TorchDecorationController _decorationController;
  late final TextPaint _interactionPromptTextPaint;

  /// Creates an active torch decoration with lighting enabled.
  ///
  /// The torch will be initialized in the "on" state with full lighting effects.
  ///
  /// [position] The world position where the torch will be placed.
  /// [model] Optional model data. If not provided, a default model is created.
  TorchDecorationView.lightingEnabled({
    required super.position,
    required TorchDecorationModel model,
  }) : super.withAnimation(
         animation: TorchDecorationConfig.loadSpriteAnimation(),
         size: TorchDecorationConfig.componentSize,
       ) {
    _initializeController(model);
  }

  /// Creates an inactive torch decoration with lighting disabled.
  ///
  /// The torch will be initialized in the "off" state without lighting effects.
  ///
  /// [position] The world position where the torch will be placed.
  /// [model] Optional model data. If not provided, a default model is created.
  TorchDecorationView.lightingDisabled({
    required super.position,
    required TorchDecorationModel model,
  }) : super.withAnimation(
         animation: TorchDecorationConfig.loadSpriteAnimation(),
         size: TorchDecorationConfig.componentSize,
       ) {
    _initializeController(model);
  }

  /// Provides public read-only access to the torch's data model.
  TorchDecorationModel get model => _decorationController.model;

  /// Initializes the controller with the provided model and sets up callback handlers.
  ///
  /// This method wires the controller to the view's private callback implementations,
  /// maintaining proper separation of concerns.
  ///
  /// [model] The data model to be managed by the controller.
  void _initializeController(TorchDecorationModel model) {
    _decorationController = TorchDecorationController(
      model: model,
      onDisplayExclamationEmote: _handleDisplayExclamationEmote,
      onToggleTorchState: _handleToggleTorchState,
      onDetectPlayerInCloseVisionRadius: _handleDetectPlayerInCloseVisionRadius,
    );
  }

  @override
  void onMount() {}

  @override
  Future<void> onLoad() {
    setupLighting(TorchDecorationConfig.lightingConfig);
    _interactionPromptTextPaint = TorchDecorationConfig.createTextConfig(width);

    if (model.isOn)
      lightingEnabled = true;
    else
      lightingEnabled = false;

    return super.onLoad();
  }

  /// Updates the torch state based on player proximity and interaction.
  ///
  /// Performs periodic vision checks to determine if the player is near enough
  /// to interact with the torch.
  ///
  /// [dt] Delta time since the last frame update.
  @override
  void update(double dt) {
    if (checkInterval(
      TorchDecorationConfig.kVisionCheckIntervalId,
      TorchDecorationConfig.kVisionCheckInterval,
      dt,
    )) {
      _decorationController.update(dt, gameRef.player);
    }
    super.update(dt);
  }

  /// Renders the torch decoration and interaction prompt when applicable.
  ///
  /// Displays an interaction prompt text above the torch when the player
  /// is observing it and the torch is currently off.
  ///
  /// [canvas] The canvas on which to render the decoration.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_shouldDisplayInteractionPrompt()) {
      _renderInteractionPrompt(canvas);
    }
  }

  /// Handles keyboard input events for torch interaction.
  ///
  /// Processes the interaction key press when the player is in range
  /// and able to interact with the torch.
  ///
  /// [event] The keyboard event to process.
  /// [keysPressed] Set of currently pressed keys.
  ///
  /// Returns `true` if the event was handled, `false` otherwise.
  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_isValidInteractionAttempt(event)) {
      _decorationController.toggleTorchState();
      return true;
    }
    return false;
  }

  /// Cleans up resources when the decoration is removed from the game.
  @override
  void onRemove() {
    _decorationController.dispose();
    super.onRemove();
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Determines whether the interaction prompt should be displayed.
  ///
  /// Returns `true` when the player is observing the torch and it's turned off.
  bool _shouldDisplayInteractionPrompt() {
    return _decorationController.model.isDetectPlayer &&
        !_decorationController.model.isOn;
  }

  /// Renders the interaction prompt text at the appropriate position.
  ///
  /// [canvas] The canvas on which to render the text.
  void _renderInteractionPrompt(Canvas canvas) {
    final textPosition = TorchDecorationConfig.getTextPosition(width, height);
    _interactionPromptTextPaint.render(
      canvas,
      TorchDecorationConfig.interactionPromptText,
      textPosition,
    );
  }

  /// Validates whether a keyboard event represents a valid interaction attempt.
  ///
  /// Checks if the torch can be interacted with and if the correct key was pressed.
  ///
  /// [event] The keyboard event to validate.
  ///
  /// Returns `true` if this is a valid interaction attempt.
  bool _isValidInteractionAttempt(KeyEvent event) {
    return _decorationController.model.canInteract &&
        event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kInteractionKey;
  }

  // ============================================================================
  // Controller Callback Implementations
  // ============================================================================

  /// Handles the display of an emote animation above the torch.
  ///
  /// This callback is invoked by the controller when an emote should be shown,
  /// typically in response to player interaction.
  void _handleDisplayExclamationEmote() {
    add(EmoteManager.getDecorationAnimatedObject(size));
  }

  /// Handles lighting state changes when the torch is toggled.
  ///
  /// This callback is invoked by the controller when the torch state changes,
  /// enabling or disabling the lighting effect accordingly.
  void _handleToggleTorchState() {
    lightingEnabled = model.isOn;
  }

  /// Evaluates the visibility relationship between the player and the torch.
  ///
  /// This callback provides an abstraction layer between the controller and
  /// the Bonfire framework's visibility detection system.
  ///
  /// [player] The player component to check visibility against.
  /// [observed] Callback invoked when the player is within vision range.
  /// [notObserved] Callback invoked when the player is outside vision range.
  /// [radiusVision] The vision radius for detection.
  void _handleDetectPlayerInCloseVisionRadius({
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
