import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:flutter/services.dart';

/// Componente que gerencia a defesa com escudo via input de teclado
///
/// Detecta quando Z está pressionado e consome stamina enquanto defende.
/// Consumo: 10 stamina por segundo.
class ShieldDefenseInputHandler extends GameComponent
    with KeyboardEventListener {
  bool _isDefending = false;
  double _defenseTime = 0.0;
  double _staminaAccumulator = 0.0; // Acumula frações de stamina entre frames

  /// Stamina consumida por segundo de defesa
  static const double kStaminaPerSecond = 10.0;

  bool get isDefending => _isDefending;

  /// Busca o player atual a cada chamada para garantir compatibilidade com troca de mapas
  SunnyPlayerView? _getCurrentPlayer() {
    final players = gameRef.query<SunnyPlayerView>();
    return players.isNotEmpty ? players.first : null;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isDefending) {
      final player = _getCurrentPlayer();
      if (player == null) return;

      // Acumular tempo de defesa
      _defenseTime += dt;

      // Consumir stamina a cada segundo (acumular frações entre frames)
      _staminaAccumulator += kStaminaPerSecond * dt;

      // Quando acumular >= 1 ponto de stamina, consumir
      if (_staminaAccumulator >= 1.0) {
        final intStaminaToConsume = _staminaAccumulator.floor();
        if (intStaminaToConsume > 0) {
          player.controller.model.consumeStamina(intStaminaToConsume);
          _staminaAccumulator -= intStaminaToConsume;
        }
      }

      // Verificar se stamina acabou
      if (player.controller.model.currentStamina <= 0) {
        // Sem stamina, parar defesa automaticamente
        developer.log(
          '[ShieldDefenseInput] ✗ Stamina esgotada, parando defesa',
        );
        player.stopShieldDefense();
        _isDefending = false;
        _defenseTime = 0.0;
        _staminaAccumulator = 0.0;
        // Retomar regeneração de stamina
        player.controller.endStaminaConsumingAction();
      }
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final player = _getCurrentPlayer();
    if (player == null) return false;

    // Detectar Z pressionado (KeyDown)
    if (event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kSecondaryActionKey) {
      if (!_isDefending) {
        // Verificar se tem stamina antes de ativar
        if (player.controller.model.currentStamina <= 0) {
          developer.log('[ShieldDefenseInput] ✗ Sem stamina para defender');
          return false;
        }

        final success = player.startShieldDefense();
        if (success) {
          _isDefending = true;
          _defenseTime = 0.0;
          _staminaAccumulator = 0.0;
          // Pausar regeneração de stamina durante defesa
          player.controller.beginStaminaConsumingAction();
          developer.log(
            '[ShieldDefenseInput] ✓ Defesa iniciada - regeneração pausada',
          );
          return true; // Consumir o evento
        }
      }
      return false;
    }

    // Detectar Z solto (KeyUp)
    if (event is KeyUpEvent &&
        event.logicalKey == KeyboardSetup.kSecondaryActionKey) {
      if (_isDefending) {
        player.stopShieldDefense();
        _isDefending = false;
        _defenseTime = 0.0;
        _staminaAccumulator = 0.0;
        // Retomar regeneração de stamina
        player.controller.endStaminaConsumingAction();
        developer.log(
          '[ShieldDefenseInput] ✓ Defesa finalizada (tempo: ${_defenseTime.toStringAsFixed(2)}s) - regeneração retomada',
        );
        return true; // Consumir o evento
      }
      return false;
    }

    return false; // Permitir processamento normal de todos os inputs
  }

  @override
  void onRemove() {
    // Garantir que defesa seja desativada ao remover componente
    if (_isDefending) {
      final player = _getCurrentPlayer();
      if (player != null) {
        player.stopShieldDefense();
        player.controller.endStaminaConsumingAction();
      }
      _isDefending = false;
    }
    super.onRemove();
  }
}
