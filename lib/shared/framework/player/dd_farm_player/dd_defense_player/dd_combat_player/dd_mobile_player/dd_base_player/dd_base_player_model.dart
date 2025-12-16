import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:flutter/foundation.dart';

class DDBasePlayerModel {
  final DDBasePlayerModelConfig modelConfig;
  final DDBasePlayerSaveData _saveData;

  bool _isObservingEnemy;

  @protected
  DDBasePlayerModel.internal({
    required this.modelConfig,
    required DDBasePlayerSaveData saveData,
  }) : _saveData = saveData,
       _isObservingEnemy = false;

  @protected
  static EquippedHandType? parseEquipment(String? eq) {
    if (eq == null || eq == 'null' || eq.isEmpty) return null;
    try {
      return EquippedHandType.values.byName(eq);
    } catch (e) {
      return null;
    }
  }

  double get stamina => _saveData.stamina;
  int get energy => _saveData.energy;
  double? get life => _saveData.life;
  bool get hasKey => _saveData.hasKey;
  bool get hasStamina => _saveData.stamina > 0;
  EquippedHandType? get equipment => _saveData.equipment;

  bool get isObservingEnemy => _isObservingEnemy;
  void startObservingEnemy() => _isObservingEnemy = true;
  void stopObservingEnemy() => _isObservingEnemy = false;

  void consumeStamina(int amount) {
    _saveData.stamina -= amount;
    if (_saveData.stamina < 0) _saveData.stamina = 0;
  }

  void regenerateStamina() {
    _saveData.stamina += modelConfig.staminaRegenIncrement;
    if (_saveData.stamina > modelConfig.maxStamina) {
      _saveData.stamina = modelConfig.maxStamina;
    }
  }

  void consumeEnergy(int amount) {
    _saveData.energy -= amount;
    if (_saveData.energy < 0) _saveData.energy = 0;
  }

  void restoreEnergy() => _saveData.energy = modelConfig.maxEnergy;

  void updateLife(double value) => _saveData.life = value;

  void setEquipment(EquippedHandType? value) => _saveData.equipment = value;

  void obtainKey() => _saveData.hasKey = true;
  void removeKey() => _saveData.hasKey = false;

  Map<String, dynamic> toJson() => _saveData.toJson();

  @protected
  factory DDBasePlayerModel.fromJson(
    Map<String, dynamic> json,
    DDBasePlayerModelConfig modelConfig,
  ) {
    return DDBasePlayerModel.internal(
      modelConfig: modelConfig,
      saveData: DDBasePlayerSaveData.fromJson(json, modelConfig),
    );
  }
}
