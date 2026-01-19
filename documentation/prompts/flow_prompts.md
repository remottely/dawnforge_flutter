// lib/shared/framework/player/dd_farm_player/dd_consumable_player/dd_consumable_player_controller.dart
import 'dart:async' show unawaited;
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/global/global_input_handler.dart';
import 'package:dawnforge/game/systems/ui/dialog/binary_choice_dialog.dart';
import 'package:dawnforge/game/features/inventory/items/consumable_item.dart';
import 'package:dawnforge/game/features/inventory/items/harvest_loot_item.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_view.dart';
import 'package:flutter/foundation.dart';

/// Handles consumable usage (vegetables/consumables) independent from farm actions.
/// ✅ SEM PlayerControllerListener - Usa callbacks no GlobalInputHandler
/// ✅ OTIMIZADO - Só registra quando equipamento muda
abstract class DDConsumablePlayerController<M extends DDCombatPlayerModel>
    extends DDCombatPlayerController<M> {
  bool _isShowingConsumeDialog = false;
  bool _isRegistered = false;
  DDBasePlayerView? _player;

  DDConsumablePlayerController({
    required super.model,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
    required super.onChangeRunState,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
  });

  /// ✅ INICIALIZA LISTENER (chame no onLoad do player)
  void initializeConsumableListener(DDBasePlayerView player) {
    _player = player;

    // ✅ ESCUTA MUDANÇAS DE EQUIPAMENTO
    EquipmentManager.instance.onEquipmentChanged.addListener(_onEquipmentChanged);

    // ✅ REGISTRA INICIAL (se já tiver consumível equipado)
    _updateConsumableRegistration();

    if (kDebugMode) {
      GameLogger.debug('[ConsumableController] 🎧 Listener initialized');
    }
  }

  /// ✅ CALLBACK CHAMADO QUANDO EQUIPAMENTO MUDA
  void _onEquipmentChanged() {
    if (kDebugMode) {
      GameLogger.debug(
        '[ConsumableController] 🔄 Equipment changed, updating registration',
      );
    }
    _updateConsumableRegistration();
  }

  /// ✅ Atualiza registro no GlobalInputHandler
  void _updateConsumableRegistration() {
    if (_player == null) return;

    final hasConsumable = _hasConsumableEquipped();

    if (hasConsumable && !_isRegistered) {
      // ✅ REGISTRA COM CALLBACK
      GlobalInputHandler.register(
        id: 'consumable_${_player.hashCode}',
        type: InteractionType.consumable,
        onExecute: () async {
          if (kDebugMode) {
            GameLogger.debug('[ConsumableController] 🍎 Executing consume action');
          }
          await _tryConsumeSelectedItem(_player!);
        },
      );
      _isRegistered = true;

      if (kDebugMode) {
        GameLogger.debug('[ConsumableController] ✅ Registered in GlobalInputHandler');
      }
    } else if (!hasConsumable && _isRegistered) {
      // ✅ DESREGISTRA
      GlobalInputHandler.unregister('consumable_${_player.hashCode}');
      _isRegistered = false;

      if (kDebugMode) {
        GameLogger.debug('[ConsumableController] ➖ Unregistered from GlobalInputHandler');
      }
    }
  }

  /// ✅ MÉTODO LEGADO (mantido para compatibilidade, mas não usa mais)
  @Deprecated('Use initializeConsumableListener instead')
  void updateConsumableRegistration(DDBasePlayerView player) {
    // Não faz nada - mantido apenas para não quebrar código existente
    if (kDebugMode) {
      GameLogger.debug(
        '[ConsumableController] ⚠️ updateConsumableRegistration is deprecated',
      );
    }
  }

  /// Call the original combat chain (skipping consumable re-processing).
  @protected
  void handleBaseCombatInputAction({
    required DDBasePlayerView player,
    required JoystickActionEvent event,
  }) {
    super.handleInputAction(player: player, event: event);
  }

  /// Verifica se tem consumível equipado
  bool _hasConsumableEquipped() {
    final selectedIndex = EquipmentManager.instance.currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedIndex);

    if (slot == null || slot.isEmpty) return false;

    final item = slot.item;
    if (item == null) return false;

    if (item is HarvestLootItem && item.isEdible) return true;
    if (item is ConsumableItem) return true;

    return false;
  }

  /// Tenta consumir o item selecionado
  Future<void> _tryConsumeSelectedItem(DDBasePlayerView player) async {
    final selectedIndex = EquipmentManager.instance.currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedIndex);

    if (slot == null || slot.isEmpty) {
      if (kDebugMode) {
        GameLogger.debug('[ConsumableController] Consumo falhou: slot vazio');
      }
      return;
    }

    if (_isShowingConsumeDialog) {
      if (kDebugMode) {
        GameLogger.debug('[ConsumableController] Consumo já em progresso');
      }
      return;
    }

    final item = slot.item;
    if (item == null) {
      if (kDebugMode) {
        GameLogger.debug('[ConsumableController] Consumo falhou: item nulo');
      }
      return;
    }

    int staminaGain = 0;
    double healthGain = 0;

    if (kDebugMode) {
      GameLogger.info(
        '[ConsumableController] Consumo tentativa: slot=$selectedIndex '
        'item=${item.runtimeType} qty=${slot.quantity}',
      );
    }

    if (item is HarvestLootItem) {
      if (!item.isEdible) {
        if (kDebugMode) {
          GameLogger.debug('[ConsumableController] Item não é comestível: ${item.name}');
        }
        return;
      }
      staminaGain = item.staminaRestore;
      healthGain = item.staminaRestore.toDouble();
    } else if (item is ConsumableItem) {
      staminaGain = item.staminaRestore;
      healthGain = item.healthRestore.toDouble();
    } else {
      if (kDebugMode) {
        GameLogger.debug('[ConsumableController] Item não é consumível: ${item.runtimeType}');
      }
      return;
    }

    // ✅ MOSTRA DIÁLOGO DE CONFIRMAÇÃO
    await _confirmAndConsumeItem(
      player: player,
      slotIndex: selectedIndex,
      itemName: item.name,
      staminaGain: staminaGain,
      healthGain: healthGain,
    );
  }

  /// Confirma e consome o item
  Future<void> _confirmAndConsumeItem({
    required DDBasePlayerView player,
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
      GameLogger.info('[ConsumableController] Consumo cancelado pelo usuário');
      return;
    }

    // ✅ APLICA EFEITOS
    if (healthGain > 0) {
      player.addLife(healthGain);
    }

    if (staminaGain > 0) {
      model.restoreStamina(staminaGain);
    }

    // ✅ CONSOME 1 UNIDADE DO ITEM
    InventoryManager.instance.consumeFromSlot(slotIndex, 1);

    GameLogger.info(
      '[ConsumableController] ✅ Consumo aplicado: '
      'hp=+$healthGain, stamina=+$staminaGain, slot=$slotIndex',
    );

    // ✅ ATUALIZA REGISTRO (pode ter ficado sem items)
    _updateConsumableRegistration();
  }

  @override
  void dispose() {
    // ✅ REMOVE LISTENER
    EquipmentManager.instance.onEquipmentChanged.removeListener(_onEquipmentChanged); // error: The getter 'onEquipmentChanged' isn't defined for the type 'EquipmentManager'.
// Try importing the library that defines 'onEquipmentChanged', correcting the name to the name of an existing getter, or defining a getter or field named 'onEquipmentChanged'.

    // ✅ DESREGISTRA DO GlobalInputHandler
    if (_isRegistered && _player != null) {
      GlobalInputHandler.unregister('consumable_${_player.hashCode}');
      _isRegistered = false;
    }

    super.dispose();
  }
}

import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:flutter/foundation.dart';

import '../entities/hand_item.dart';
import '../items/weapon_item.dart';
import 'inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/state/equipment_state.dart';

/// Manager for equipment state (C1: Singleton + ValueNotifier, I2: Manager = Singleton State)
final class EquipmentManager {
  EquipmentManager._();

  static final EquipmentManager instance = EquipmentManager._();

  void initialize() {
    InventoryManager.instance.slotsNotifier.addListener(
      _handleInventorySlotsChanged,
    );
  }

  /// J3: ValueNotifier for cross-module communication
  final ValueNotifier<int> selectedSlotIndexNotifier = ValueNotifier(0);

  int _currentMainHandSlotIndex = 0;

  int get currentMainHandSlotIndex => _currentMainHandSlotIndex;

  // /// In this design, "equipping" means selecting the inventory slot that holds the item.
  // bool equip(Item item, {int? inventorySlotIndex}) {
  //   GameLogger.info('[EquipmentManager] Selecting slot for ${item.name}');

  //   // If caller provided the slot index, just select it.
  //   if (inventorySlotIndex != null) {
  //     return selectSlotIndex(inventorySlotIndex);
  //   }

  //   // Otherwise, find the first slot containing this item id.
  //   final slot = InventoryManager.instance.findSlotByItemId(item.id);
  //   if (slot == null) {
  //     GameLogger.warning('[EquipmentManager] Item not in inventory');
  //     return false;
  //   }
  //   return selectSlotIndex(slot.index);
  // }

  bool selectSlotIndex(int index) {
    final slot = InventoryManager.instance.getSlotByIndex(index);
    if (slot == null) {
      GameLogger.warning('[EquipmentManager] Slot $index not found');
      return false;
    }

    _currentMainHandSlotIndex = index;
    selectedSlotIndexNotifier.value = index;

    // Update overlays with current item (can be null if slot empty)
    EquipmentState.instance.updateEquippedItem(slot.item);
    GameLogger.info(
      '[EquipmentManager] Selected slot $index (${slot.item?.name ?? 'empty'})',
    );
    return true;
  }

  void clearSelectedEquipment() {
    EquipmentState.instance.updateEquippedItem(null);
  }

  HandItem? getEquippedItem() =>
      InventoryManager.instance.getSlotByIndex(_currentMainHandSlotIndex)?.item;

  bool hasEquippedItem() => getEquippedItem() != null;

  List<HandItem> getAllEquippedItems() {
    final item = getEquippedItem();
    return item != null ? [item] : [];
  }

  int getTotalDamage() {
    final mainHand = getEquippedItem();
    if (mainHand == null) return 0;
    if (mainHand is WeaponItem) return mainHand.damage;
    return 0;
  }

  double getTotalDps() {
    final mainHand = getEquippedItem();
    if (mainHand == null) return 0;
    if (mainHand is WeaponItem) return mainHand.damage.toDouble();
    return 0;
  }

  int getTotalDefense() {
    return 0;
  }

  Map<String, dynamic> getTotalStats() {
    return {
      'damage': getTotalDamage(),
      'dps': getTotalDps(),
      'defense': getTotalDefense(),
    };
  }

  Map<String, dynamic> toJson() {
    return {'selectedSlotIndex': _currentMainHandSlotIndex};
  }

  void fromJson(
    Map<String, dynamic> json,
    HandItem? Function(HandItemId itemId) itemFactory,
  ) {
    _currentMainHandSlotIndex = json['selectedSlotIndex'] as int? ?? 0;
    // Clamp to available slots
    if (_currentMainHandSlotIndex >= InventoryManager.instance.maxSlots) {
      _currentMainHandSlotIndex = 0;
    }
    selectedSlotIndexNotifier.value = _currentMainHandSlotIndex;

    // Update UI with current item
    final item = InventoryManager.instance
        .getSlotByIndex(_currentMainHandSlotIndex)
        ?.item;
    EquipmentState.instance.updateEquippedItem(item);

    GameLogger.info(
      '[EquipmentManager] Loaded selected slot $_currentMainHandSlotIndex',
    );
  }

  void reset() {
    _currentMainHandSlotIndex = 0;
    selectedSlotIndexNotifier.value = 0;

    // Notify Flutter overlays
    EquipmentState.instance.updateEquippedItem(
      InventoryManager.instance.getSlotByIndex(0)?.item,
    );

    GameLogger.info('[EquipmentManager] Equipment reset');
  }

  void _handleInventorySlotsChanged() {
    final selectedIndex = _currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedIndex);
    if (slot == null) return;

    // Keep overlay synced with whatever is in the selected slot
    EquipmentState.instance.updateEquippedItem(slot.item);
  }
}
