// lib/gameplay/characters/player/demo/demo_player.dart (CORRIGIDO)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';
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
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';

class DemoPlayer extends Character {
  // ✅ Sistema de regeneração de stamina por tocha
  double _torchStaminaRegenAccumulator = 0.0;
  static const double _kTorchStaminaRegenInterval = 2.0; // segundos
  static const double _kTorchStaminaRegenAmount = 5.0; // stamina por intervalo
  
  // ✅ Armazena dt do último update
  double _lastDeltaTime = 0.0;
  
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
    addBehavior(MovementBehavior(
      MovementConfig(
        runSpeedMultiplier: DemoPlayerDef.runSpeedMultiplier,
        walkSpeed: DemoPlayerDef.config.baseSpeed,
        walkAnimation: DemoPlayerDef.walkAnimation,
        runAnimation: DemoPlayerDef.runAnimation,
      ),
    ));
    
    addBehavior(CombatBehavior(DemoPlayerDef.combatConfig));
    addBehavior(FarmingBehavior(DemoPlayerDef.farmingConfig));
    addBehavior(MiningBehavior(DemoPlayerDef.miningConfig));
    
    addBehavior(ConsumableBehavior(
      const ConsumableConfig(
        healthPotionRestoreAmount: 50.0,
        staminaPotionRestoreAmount: 50.0,
      ),
    ));
    
    addBehavior(DefenseBehavior(
      const DefenseConfig(
        blockDamageReduction: 0.5,
        blockStaminaCostPerHit: 5.0,
        parryWindowMs: 200.0,
        parryDamageReflection: 0.3,
      ),
    ));
    
    addBehavior(EnemyDetectionBehavior(
      EnemyDetectionConfig(
        longVisionRadius: DemoPlayerDef.config.longVisionRadius,
      ),
    ));
    
    addBehavior(EquipmentSyncBehavior());
  }
  
  @override
  void update(double dt) {
    // ✅ Armazena dt para uso em processStaminaRegeneration
    _lastDeltaTime = dt;
    
    super.update(dt);
  }
  
  /// ✅ CORRIGIDO: Regeneração de stamina por tocha
  /// Este método é chamado pela TorchDecoration quando o player está no range
  /// e a tocha está acesa. Regenera stamina em intervalos.
  void processStaminaRegeneration() {
    // Não regenera se já está no máximo
    if (data.stamina >= data.maxStamina) {
      _torchStaminaRegenAccumulator = 0.0;
      return;
    }
    
    // ✅ CORREÇÃO: Usa o dt armazenado do último update
    final dt = _lastDeltaTime;
    
    _torchStaminaRegenAccumulator += dt;
    
    // A cada X segundos, regenera stamina
    if (_torchStaminaRegenAccumulator >= _kTorchStaminaRegenInterval) {
      data.restoreStamina(_kTorchStaminaRegenAmount);
      
      _torchStaminaRegenAccumulator -= _kTorchStaminaRegenInterval;
      
      GameLogger.info(
        '[DemoPlayer] 🔥 Torch regen: +${_kTorchStaminaRegenAmount} stamina '
        '(${data.stamina.toStringAsFixed(1)}/${data.maxStamina})',
      );
    }
  }
  
  /// Reseta o acumulador de regeneração por tocha
  /// Chamado quando player sai do range da tocha
  void resetTorchRegeneration() {
    if (_torchStaminaRegenAccumulator > 0) {
      GameLogger.info('[DemoPlayer] 🔥 Torch regen reset (left range)');
      _torchStaminaRegenAccumulator = 0.0;
    }
  }
  
  // ✅ Métodos de shield (delegam para DefenseBehavior)
  bool startShieldDefense() {
    final defenseBehavior = getBehavior<DefenseBehavior>();
    if (defenseBehavior == null) return false;
    
    // Verifica se tem shield equipado
    return data.equippedItemId == HandItemId.shield;
  }
  
  void stopShieldDefense() {
    // O DefenseBehavior já lida com isso via input
  }
  
  // Factory methods
  factory DemoPlayer.fromSave(Map<String, dynamic> saveData) {
    final data = CharacterData.fromJson(saveData);
    
    return DemoPlayer(
      id: 'player_demo',
      data: data,
      position: data.position,
    );
  }
  
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
