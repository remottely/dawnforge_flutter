import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_controller.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_model.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/life_potion_decoration.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_interactable_decoration.dart';
import 'package:flutter/services.dart';

class ChestDecorationView extends DDInteractableDecoration {
  late final ChestDecorationController _controller;
  late final TextPaint _textConfig;

  ChestDecorationView(Vector2 position, {ChestDecorationModel? model})
    : super.withAnimation(
        animation: ChestDecorationConfig.loadChestAnimation(),
        size: ChestDecorationConfig.componentSize,
        position: position,
      ) {
    _textConfig = ChestDecorationConfig.createTextConfig(width);
    _initializeController(model ?? ChestDecorationModel());
  }

  // Public API for external interaction
  ChestDecorationModel get model => _controller.model;

  void _initializeController(ChestDecorationModel model) {
    _controller = ChestDecorationController(
      model: model,
      onShowEmote: _showEmote,
      onOpenChest: _handleChestOpened,
      onCheckPlayerVision: _checkPlayerVision,
    );
  }

  @override
  void update(double dt) {
    if (checkInterval(
      ChestDecorationConfig.kVisionCheckIntervalId,
      ChestDecorationConfig.kVisionCheckInterval,
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
      final textPosition = ChestDecorationConfig.getTextPosition(width, height);
      _textConfig.render(
        canvas,
        ChestDecorationConfig.kInteractionPromptText,
        textPosition,
      );
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_controller.model.canBeOpened &&
        event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kInteractionKey) {
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

  /// Private helper methods - Controller callbacks implementation
  void _showEmote() {
    add(EmoteManager.getDecorationAnimatedObject(size));
  }

  void _handleChestOpened() {
    _spawnLifePotions();
    removeFromParent();
  }

  void _spawnLifePotions() {
    _spawnLifePotion();
    _spawnLifePotion();
  }

  void _spawnLifePotion() {
    final random = Random();
    final offset = Vector2(random.nextInt(5) + 1, random.nextInt(5) + 1);
    final potionPosition = position - offset;

    _addSmokeExplosion(potionPosition);
    gameRef.add(
      LifePotionDecorationView(
        position: potionPosition,
        healAmount: ChestDecorationConfig.kHealAmountPerPotion,
      ),
    );
  }

  void _addSmokeExplosion(Vector2 position) {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: position,
        size: ChestDecorationConfig.smokeExplosionSize,
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
