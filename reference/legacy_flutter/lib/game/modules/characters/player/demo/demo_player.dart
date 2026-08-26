// lib/gameplay/characters/player/demo/demo_player.dart (CORRIGIDO)
import 'dart:ui';
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/modules/characters/player/demo/demo_player_def.dart';
import 'package:dawnforge/shared/framework/character/character.dart';
import 'package:dawnforge/shared/framework/character/character_data.dart';
import 'package:dawnforge/shared/framework/character/behavior/movement_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/combat_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/farming_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/consumable_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/defense_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/mining_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/enemy_detection_behavior.dart';
import 'package:dawnforge/shared/framework/character/behavior/equipment_sync_behavior.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:flutter/foundation.dart';

class DemoPlayer extends Character {
  double _torchStaminaRegenAccumulator = 0.0;
  static const double _kTorchStaminaRegenInterval = 2.0;
  static const double _kTorchStaminaRegenAmount = 5.0;

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
         // ✅ PASSA a animação NO CONSTRUTOR (não null!)
         animation: DemoPlayerDef.walkAnimation,
       ) {
    GameLogger.info('[DemoPlayer] 🎮 Construtor - position: $position');
    _setupBehaviors();
  }

  @override
  Future<void> onLoad() async {
    GameLogger.info('[DemoPlayer] 📦 onLoad START');

    // ✅ Apenas chama super.onLoad (animação já foi passada no construtor)
    await super.onLoad();

    GameLogger.info('[DemoPlayer] 📦 onLoad END');
    GameLogger.info('[DemoPlayer] 📦 animation: $animation');
  }

  @override
  void onMount() {
    GameLogger.info('[DemoPlayer] 🔗 onMount START');
    super.onMount();
    GameLogger.info('[DemoPlayer] 🔗 onMount END');
  }

  void _setupBehaviors() {
    GameLogger.info('[DemoPlayer] ⚙️ _setupBehaviors START');

    addBehavior(
      MovementBehavior(
        MovementConfig(
          runSpeedMultiplier: DemoPlayerDef.kRunSpeedMultiplier,
          walkSpeed: DemoPlayerDef.config.baseSpeed,
          walkAnimation: DemoPlayerDef.walkAnimation,
          runAnimation: DemoPlayerDef.runAnimation,
        ),
      ),
    );

    addBehavior(CombatBehavior(DemoPlayerDef.combatConfig));
    addBehavior(FarmingBehavior(DemoPlayerDef.farmingConfig));
    addBehavior(MiningBehavior(DemoPlayerDef.miningConfig));

    addBehavior(
      ConsumableBehavior(
        const ConsumableConfig(
          healthPotionRestoreAmount: 50.0,
          staminaPotionRestoreAmount: 50.0,
        ),
      ),
    );

    addBehavior(
      DefenseBehavior(
        const DefenseConfig(
          blockDamageReduction: 0.5,
          blockStaminaCostPerHit: 5.0,
          parryWindowMs: 200.0,
          parryDamageReflection: 0.3,
        ),
      ),
    );

    addBehavior(
      EnemyDetectionBehavior(
        EnemyDetectionConfig(
          longVisionRadius: DemoPlayerDef.config.longVisionRadius,
        ),
      ),
    );

    addBehavior(EquipmentSyncBehavior());

    GameLogger.info('[DemoPlayer] ⚙️ _setupBehaviors END');
  }

  @override
  void update(double dt) {
    _lastDeltaTime = dt;
    super.update(dt);
  }

  void processStaminaRegeneration() {
    if (data.stamina >= data.maxStamina) {
      _torchStaminaRegenAccumulator = 0.0;
      return;
    }

    final dt = _lastDeltaTime;
    _torchStaminaRegenAccumulator += dt;

    if (_torchStaminaRegenAccumulator >= _kTorchStaminaRegenInterval) {
      data.restoreStamina(_kTorchStaminaRegenAmount);
      _torchStaminaRegenAccumulator -= _kTorchStaminaRegenInterval;

      GameLogger.info(
        '[DemoPlayer] 🔥 Torch regen: +${_kTorchStaminaRegenAmount} stamina '
        '(${data.stamina.toStringAsFixed(1)}/${data.maxStamina})',
      );
    }
  }

  void resetTorchRegeneration() {
    if (_torchStaminaRegenAccumulator > 0) {
      GameLogger.info('[DemoPlayer] 🔥 Torch regen reset (left range)');
      _torchStaminaRegenAccumulator = 0.0;
    }
  }

  bool startShieldDefense() {
    final defenseBehavior = getBehavior<DefenseBehavior>();
    if (defenseBehavior == null) return false;

    return data.equippedItemId == HandItemId.shield;
  }

  void stopShieldDefense() {
    // O DefenseBehavior já lida com isso via input
  }

  factory DemoPlayer.fromSave(Map<String, dynamic> saveData) {
    final data = CharacterData.fromJson(saveData);

    return DemoPlayer(id: 'player_demo', data: data, position: data.position);
  }

  factory DemoPlayer.newGame(Vector2 spawnPosition) {
    final data = CharacterData.defaultPlayer(
      maxStamina: DemoPlayerDef.config.maxStamina,
      maxEnergy: DemoPlayerDef.config.maxEnergy,
      maxLife: DemoPlayerDef.config.maxLife,
      position: spawnPosition,
    );

    return DemoPlayer(id: 'player_demo', data: data, position: spawnPosition);
  }
}
