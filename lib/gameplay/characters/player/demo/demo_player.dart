// lib/gameplay/characters/player/demo/demo_player.dart
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/shared/framework/character/character.dart';
import 'package:dawnforge/shared/framework/character/character_config.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/shared/framework/character/behavior/movement_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/combat_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/farming_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/consumable_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/defense_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/mining_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/enemy_detection_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/equipment_sync_behavior.dart';

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
    // Movement (com Run)
    addBehavior(MovementBehavior(
      MovementConfig(
        runSpeedMultiplier: DemoPlayerDef.runSpeedMultiplier,
        walkSpeed: DemoPlayerDef.config.baseSpeed,
        walkAnimation: DemoPlayerDef.walkAnimation,
        runAnimation: DemoPlayerDef.runAnimation,
      ),
    ));
    
    // Combat
    addBehavior(CombatBehavior(DemoPlayerDef.combatConfig));
    
    // Farming
    addBehavior(FarmingBehavior(DemoPlayerDef.farmingConfig));
    
    // Mining
    addBehavior(MiningBehavior(DemoPlayerDef.miningConfig));
    
    // Consumable
    addBehavior(ConsumableBehavior(
      const ConsumableConfig(
        healthPotionRestoreAmount: 50.0,
        staminaPotionRestoreAmount: 50.0,
      ),
    ));
    
    // Defense (Shield)
    addBehavior(DefenseBehavior(
      const DefenseConfig(
        blockDamageReduction: 0.5,
        blockStaminaCostPerHit: 5.0,
        parryWindowMs: 200.0,
        parryDamageReflection: 0.3,
      ),
    ));
    
    // Enemy Detection
    addBehavior(EnemyDetectionBehavior(
      EnemyDetectionConfig(
        longVisionRadius: DemoPlayerDef.config.longVisionRadius,
      ),
    ));
    
    // Equipment Sync (mantém CharacterData.equippedItemId atualizado)
    addBehavior(EquipmentSyncBehavior());
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
  
  // Factory para criar novo jogo
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
