import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/combat/character_fx_sprite_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/emote_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_config.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_controller.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/chest/chest_decoration_model.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/life_potion_decoration.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_view.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/services.dart';

class ChestDecorationView extends DDInputReceiverDecorationView {
  late final ChestDecorationController _controller;
  late final TextPaint _textConfig;

  ChestDecorationView({
    required super.position,
    required ChestDecorationModel model,
  }) : super.withAnimation(
         animation: ChestDecorationConfig.loadChestAnimation(),
         size: ChestDecorationConfig.componentSize,
       ) {
    _initializeController(model);
  }

  // Public API for external interaction
  ChestDecorationModel get model => _controller.model;

  void _initializeController(ChestDecorationModel model) {
    _controller = ChestDecorationController(
      model: model,
      onOpenChest: _onOpenChest,
      onDisplayExclamationEmote: _onDisplayExclamationEmote,
      onDetectPlayerInCloseVisionRadius: _onDetectPlayerInCloseVisionRadius,
    );
  }

  @override
  Future<void> onLoad() {
    _textConfig = ChestDecorationConfig.createTextConfig(width);
    add(ChestDecorationConfig.createHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (checkInterval(
      ChestDecorationConfig.kVisionCheckIntervalId,
      ChestDecorationConfig.kVisionCheckInterval,
      dt,
    )) {
      _controller.update(dt, gameRef.player as DDBasePlayerView?);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_controller.model.isDetectPlayer && !_controller.model.isOpened) {
      final textPosition = ChestDecorationConfig.getTextPosition(width, height);
      _textConfig.render(
        canvas,
        ChestDecorationConfig.interactionPromptText,
        textPosition,
      );
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_controller.model.canInteract &&
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
  void _onDisplayExclamationEmote() {
    add(EmoteManager.getDecorationAnimatedObject(size));
  }

  void _onOpenChest() {
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

  void _addSmokeExplosion(Vector2 potionPosition) {
    gameRef.add(
      AnimatedGameObject(
        animation:
            CharacterFxSpriteAnimationsConfig.createExplosionSmokeRight5(),
        position: potionPosition,
        size: size,
        loop: false,
      ),
    );
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
