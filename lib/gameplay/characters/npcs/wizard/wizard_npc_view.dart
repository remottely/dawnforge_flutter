import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_input_actions_config.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_audio_manager.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';

class WizardNpcView extends SimpleNpc {
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
    if (gameRef.player != null) {
      seeComponent(
        gameRef.player!,
        observed: _controller.onPlayerDetected,
        radiusVision: WizardNpcConfig.kVisionRadius,
      );
    }
  }

  void idlePlayer() {
    gameRef.player?.idle();
  }

  void showConversation() {
    GameplayAudioManager.instance.playInteraction();
    GameplayUIManager.showConversation(
      gameRef.context,
      WizardNpcConfig.createConversationSequence(),
      onChangeTalk: _controller.onConversationChanged,
      onFinish: _controller.onConversationFinished,
      logicalKeyboardKeysToNext: [
        GameplayInputActionsConfig.kKeyboardMeleeAttack,
      ],
    );
  }
}
