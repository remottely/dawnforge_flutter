import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:flutter/foundation.dart';

class DDBasePlayerModel {
  final DDBasePlayerModelConfig config;
  final DDBasePlayerSaveData _saveData;
  EquippedHandType? _equipment;

  bool _isObservingEnemy;

  @protected
  DDBasePlayerModel.internal({
    required this.config,
    required DDBasePlayerSaveData saveData,
  }) : _saveData = saveData,
       _equipment = null,
       _isObservingEnemy = false;

  double get stamina => _saveData.stamina;
  int get energy => _saveData.energy;
  double? get life => _saveData.life;
  bool get hasKey => _saveData.hasKey;
  bool get hasStamina => _saveData.stamina > 0;
  EquippedHandType? get equipment => _equipment;

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

  void setEquipment(EquippedHandType? value) => _equipment = value;

  void obtainKey() => _saveData.hasKey = true;
  void removeKey() => _saveData.hasKey = false;

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
