import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:flutter/services.dart';

/// Gerencia a lógica de entrada, timers e a comunicação
/// entre o Model (dados) e a View (componente Bonfire).
class KnightPlayerController {
  final KnightPlayerModel model;
  late KnightPlayerView _view;

  // Estado gerenciado pelo Controller
  async.Timer? _staminaRegenerationTimer;
  bool _isObservingEnemy = false;
  bool isUsingTool = false; // Bloqueia o uso repetido de ferramentas

  KnightPlayerController({required this.model});

  void attachView(KnightPlayerView view) {
    _view = view;
  }

  /// Chamado pela View a cada tick do jogo.
  void onUpdate(double dt) {
    _handleStamina();
    _handleMovementEffects();
  }

  /// Chamado pela View quando o joystick é acionado.
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      _executeMeleeAttack();
    }

    if (event.id == LogicalKeyboardKey.space &&
        event.event == ActionEvent.DOWN) {
      _executeMeleeAttack();
    }

    if (event.id == LogicalKeyboardKey.keyZ &&
        event.event == ActionEvent.DOWN) {
      _executeFireballAttack();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      _executeFireballAttack();
    }
  }

  // --- Lógica de Ação ---

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
    // TODO: A View deve chamar 'controller.isUsingTool = false'
    // quando a animação da ferramenta terminar.
    // Por enquanto, liberamos após um curto período.
    async.Timer(Duration(milliseconds: 500), () {
      isUsingTool = false;
    });
  }

  void switchTool(FarmTool newTool) {
    model.switchTool(newTool);
    // TODO: _view?.playSwitchToolFeedback();
  }

  void restoreEnergy() {
    model.restoreEnergy();
    // TODO: _view?.updateEnergyBar(model.currentEnergy);
  }

  // --- Lógica de Update ---

  void _handleStamina() {
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
    // TODO: _view?.updateStaminaBar(model.currentStamina);
  }

  void _handleMovementEffects() {
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
