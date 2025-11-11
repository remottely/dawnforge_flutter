import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:flutter/services.dart';

class WizardNpcView extends SimpleNpc with KeyboardEventListener {
  bool _playerIsNearby = false;

  final WizardNpcController _controller = WizardNpcController(
    model: WizardNpcModel(),
  );

  WizardNpcView({required super.position})
    : super(
        animation: WizardNpcConfig.animation,
        size: WizardNpcConfig.componentSize,
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
    if (gameRef.player is SunnyPlayerView) {
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
        event.logicalKey == KeyboardSetup.kInteractionKey) {
      _controller.onPlayerDetected(gameRef.player!, interactionRequested: true);

      return true;
    }

    return false;
  }

  void showConversation(Player player) {
    _controller.model.hasBeenFirstInteraction = true;
    AudioManager.instance.playConversationInteractionSfx();
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: WizardNpcConfig.createConversationSequence(),
      onChangeTalk: _controller.onConversationChanged,
      onFinish: _controller.onConversationFinished,
      logicalKeyboardKeysToNext: [KeyboardSetup.kPrimaryAttackKey],
    );
  }
}
