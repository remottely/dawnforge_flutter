import 'dart:developer' as developer;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/input_def.dart';
import 'package:darkness_dungeon/gameplay/core/modules/input_actions/keyboard_setup.dart';
import 'package:darkness_dungeon/gameplay/core/modules/overlay/overlay_message_def.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/consumable_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/crop_item.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
import 'package:flutter/services.dart';

abstract class DDFarmPlayerController<M extends DDFarmPlayerModel>
    extends DDCombatPlayerController<M> {
  final bool Function() onExecuteDig;
  final bool Function() onExecuteWateringCan;
  final bool Function() onExecuteSeed;
  final bool Function() onExecuteHarvest;

  DDFarmPlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required this.onExecuteDig,
    required this.onExecuteWateringCan,
    required this.onExecuteSeed,
    required this.onExecuteHarvest,
  });

  bool isDigAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == EquippedHandType.shovel;

  bool isWateringCanAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == EquippedHandType.wateringCan;

  bool isSeedAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      (player.controller.model.equipment?.isSeed ?? false);

  bool isHarvestAction({
    required DDBasePlayerView player,
    required dynamic actionId,
  }) =>
      InputDef.isPrimaryAction(actionId) &&
      player.controller.model.equipment == EquippedHandType.harvestBasket;

  bool _isConsumeVegetableAction(dynamic actionId) {
    if (InputDef.isInteractionAction(actionId)) return true;

    // Fallback apenas para garantir que X seja reconhecido mesmo se vier como instância diferente.
    if (actionId is LogicalKeyboardKey) {
      if (actionId.keyId == LogicalKeyboardKey.keyX.keyId) return true;
    }

    return false;
  }

  @override
  void handleInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    developer.log(
      '[FarmController] Verificando ação: ${event.id} | equipment: ${player.controller.model.equipment} | evento: ${event.event}',
    );

    final bool isInteraction = _isConsumeVegetableAction(event.id);
    final bool isConsumeVegetable =
        event.event == ActionEvent.DOWN && isInteraction;
    developer.log(
      '[FarmController] Check consumo: isInteraction=$isInteraction | isConsumeVegetable=$isConsumeVegetable | actionId=${event.id}',
    );

    if (isConsumeVegetable) {
      final consumed = _tryConsumeSelectedVegetable(player);
      developer.log('[FarmController] Consumo via interação: success=$consumed');
      if (consumed) return;
      // Se não consumiu, não prossiga para ações de farm; evita log de "não é ação de farm" poluir
      return;
    }

    // Só processa ações no DOWN, não no UP
    if (event.event != ActionEvent.DOWN) {
      super.handleInputAction(player: player, event: event);
      return;
    }

    if (isDigAction(player: player, actionId: event.id)) {
      developer.log('[FarmController] ✓ É dig action (shovel)');
      _handleExecuteDig();
    } else if (isWateringCanAction(player: player, actionId: event.id)) {
      developer.log('[FarmController] ✓ É watering can action');
      _handleExecuteWateringCan();
    } else if (isSeedAction(player: player, actionId: event.id)) {
      developer.log('[FarmController] ✓ É seed action');
      _handleExecuteSeed();
    } else if (isHarvestAction(player: player, actionId: event.id)) {
      developer.log('[FarmController] ✓ É harvest action');
      _handleExecuteHarvest();
    } else {
      developer.log(
        '[FarmController] ✗ Não é ação de farm, passando para super',
      );
    }

    super.handleInputAction(player: player, event: event);
  }

  bool _tryConsumeSelectedVegetable(DDBasePlayerView player) {
    final selectedIndex = EquipmentManager.instance.currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedIndex);
    if (slot == null || slot.isEmpty) {
      developer.log('[FarmController] Consumo falhou: slot vazio ($selectedIndex)');
      return false;
    }

    final item = slot.item;
    int staminaGain = 0;
    double healthGain = 0;

    developer.log(
      '[FarmController] Consumo tentativa: slot=$selectedIndex item=${item.runtimeType} qty=${slot.quantity}',
    );

    if (item is CropItem) {
      if (!item.isEdible) return false;
      staminaGain = item.effectiveEnergyRestore;
      healthGain = item.effectiveHealthRestore.toDouble();
    } else if (item is ConsumableItem) {
      staminaGain = item.staminaRestore;
      healthGain = item.healthRestore.toDouble();
    } else {
      return false;
    }

    if (healthGain > 0) {
      player.addLife(healthGain);
    }

    if (staminaGain > 0) {
      model.restoreStamina(staminaGain);
    }

    InventoryManager.instance.consumeFromSlot(selectedIndex, 1);
    developer.log('[FarmController] Consumo aplicado: hp=+$healthGain, stamina=+$staminaGain, slot=$selectedIndex');

    return true;
  }

  void _handleExecuteDig() {
    developer.log(
      '[FarmController] _handleExecuteDig: stamina=${model.stamina}, canExecute=${model.canExecuteDig}',
    );

    if (!model.canExecuteDig) {
      developer.log('[FarmController] ✗ Não pode executar dig');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.digStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteDig.call();

    developer.log('[FarmController] Dig wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.digStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteWateringCan() {
    developer.log(
      '[FarmController] _handleExecuteWateringCan: stamina=${model.stamina}, canExecute=${model.canExecuteWateringCan}',
    );

    if (!model.canExecuteWateringCan) {
      developer.log('[FarmController] ✗ Não pode executar watering can');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.wateringCanStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteWateringCan.call();

    developer.log('[FarmController] WateringCan wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.wateringCanStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteSeed() {
    developer.log(
      '[FarmController] _handleExecuteSeed: stamina=${model.stamina}, canExecute=${model.canExecuteSeed}',
    );

    if (!model.canExecuteSeed) {
      developer.log('[FarmController] ✗ Não pode executar seed');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.seedStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteSeed.call();

    developer.log('[FarmController] Seed wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.seedStaminaCost);

    endStaminaConsumingAction();
  }

  void _handleExecuteHarvest() {
    developer.log(
      '[FarmController] _handleExecuteHarvest: stamina=${model.stamina}, canExecute=${model.canExecuteHarvest}',
    );

    if (!model.canExecuteHarvest) {
      developer.log('[FarmController] ✗ Não pode executar harvest');
      // Só mostra "Sem Stamina" se realmente for problema de stamina
      if (model.stamina < model.config.harvestStaminaCost) {
        OverlayMessageDef.showNoStamina();
      }
      return;
    }

    beginStaminaConsumingAction();

    final bool wasExecuted = onExecuteHarvest.call();

    developer.log('[FarmController] Harvest wasExecuted: $wasExecuted');

    if (!wasExecuted) {
      endStaminaConsumingAction();
      return;
    }

    model.consumeStamina(model.config.harvestStaminaCost);

    endStaminaConsumingAction();
  }
}
