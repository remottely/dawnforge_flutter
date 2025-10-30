import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:flutter/services.dart';

class WizardNpcView extends SimpleNpc with KeyboardEventListener {
  bool _playerIsNearby = false;

  final WizardNpcController _controller = WizardNpcController(
    model: WizardNpcModel(),
  );

  WizardNpcView(Vector2 position)
    : super(
        animation: WizardNpcConfig.fDirectionalSpriteAnimation,
        position: position,
        size: WizardNpcConfig.fComponentSize,
      );

  @override
  Future<void> onLoad() {
    _controller.attachView(this);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _controller.onUpdate(dt);
    super.update(dt);
  }

  void checkPlayerProximity() {
    if (gameRef.player is KnightPlayerView) {
      seeComponent(
        gameRef.player!,
        observed: (_) {
          if (!_playerIsNearby) {
            _playerIsNearby = true;

            _controller.onPlayerDetected(
              gameRef.player!,
              interactionRequested: false,
            );
          }
        },
        notObserved: () {
          _playerIsNearby = false;
        },
        radiusVision: WizardNpcConfig.kVisionRadius,
      );
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_playerIsNearby &&
        event is KeyDownEvent &&
        event.logicalKey == GameplayInputActionsConfig.kKeyboardMeleeAttack) {
      _controller.onPlayerDetected(gameRef.player!, interactionRequested: true);

      return true;
    }

    return false;
  }

  void showConversation(Player player) {
    _controller.model.hasBeenFirstInteraction = true;
    GameplayAudioManager.instance.playConversationInteraction();
    GameplayUIManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: WizardNpcConfig.createConversationSequence(),
      onChangeTalk: _controller.onConversationChanged,
      onFinish: _controller.onConversationFinished,
      logicalKeyboardKeysToNext: [
        GameplayInputActionsConfig.kKeyboardMeleeAttack,
      ],
    );
  }
}
