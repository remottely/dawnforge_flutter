import 'dart:async' show unawaited;
import 'package:dawnforge/core/utils/logger/game_logger.dart';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/core/modules/ui/dialog/binary_choice_dialog.dart';
import 'package:dawnforge/gameplay/inventory/items/consumable_item.dart';
import 'package:dawnforge/gameplay/inventory/items/harvest_loot_item.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Handles consumable usage (vegetables/consumables) independent from farm actions.
abstract class DDConsumablePlayerController<M extends DDCombatPlayerModel>
    extends DDCombatPlayerController<M> {
  bool _isShowingConsumeDialog = false;

  DDConsumablePlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
  });

  @override
  void handleInputAction({
    required DemoPlayer player,
    required JoystickActionEvent event,
  }) {
    if (handleConsumableInput(player: player, event: event)) {
      return;
    }

    // Forward to combat chain if nothing to consume.
    handleBaseCombatInputAction(player: player, event: event);
  }

  /// Allows subclasses to reuse the consumable handling early in their overrides.
  @protected
  bool handleConsumableInput({
    required DemoPlayer player,
    required JoystickActionEvent event,
  }) {
    final bool isInteraction = _isConsumeAction(event.id);
    final bool isConsumeVegetable =
        event.event == ActionEvent.DOWN && isInteraction;

    if (!isConsumeVegetable) {
      return false;
    }

    final consumed = _tryConsumeSelectedItem(player);
    GameLogger.info(
      '[ConsumableController] Consumo via interação: success=$consumed',
    );
    return consumed;
  }

  /// Call the original combat chain (skipping consumable re-processing).
  @protected
  void handleBaseCombatInputAction({
    required DemoPlayer player,
    required JoystickActionEvent event,
  }) {
    super.handleInputAction(player: player, event: event);
  }

  bool _isConsumeAction(dynamic actionId) {
    if (InputDef.isInteractionAction(actionId)) return true;

    // Fallback para garantir que X seja reconhecido mesmo se vier como instância diferente.
    if (actionId is LogicalKeyboardKey) {
      if (actionId.keyId == LogicalKeyboardKey.keyX.keyId) return true;
    }

    return false;
  }

  bool _tryConsumeSelectedItem(DemoPlayer player) {
    final selectedIndex = EquipmentManager.instance.currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedIndex);
    if (slot == null || slot.isEmpty) {
      GameLogger.warning(
        '[ConsumableController] Consumo falhou: slot vazio ($selectedIndex)',
      );
      return false;
    }

    if (_isShowingConsumeDialog) {
      GameLogger.warning('[ConsumableController] Consumo já em progresso');
      return true;
    }

    final item = slot.item;
    if (item == null) {
      GameLogger.warning(
        '[ConsumableController] Consumo falhou: item nulo ($selectedIndex)',
      );
      return false;
    }

    int staminaGain = 0;
    double healthGain = 0;

    GameLogger.info(
      '[ConsumableController] Consumo tentativa: slot=$selectedIndex item=${item.runtimeType} qty=${slot.quantity}',
    );

    if (item is HarvestLootItem) {
      if (!item.isEdible) return false;
      staminaGain = item.staminaRestore;
      healthGain = item.staminaRestore.toDouble();
    } else if (item is ConsumableItem) {
      staminaGain = item.staminaRestore;
      healthGain = item.healthRestore.toDouble();
    } else {
      return false;
    }

    unawaited(
      _confirmConsumeItem(
        player: player,
        slotIndex: selectedIndex,
        itemName: item.name,
        staminaGain: staminaGain,
        healthGain: healthGain,
      ),
    );

    // Diálogo é assíncrono; retornamos true para bloquear outras ações enquanto a escolha é feita.
    return true;
  }

  Future<void> _confirmConsumeItem({
    required DemoPlayer player,
    required int slotIndex,
    required String itemName,
    required int staminaGain,
    required double healthGain,
  }) async {
    _isShowingConsumeDialog = true;

    final result = await BinaryChoiceDialog.show(
      context: player.gameRef.context,
      question: 'Consumir $itemName?',
      yesLabel: 'Sim',
      noLabel: 'Não',
    );

    _isShowingConsumeDialog = false;

    if (result != true) {
      GameLogger.info('[ConsumableController] Consumo cancelado');
      return;
    }

    if (healthGain > 0) {
      player.addLife(healthGain);
    }

    if (staminaGain > 0) {
      model.restoreStamina(staminaGain);
    }

    InventoryManager.instance.consumeFromSlot(slotIndex, 1);
    GameLogger.info(
      '[ConsumableController] Consumo aplicado: hp=+$healthGain, stamina=+$staminaGain, slot=$slotIndex',
    );
  }
}
