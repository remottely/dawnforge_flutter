import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/wizard/wizard_npc_controller.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/wizard/wizard_npc_def.dart';
import 'package:dawnforge/game/features/game_world/characters/npcs/wizard/wizard_npc_model.dart';
import 'package:dawnforge/game/core/systems/audio/audio_manager.dart';
import 'package:dawnforge/game/core/systems/input_actions/input_def.dart';
import 'package:dawnforge/game/core/systems/ui/ui_state_manager.dart';

class WizardNpcView extends SimpleNpc with PlayerControllerListener {
  bool _playerIsNearby = false;
  PlayerController? _registeredController;

  final WizardNpcController _controller = WizardNpcController(
    model: WizardNpcModel(),
  );

  WizardNpcView({required super.position})
    : super(
        animation: WizardNpcDef.animationWalkDirectional,
        size: WizardNpcDef.componentSize,
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

  // TODO(Kevin): pass it through controller
  void onDetectPlayerInCloseVisionRadius() {
    if (gameRef.player is SimplePlayer) {
      seeComponent(
        gameRef.player!,
        radiusVision: WizardNpcDef.kCloseVisionRadius,
        observed: (_) {
          if (!_playerIsNearby) {
            _playerIsNearby = true;

            // Register to receive player controller events
            final playerController = gameRef.playerControllers?.firstOrNull;
            if (playerController != null &&
                _registeredController != playerController) {
              _registeredController?.removeObserver(this);
              _registeredController = playerController;
              playerController.addObserver(this);
            }

            _controller.onPlayerDetected(
              gameRef.player!,
              interactionRequested: false,
            );
          }
        },
        notObserved: () {
          _playerIsNearby = false;
          // Unregister when player leaves
          if (_registeredController != null) {
            _registeredController!.removeObserver(this);
            _registeredController = null;
          }
        },
      );
    }
  }

  // @override
  // bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  //   if (_playerIsNearby &&
  //       event is KeyDownEvent &&
  //       event.logicalKey == KeyboardSetup.kInteractionKey) {
  //     _controller.onPlayerDetected(gameRef.player!, interactionRequested: true);

  //     return true;
  //   }

  //   return false;
  // }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (_playerIsNearby &&
        event.event == ActionEvent.DOWN &&
        InputDef.isInteractionAction(event.id)) {
      _controller.onPlayerDetected(gameRef.player!, interactionRequested: true);
    }
  }

  void showConversation(Player player) {
    _controller.model.hasBeenFirstInteraction = true;
    AudioManager.instance.playConversationInteractionSfx();
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: WizardNpcDef.createConversationSequence(),
      onChangeConversation: _controller.onConversationChanged,
      onFinishConversation: _controller.onConversationFinished,
    );
  }

  @override
  void onRemove() {
    if (_registeredController != null) {
      _registeredController!.removeObserver(this);
      _registeredController = null;
    }
    super.onRemove();
  }
}
