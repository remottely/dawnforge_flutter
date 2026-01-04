import 'package:darkness_dungeon/gameplay/inventory/managers/equipment_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/managers/inventory_manager.dart';
import 'package:darkness_dungeon/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:darkness_dungeon/gameplay/inventory/items/weapon_item.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand/hand_item_id.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:flutter/foundation.dart';

class DDBasePlayerModel {
  final DDBasePlayerModelConfig config;
  final DDBasePlayerSaveData _saveData;

  bool _isObservingEnemy;

  @protected
  DDBasePlayerModel.internal({
    required this.config,
    required DDBasePlayerSaveData saveData,
  }) : _saveData = saveData,
       _isObservingEnemy = false;

  double get stamina => _saveData.stamina;
  int get energy => _saveData.energy;
  double? get life => _saveData.life;
  bool get hasStamina => _saveData.stamina > 0;

  /// Equipment always points to the currently selected inventory slot
  /// This is never null - it always represents the selected slot
  /// If the slot is empty, equipment will be null
  HandItemId? get equipment {
    final selectedSlotIndex =
        getIt<EquipmentManager>().currentMainHandSlotIndex;
    final slot = getIt<InventoryManager>().getSlotByIndex(selectedSlotIndex);
    final item = slot?.item;

    if (item is WeaponItem) {
      return item.id;
    }

    return item?.id;
  }

  bool get isObservingEnemy => _isObservingEnemy;
  void startObservingEnemy() => _isObservingEnemy = true;
  void stopObservingEnemy() => _isObservingEnemy = false;

  void consumeStamina(int amount) {
    _saveData.stamina -= amount;
    if (_saveData.stamina < 0) _saveData.stamina = 0;
  }

  void regenerateStamina() => restoreStamina(config.staminaRegenIncrement);

  /// Restore a specific amount of stamina (e.g., from consumables)
  void restoreStamina(int amount) {
    _saveData.stamina += amount;
    if (_saveData.stamina > config.maxStamina) {
      _saveData.stamina = config.maxStamina;
    }
  }

  /// Restore stamina to maximum (e.g., when a new day starts)
  void restoreStaminaFully() => _saveData.stamina = config.maxStamina;

  void consumeEnergy(int amount) {
    _saveData.energy -= amount;
    if (_saveData.energy < 0) _saveData.energy = 0;
  }

  void restoreEnergy() => _saveData.energy = config.maxEnergy;

  void updateLife(double value) => _saveData.life = value;

  Map<String, dynamic> toJson() => _saveData.toJson();

  @protected
  factory DDBasePlayerModel.fromJson(
    Map<String, dynamic> json,
    DDBasePlayerModelConfig config,
  ) {
    return DDBasePlayerModel.internal(
      config: config,
      saveData: DDBasePlayerSaveData.fromJson(json, config),
    );
  }
}
