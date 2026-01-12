// lib/gameplay/characters/player/demo/demo_player.dart (CORREÇÃO FINAL)
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/logger/game_logger.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';
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
import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
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
         animation: null,
       ) {
    debugPrint('[DemoPlayer] 🎮 Construtor chamado - position: $position');
    _setupBehaviors();
  }

  @override
  Future<void> onLoad() async {
    debugPrint('[DemoPlayer] 📦 onLoad START');

    // ✅ CORREÇÃO: Aguarda super.onLoad PRIMEIRO
    await super.onLoad();

    // ✅ CRÍTICO: Aguarda replaceAnimation carregar as animações
    debugPrint('[DemoPlayer] 🎨 Carregando walkAnimation...');
    await replaceAnimation(DemoPlayerDef.walkAnimation);
    debugPrint('[DemoPlayer] ✅ walkAnimation carregada!');

    debugPrint('[DemoPlayer] 📦 onLoad END');
    debugPrint('[DemoPlayer] 📦 animation: $animation');
    debugPrint('[DemoPlayer] 📦 isMounted: $isMounted');
  }

  @override
  void onMount() {
    debugPrint('[DemoPlayer] 🔗 onMount START');
    debugPrint('[DemoPlayer] 🔗 isMounted: $isMounted');
    debugPrint('[DemoPlayer] 🔗 animation: $animation');

    super.onMount();

    debugPrint('[DemoPlayer] 🔗 onMount END');
  }

  void _setupBehaviors() {
    debugPrint('[DemoPlayer] ⚙️ _setupBehaviors START');

    addBehavior(
      MovementBehavior(
        MovementConfig(
          runSpeedMultiplier: DemoPlayerDef.runSpeedMultiplier,
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

    debugPrint('[DemoPlayer] ⚙️ _setupBehaviors END');
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

  // No DemoPlayer
  @override
  void render(Canvas canvas) {
    debugPrint(
      '[DemoPlayer] 🎨 render() - position: $position, visible: ${isVisible}',
    );
    super.render(canvas);
  }

  @override
  void renderDebugMode(Canvas canvas) {
    // Desenha um círculo vermelho no player (debug)
    canvas.drawCircle(
      Offset.zero,
      32,
      Paint()..color = const Color(0xFFFF0000),
    );
    super.renderDebugMode(canvas);
  }
}
