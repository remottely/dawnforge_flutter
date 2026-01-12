// lib/gameplay/characters/player/demo/demo_player.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/shared/framework/character/character.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/shared/framework/character/behavior/movement_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/combat_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/farming_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/enemy_detection_behavior.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';

class DemoPlayer extends Character {
  DemoPlayer({
    required String id,
    required CharacterData data,
    required Vector2 position,
  }) : super(
    id: id,
    data: data,
    config: DemoPlayerDef.config,
    position: position,
  ) {
    _setupBehaviors();
  }
  
  void _setupBehaviors() {
    // Movement
    addBehavior(MovementBehavior(
      MovementConfig(
        runSpeedMultiplier: 1.4,
        walkSpeed: DemoPlayerDef.config.baseSpeed,
      ),
    ));
    
    // Combat
    addBehavior(CombatBehavior(
      DemoPlayerDef.combatConfig, // Você criará isso no próximo passo
    ));
    
    // Farming
    addBehavior(FarmingBehavior(
      DemoPlayerDef.farmingConfig, // Você criará isso no próximo passo
    ));
    
    // Enemy Detection
    addBehavior(EnemyDetectionBehavior(
      EnemyDetectionConfig(
        longVisionRadius: DemoPlayerDef.config.longVisionRadius,
      ),
    ));
  }
  
  // Factory para criar do save
  factory DemoPlayer.fromSave(Map<String, dynamic> saveData) {
    final data = CharacterData.fromJson(saveData);
    
    return DemoPlayer(
      id: 'player_demo',
      data: data,
      position: data.position,
    );
  }
  
  // Factory para criar novo
  factory DemoPlayer.newGame(Vector2 spawnPosition) {
    final data = CharacterData.defaultPlayer(
      maxStamina: DemoPlayerDef.config.maxStamina,
      maxEnergy: DemoPlayerDef.config.maxEnergy,
      maxLife: DemoPlayerDef.config.maxLife,
      position: spawnPosition,
    );
    
    return DemoPlayer(
      id: 'player_demo',
      data: data,
      position: spawnPosition,
    );
  }
}