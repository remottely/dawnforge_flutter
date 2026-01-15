// lib/shared/framework/character/behavior/movement_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';

class MovementConfig {
  final double runSpeedMultiplier;
  final double walkSpeed;
  final SimpleDirectionAnimation walkAnimation;
  final SimpleDirectionAnimation runAnimation;

  const MovementConfig({
    this.runSpeedMultiplier = 1.4,
    required this.walkSpeed,
    required this.walkAnimation,
    required this.runAnimation,
  });
}

class MovementBehavior extends CharacterBehavior {
  final MovementConfig config;

  bool _isRunning = false;

  MovementBehavior(this.config);

  bool get isRunning => _isRunning;

  @override
  void onAttach() {
    super.onAttach();

    // Define animação inicial de walk
    character.replaceAnimation(config.walkAnimation);
  }

  @override
  bool onInput(JoystickActionEvent event) {
    // Run toggle
    if (InputDef.isRunAction(event.id)) {
      if (event.event == ActionEvent.DOWN) {
        _startRunning();
      } else if (event.event == ActionEvent.UP) {
        _stopRunning();
      }
      return true;
    }

    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Atualiza velocidade no data
    character.data.velocity = character.velocity;

    // Atualiza direção no data
    // if (character.lastDirection != Direction.none) {
    character.data.direction = _directionToString(character.lastDirection);
    // }
  }

  void _startRunning() {
    if (_isRunning || character.isActionLocked) return;

    _isRunning = true;
    character.speed = config.walkSpeed * config.runSpeedMultiplier;

    character.replaceAnimation(config.runAnimation, doIdle: character.isIdle);

    GameLogger.info(
      '[MovementBehavior] ✓ Running started (speed: ${character.speed})',
    );
  }

  void _stopRunning() {
    if (!_isRunning) return;

    _isRunning = false;
    character.speed = config.walkSpeed;

    character.replaceAnimation(config.walkAnimation, doIdle: character.isIdle);

    GameLogger.info(
      '[MovementBehavior] ✓ Running stopped (speed: ${character.speed})',
    );
  }

  String _directionToString(Direction dir) {
    switch (dir) {
      case Direction.up:
        return 'up';
      case Direction.down:
        return 'down';
      case Direction.left:
        return 'left';
      case Direction.right:
        return 'right';
      default:
        return 'down';
    }
  }
}
