import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/input_def.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_defense_player_view.dart';

class ShieldDefenseInputHandler extends GameComponent
    with PlayerControllerListener {
  final PlayerController? playerController;

  bool _isDefending = false;
  double _defenseTime = 0.0;
  double _staminaAccumulator = 0.0;

  static const double kStaminaPerSecond = 10.0;

  ShieldDefenseInputHandler({this.playerController});

  bool get isDefending => _isDefending;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (playerController != null) {
      playerController!.addObserver(this);
    }
  }

  DDDefensePlayerView? _getCurrentPlayer() {
    final players = gameRef.query<DDDefensePlayerView>();
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

      if (player.controller.model.stamina <= 0) {
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

  // @override
  // bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  //   final player = _getCurrentPlayer();
  //   if (player == null) return false;

  //   if (InputDef.isSecondaryAction(event.logicalKey)) {
  //     if (event is KeyDownEvent) {
  //       return _handleDefenseStart(player);
  //     } else if (event is KeyUpEvent) {
  //       return _handleDefenseEnd(player);
  //     }
  //   }

  //   return false;
  // }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    final player = _getCurrentPlayer();
    if (player == null) return;

    if (InputDef.isSecondaryAction(event.id)) {
      if (event.event == ActionEvent.DOWN) {
        _handleDefenseStart(player);
      } else if (event.event == ActionEvent.UP) {
        _handleDefenseEnd(player);
      }
    }
  }

  bool _handleDefenseStart(DDDefensePlayerView player) {
    if (!_isDefending) {
      if (player.controller.model.stamina <= 0) {
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

  bool _handleDefenseEnd(DDDefensePlayerView player) {
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

  @override
  void onRemove() {
    if (playerController != null) {
      playerController!.removeObserver(this);
    }
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
