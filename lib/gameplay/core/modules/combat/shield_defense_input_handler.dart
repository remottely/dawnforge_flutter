import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:flutter/services.dart';

class ShieldDefenseInputHandler extends GameComponent
    with KeyboardEventListener {
  bool _isDefending = false;
  double _defenseTime = 0.0;
  double _staminaAccumulator = 0.0;

  static const double kStaminaPerSecond = 10.0;

  bool get isDefending => _isDefending;

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

      _defenseTime += dt;

      _staminaAccumulator += kStaminaPerSecond * dt;

      if (_staminaAccumulator >= 1.0) {
        final intStaminaToConsume = _staminaAccumulator.floor();
        if (intStaminaToConsume > 0) {
          player.controller.model.consumeStamina(intStaminaToConsume);
          _staminaAccumulator -= intStaminaToConsume;
        }
      }

      if (player.controller.model.currentStamina <= 0) {
        developer.log(
          '[ShieldDefenseInput] ✗ Stamina esgotada, parando defesa',
        );
        player.stopShieldDefense();
        _isDefending = false;
        _defenseTime = 0.0;
        _staminaAccumulator = 0.0;

        player.controller.endStaminaConsumingAction();
      }
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final player = _getCurrentPlayer();
    if (player == null) return false;

    if (event is KeyDownEvent &&
        event.logicalKey == KeyboardSetup.kSecondaryActionKey) {
      if (!_isDefending) {
        if (player.controller.model.currentStamina <= 0) {
          developer.log('[ShieldDefenseInput] ✗ Sem stamina para defender');
          return false;
        }

        final success = player.startShieldDefense();
        if (success) {
          _isDefending = true;
          _defenseTime = 0.0;
          _staminaAccumulator = 0.0;

          player.controller.beginStaminaConsumingAction();
          developer.log(
            '[ShieldDefenseInput] ✓ Defesa iniciada - regeneração pausada',
          );
          return true;
        }
      }
      return false;
    }

    if (event is KeyUpEvent &&
        event.logicalKey == KeyboardSetup.kSecondaryActionKey) {
      if (_isDefending) {
        player.stopShieldDefense();
        _isDefending = false;
        _defenseTime = 0.0;
        _staminaAccumulator = 0.0;

        player.controller.endStaminaConsumingAction();
        developer.log(
          '[ShieldDefenseInput] ✓ Defesa finalizada (tempo: ${_defenseTime.toStringAsFixed(2)}s) - regeneração retomada',
        );
        return true;
      }
      return false;
    }

    return false;
  }

  @override
  void onRemove() {
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
