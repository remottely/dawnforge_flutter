import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';

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

  DemoPlayer? _getCurrentPlayer() {
    final players = gameRef.query<DemoPlayer>();
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
          player.data.consumeStamina(intStaminaToConsume); // error: The method 'consumeStamina' isn't defined for the type 'CharacterData'.
// Try correcting the name to the name of an existing method, or defining a method named 'consumeStamina'.
          _staminaAccumulator -= intStaminaToConsume;
        }
      }

      if (player.data.stamina <= 0) {
        GameLogger.warning(
          '[ShieldDefenseInput] ✗ Stamina esgotada, parando defesa',
        );
        player.stopShieldDefense(); // error: The method 'stopShieldDefense' isn't defined for the type 'DemoPlayer'.
// Try correcting the name to the name of an existing method, or defining a method named 'stopShieldDefense'.
        _isDefending = false;
        _defenseTime = 0.0;
        _staminaAccumulator = 0.0;

        player.endStaminaConsumingAction();
      }
    }
  }

  // @override
  // bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  //   final player = _getCurrentPlayer();
  //   if (player == null) return false;

  //   if (InputDef.isInteractionAction(event.logicalKey)) {
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

    if (InputDef.isInteractionAction(event.id)) {
      if (event.event == ActionEvent.DOWN) {
        _handleDefenseStart(player);
      } else if (event.event == ActionEvent.UP) {
        _handleDefenseEnd(player);
      }
    }
  }

  bool _handleDefenseStart(DemoPlayer player) {
    if (!_isDefending) {
      if (player.data.stamina <= 0) {
        GameLogger.warning('[ShieldDefenseInput] ✗ Sem stamina para defender');
        return false;
      }

      final success = player.startShieldDefense(); // error: The method 'startShieldDefense' isn't defined for the type 'DemoPlayer'.
// Try correcting the name to the name of an existing method, or defining a method named 'startShieldDefense'.
      if (success) {
        _isDefending = true;
        _defenseTime = 0.0;
        _staminaAccumulator = 0.0;

        player.beginStaminaConsumingAction();
        GameLogger.info(
          '[ShieldDefenseInput] ✓ Defesa iniciada - regeneração pausada',
        );
        return true;
      }
    }
    return false;
  }

  bool _handleDefenseEnd(DemoPlayer player) {
    if (_isDefending) {
      player.stopShieldDefense(); // error: The method 'stopShieldDefense' isn't defined for the type 'DemoPlayer'.
// Try correcting the name to the name of an existing method, or defining a method named 'stopShieldDefense'.
      _isDefending = false;
      _defenseTime = 0.0;
      _staminaAccumulator = 0.0;

      player.endStaminaConsumingAction();
      GameLogger.info(
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
        player.endStaminaConsumingAction();
      }
      _isDefending = false;
    }
    super.onRemove();
  }
}
