import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_input_actions_config.dart';

class KnightPlayerController {
  final KnightPlayerModel model;
  late KnightPlayerView _view;

  async.Timer? _staminaRegenerationTimer;
  bool _isObservingEnemy = false;
  bool isUsingTool = false;

  KnightPlayerController({required this.model});

  void attachView(KnightPlayerView view) {
    _view = view;
  }

  void onUpdate(double dt) {
    _handleStaminaRegeneration();
    _handleEnemyVision();
  }

  void onInputAction(JoystickActionEvent event) {
    if ((event.id == GameplayInputActionsConfig.joystickMeleeAttack ||
            event.id == GameplayInputActionsConfig.keyboardMeleeAttack) &&
        event.event == ActionEvent.DOWN) {
      _executeMeleeAttack();
    }
    if ((event.id == GameplayInputActionsConfig.joystickFireballAttack ||
            event.id == GameplayInputActionsConfig.keyboardFireballAttack) &&
        event.event == ActionEvent.DOWN) {
      _executeFireballAttack();
    }
  }

  void _executeMeleeAttack() {
    if (!model.canDoMeleeAttack()) return;
    model.executeMeleeAttackStaminaCost();
    _view.playMeleeAttackAnimation(model.attackDamage);
  }

  void _executeFireballAttack() {
    if (!model.canDoFireballAttack()) return;
    model.executeFireballAttackStaminaCost();
    _view.playFireballAttackAnimation(KnightPlayerConfig.kSmallAttackDamage);
  }

  void useTool() {
    if (isUsingTool || !model.canUseTool()) return;
    isUsingTool = true;
    model.useTool();
    _view.playToolAnimation();

    async.Timer(Duration(milliseconds: 500), () {
      isUsingTool = false;
    });
  }

  void switchTool(FarmTool newTool) {
    model.switchTool(newTool);
  }

  void restoreEnergy() {
    model.restoreEnergy();
  }

  void _handleStaminaRegeneration() {
    if (_staminaRegenerationTimer == null) {
      _staminaRegenerationTimer = async.Timer(
        KnightPlayerConfig.kStaminaRegenDebounce,
        () {
          _staminaRegenerationTimer = null;
        },
      );
    } else {
      return;
    }
    model.regenerateStamina();
  }

  void _handleEnemyVision() {
    _view.seeEnemy(
      radiusVision: KnightPlayerConfig.kVisionRadius,
      notObserved: () {
        _isObservingEnemy = false;
      },
      observed: (enemies) {
        if (_isObservingEnemy) return;
        _isObservingEnemy = true;
        _view.showExclamationEmote();
      },
    );
  }
}
