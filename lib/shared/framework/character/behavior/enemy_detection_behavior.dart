// lib/shared/framework/character/behavior/enemy_detection_behavior.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';

class EnemyDetectionConfig {
  final double longVisionRadius;
  final Duration detectionCooldown;
  
  const EnemyDetectionConfig({
    required this.longVisionRadius,
    this.detectionCooldown = const Duration(milliseconds: 500),
  });
}

class EnemyDetectionBehavior extends CharacterBehavior {
  final EnemyDetectionConfig config;
  
  int _lastDetectionTime = 0;
  
  EnemyDetectionBehavior(this.config);
  
  @override
  void update(double dt) {
    super.update(dt);
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastDetectionTime < config.detectionCooldown.inMilliseconds) {
      return;
    }
    
    _processEnemyDetection();
    _lastDetectionTime = now;
  }
  
  void _processEnemyDetection() {
    character.detectEnemies(
      radius: config.longVisionRadius,
      notObserved: () {
        character.data.isObservingEnemy = false;
      },
      observed: (List<Enemy> enemies) {
        if (!character.data.isObservingEnemy) {
          character.data.isObservingEnemy = true;
          character.displayExclamationEmote();
        }
      },
    );
  }
}
