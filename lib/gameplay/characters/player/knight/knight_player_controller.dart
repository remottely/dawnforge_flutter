import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:flutter/services.dart';

/// Controller: Orquestra lógica e comunicação entre Model e View do Knight.
class KnightPlayerController {
  final KnightPlayerModel model;
  late KnightPlayerView _view;

  //////////////////////////////////////////////////////////////////////////////
  // ESTADO INTERNO
  //////////////////////////////////////////////////////////////////////////////
  async.Timer? _staminaRegenerationTimer;
  bool _isObservingEnemy = false;
  bool isUsingTool = false;

  KnightPlayerController({required this.model});

  //////////////////////////////////////////////////////////////////////////////
  // CICLO DE VIDA
  //////////////////////////////////////////////////////////////////////////////
  /// Associa a View ao Controller
  void attachView(KnightPlayerView view) {
    _view = view;
  }

  /// Chamado pela View a cada tick do jogo
  void onUpdate(double dt) {
    _handleStaminaRegeneration();
    _handleEnemyVision();
  }

  //////////////////////////////////////////////////////////////////////////////
  // INPUT
  //////////////////////////////////////////////////////////////////////////////
  /// Processa ações do joystick/teclado
  void onJoystickAction(JoystickActionEvent event) {
    if ((event.id == 0 || event.id == LogicalKeyboardKey.space) &&
        event.event == ActionEvent.DOWN) {
      _executeMeleeAttack();
    }
    if ((event.id == 1 || event.id == LogicalKeyboardKey.keyZ) &&
        event.event == ActionEvent.DOWN) {
      _executeFireballAttack();
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  // AÇÕES
  //////////////////////////////////////////////////////////////////////////////
  /// Executa ataque melee se possível
  void _executeMeleeAttack() {
    if (!model.canDoMeleeAttack()) return;
    model.executeMeleeAttackStaminaCost();
    _view.playMeleeAttackAnimation(model.attackDamage);
  }

  /// Executa ataque fireball se possível
  void _executeFireballAttack() {
    if (!model.canDoFireballAttack()) return;
    model.executeFireballAttackStaminaCost();
    _view.playFireballAttackAnimation(KnightPlayerConfig.kSmallAttackDamage);
  }

  /// Usa ferramenta se possível
  void useTool() {
    if (isUsingTool || !model.canUseTool()) return;
    isUsingTool = true;
    model.useTool();
    _view.playToolAnimation();
    // A View deve chamar 'controller.isUsingTool = false' ao finalizar animação
    async.Timer(Duration(milliseconds: 500), () {
      isUsingTool = false;
    });
  }

  /// Troca ferramenta
  void switchTool(FarmTool newTool) {
    model.switchTool(newTool);
    // _view.playSwitchToolFeedback(); // Implementar feedback visual se necessário
  }

  /// Restaura energia ao máximo
  void restoreEnergy() {
    model.restoreEnergy();
    // _view.updateEnergyBar(model.currentEnergy); // Implementar feedback visual se necessário
  }

  //////////////////////////////////////////////////////////////////////////////
  // UPDATE DE ESTADO
  //////////////////////////////////////////////////////////////////////////////
  /// Regenera stamina gradualmente
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
    // _view.updateStaminaBar(model.currentStamina); // Implementar feedback visual se necessário
  }

  /// Detecta inimigos próximos e aciona emote
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
