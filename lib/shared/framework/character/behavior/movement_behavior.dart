// lib/shared/framework/character/behavior/movement_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';

class MovementConfig {
  final double runSpeedMultiplier;
  final double walkSpeed;

  const MovementConfig({
    this.runSpeedMultiplier = 1.4,
    required this.walkSpeed,
  });
}

class MovementBehavior extends CharacterBehavior {
  final MovementConfig config;

  bool _isRunning = false;

  MovementBehavior(this.config);

  bool get isRunning => _isRunning;

  @override
  void update(double dt) {
    super.update(dt);

    // Atualiza velocidade no data
    character.data.velocity = character.velocity; //  ?? Vector2.zero();

    // Atualiza direção no data
    // if (character.lastDirection != Direction.none) {
    character.data.direction = _directionToString(character.lastDirection);
    // }
  }

  void toggleRun(bool shouldRun) {
    if (_isRunning == shouldRun) return;

    _isRunning = shouldRun;

    final newSpeed = shouldRun
        ? config.walkSpeed * config.runSpeedMultiplier
        : config.walkSpeed;

    character.speed = newSpeed;

    GameLogger.info(
      '[MovementBehavior] Run toggled: $_isRunning | Speed: $newSpeed',
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
