import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/combat/death/character_fx_sprite_animations_def.dart';
import 'package:dawnforge/game/systems/input_actions/input_def.dart';
import 'package:dawnforge/game/systems/ui/emote_manager.dart';
import 'package:dawnforge/game/features/game_world/decorations/chest/chest_decoration_def.dart';
import 'package:dawnforge/game/features/game_world/decorations/chest/chest_decoration_controller.dart';
import 'package:dawnforge/game/features/game_world/decorations/chest/chest_decoration_model.dart';
import 'package:dawnforge/game/features/game_world/decorations/life_potion/life_potion_decoration.dart';
import 'package:dawnforge/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_view.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';

class ChestDecorationView extends DDInputReceiverDecorationView {
  late final ChestDecorationController _controller;
  late final TextPaint _textConfig;

  ChestDecorationView({
    required super.position,
    required ChestDecorationModel model,
  }) : super.withAnimation(
         animation: ChestDecorationConfig.loadAnimation(),
         size: ChestDecorationConfig.componentSize,
       ) {
    _initializeController(model);
  }

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
  void onJoystickAction(JoystickActionEvent event) {
    if (_controller.model.canInteract &&
        event.event == ActionEvent.DOWN &&
        InputDef.isInteractionAction(event.id)) {
      _controller.openChest();
    }
  }

  @override
  void onRemove() {
    _controller.dispose();
    super.onRemove();
  }

  void _onDisplayExclamationEmote() {
    add(EmoteManager.displayEmoteAboveDecoration(size));
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
            CharacterFxSpriteAnimationsDef.loadAnimationExplosionSmokeRight(),
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
        final playerView = comp as DDBasePlayerView;
        // Register to receive player controller events when player is nearby
        final PlayerController? playerInput =
            gameRef.playerControllers?.firstOrNull;
        if (playerInput != null) {
          registerToPlayerController(playerInput);
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
}
