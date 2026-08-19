import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/items/weapon_item.dart';
import 'package:dawnforge/game/features/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:flutter/foundation.dart';

class DDBasePlayerModel {
  final DDBasePlayerModelConfig config;
  final DDBasePlayerSaveData _saveData;
  final ValueNotifier<int> coinsNotifier;

  bool _isObservingEnemy;

  @protected
  DDBasePlayerModel.internal({
    required this.config,
    required DDBasePlayerSaveData saveData,
  }) : _saveData = saveData,
       coinsNotifier = ValueNotifier<int>(saveData.coins),
       _isObservingEnemy = false;

  double get stamina => _saveData.stamina;
  int get energy => _saveData.energy;
  double? get life => _saveData.life;
  int get coins => _saveData.coins;
  bool get hasStamina => _saveData.stamina > 0;
  Vector2 get position => _saveData.position;
  void setPosition(Vector2 value) => _saveData.position = value;

  /// Equipment always points to the currently selected inventory slot
  /// This is never null - it always represents the selected slot
  /// If the slot is empty, equipment will be null
  HandItemId? get equipment {
    final selectedSlotIndex =
        EquipmentManager.instance.currentMainHandSlotIndex;
    final slot = InventoryManager.instance.getSlotByIndex(selectedSlotIndex);
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

  void addCoins(int amount) {
    if (amount <= 0) return;
    _saveData.coins += amount;
    coinsNotifier.value = _saveData.coins;
  }

  bool removeCoins(int amount) {
    if (amount <= 0) return true;
    if (!canAffordCoins(amount)) return false;
    _saveData.coins -= amount;
    coinsNotifier.value = _saveData.coins;
    return true;
  }

  bool canAffordCoins(int amount) => amount <= _saveData.coins;

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
