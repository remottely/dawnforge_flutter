import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_player_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/chest/chest_interactable_config.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/chest/chest_interactable_controller.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/chest/chest_interactable_model.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/life_potion_interactable.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_interactable_decoration.dart';
import 'package:flutter/services.dart';

/// View: Renderização e integração com o Bonfire
/// Delega lógica para o Controller via callbacks
class ChestInteractableView extends DDInteractableDecoration {
  late final ChestInteractableController _controller;
  late final TextPaint _textConfig;

  ChestInteractableView(Vector2 position, {ChestInteractableModel? model})
    : super.withAnimation(
        animation: ChestInteractableConfig.chestAnimation,
        size: ChestInteractableConfig.componentSize,
        position: position,
      ) {
    _textConfig = ChestInteractableConfig.createTextConfig(width);
    _initializeController(model ?? ChestInteractableModel());
  }

  void _initializeController(ChestInteractableModel model) {
    _controller = ChestInteractableController(
      model: model,
      onShowEmote: _showEmote,
      onShowInteractionPrompt: () {}, // Será renderizado no render()
      onHideInteractionPrompt: () {}, // Será renderizado no render()
      onOpenChest: _handleChestOpened,
      onCheckPlayerVision: _checkPlayerVision,
    );
  }

  @override
  void update(double dt) {
    if (checkInterval(
      ChestInteractableConfig.kVisionCheckIntervalId,
      ChestInteractableConfig.kVisionCheckInterval,
      dt,
    )) {
      _controller.update(dt, gameRef.player);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_controller.model.observedPlayer && !_controller.model.isOpened) {
      final textPosition = ChestInteractableConfig.getTextPosition(
        width,
        height,
      );
      _textConfig.render(
        canvas,
        ChestInteractableConfig.kInteractionPromptText,
        textPosition,
      );
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_controller.model.canBeOpened &&
        event is KeyDownEvent &&
        event.logicalKey == GameplayKeyboardConfig.kInteractionKey) {
      _controller.openChest();
      return true;
    }
    return false;
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  // Public API for external interaction
  ChestInteractableModel get model => _controller.model;

  /// Private helper methods - Controller callbacks implementation
  void _showEmote() {
    add(
      AnimatedGameObject(
        animation: ChestInteractableConfig.emoteAnimation,
        size: size,
        position: size / -2,
        loop: false,
      ),
    );
  }

  void _handleChestOpened() {
    _spawnPotions();
    removeFromParent();
  }

  void _spawnPotions() {
    final potion1Position = position + ChestInteractableConfig.kPotion1Offset;
    final potion2Position = position + ChestInteractableConfig.kPotion2Offset;

    gameRef.add(
      LifePotionDecorationView(
        position: potion1Position,
        healAmount: ChestInteractableConfig.kHealAmountPerPotion,
      ),
    );

    gameRef.add(
      LifePotionDecorationView(
        position: potion2Position,
        healAmount: ChestInteractableConfig.kHealAmountPerPotion,
      ),
    );

    _addSmokeExplosion(potion1Position);
    _addSmokeExplosion(potion2Position);
  }

  void _addSmokeExplosion(Vector2 position) {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: position,
        size: ChestInteractableConfig.smokeExplosionSize,
        loop: false,
      ),
    );
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
