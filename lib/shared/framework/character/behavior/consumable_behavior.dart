// lib/shared/framework/character/behavior/consumable_behavior.dart (CORRIGIDO)
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/gameplay/core/modules/input_actions/input_def.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/gameplay/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/gameplay/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/shared/framework/character/behavior/character_behavior.dart';

class ConsumableConfig {
  final double healthPotionRestoreAmount;
  final double staminaPotionRestoreAmount;
  final Duration consumeCooldown;

  const ConsumableConfig({
    this.healthPotionRestoreAmount = 50.0,
    this.staminaPotionRestoreAmount = 50.0,
    this.consumeCooldown = const Duration(milliseconds: 500),
  });
}

class ConsumableBehavior extends CharacterBehavior {
  final ConsumableConfig config;

  int _lastConsumeTime = 0;

  ConsumableBehavior(this.config);

  @override
  bool onInput(JoystickActionEvent event) {
    if (event.event != ActionEvent.DOWN) return false;

    // Use consumable
    if (InputDef.isConsumeAction(event.id)) {
      return _tryConsumeSelectedItem();
    }

    return false;
  }

  bool _tryConsumeSelectedItem() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastConsumeTime < config.consumeCooldown.inMilliseconds) {
      GameLogger.info('[ConsumableBehavior] Consume on cooldown');
      return false;
    }

    // ✅ CORREÇÃO: Usa EquipmentManager + InventoryManager
    final equipmentManager = getIt<EquipmentManager>();
    final inventoryManager = getIt<InventoryManager>();
    
    final selectedItem = equipmentManager.getEquippedItem();
    
    if (selectedItem == null) {
      GameLogger.info('[ConsumableBehavior] No item selected');
      return false;
    }

    bool consumed = false;

    // Health Potion
    if (selectedItem.id.name.contains('healthPotion')) {
      consumed = _consumeHealthPotion();
    }
    // Stamina Potion
    else if (selectedItem.id.name.contains('staminaPotion')) {
      consumed = _consumeStaminaPotion();
    }
    // Food items
    else if (selectedItem.id.name.contains('food') || 
             selectedItem.id.name.contains('loot_item')) {
      consumed = _consumeFood(selectedItem);
    }

    if (consumed) {
      _lastConsumeTime = now;

      // ✅ CORREÇÃO: Remove do slot equipado
      final slotIndex = equipmentManager.currentMainHandSlotIndex;
      inventoryManager.consumeFromSlot(slotIndex, 1);
      
      GameLogger.info('[ConsumableBehavior] ✓ Consumed ${selectedItem.id.name}');
    }

    return consumed;
  }

  bool _consumeHealthPotion() {
    if (character.life >= character.config.maxLife) {
      GameLogger.info('[ConsumableBehavior] Health already full');
      return false;
    }

    final newLife = (character.life + config.healthPotionRestoreAmount)
        .clamp(0, character.config.maxLife).toDouble();
    character.updateLife(newLife);
    character.data.updateLife(newLife);

    _displayHealEffect();

    return true;
  }

  bool _consumeStaminaPotion() {
    if (character.data.stamina >= character.data.maxStamina) {
      GameLogger.info('[ConsumableBehavior] Stamina already full');
      return false;
    }

    character.data.restoreStamina(config.staminaPotionRestoreAmount);

    _displayStaminaEffect();

    return true;
  }

  bool _consumeFood(dynamic foodItem) {
    bool restoredSomething = false;

    if (character.life < character.config.maxLife) {
      final newLife = (character.life + 20).clamp(0, character.config.maxLife).toDouble();
      character.updateLife(newLife);
      character.data.updateLife(newLife);
      restoredSomething = true;
    }

    if (character.data.stamina < character.data.maxStamina) {
      character.data.restoreStamina(20);
      restoredSomething = true;
    }

    if (restoredSomething) {
      _displayEatEffect();
    }

    return restoredSomething;
  }

  void _displayHealEffect() {
    // TODO: Adicionar partículas verdes de cura
  }

  void _displayStaminaEffect() {
    // TODO: Adicionar partículas amarelas de stamina
  }

  void _displayEatEffect() {
    // TODO: Adicionar animação de comer
  }
}
