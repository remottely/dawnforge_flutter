import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';

abstract class DDBasePlayerModel {
  final DDBasePlayerModelConfig modelConfig;

  double _currentStamina;
  int _currentEnergy;
  double? _currentLife;
  bool _hasKeyItem;
  bool _isObservingEnemies;
  EquippedHandType? _equipment;

  DDBasePlayerModel({
    required this.modelConfig,
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : _currentStamina = initialStamina ?? modelConfig.maxStamina,
       _currentEnergy = initialEnergy ?? modelConfig.maxEnergy,
       _currentLife = initialLife,
       _hasKeyItem = initialHasKey ?? false,
       _isObservingEnemies = false;

  double get currentStamina => _currentStamina;

  int get energy => _currentEnergy;

  double? get life => _currentLife;

  bool get hasKey => _hasKeyItem;

  bool get isObservingEnemy => _isObservingEnemies;

  set isObservingEnemy(bool value) => _isObservingEnemies = value;

  bool get hasStamina => _currentStamina > 0;

  EquippedHandType? get equipment => _equipment;
  void setEquipment(EquippedHandType value) => _equipment = value;

  void consumeStamina(int amount) {
    _currentStamina = (_currentStamina - amount).clamp(
      0,
      modelConfig.maxStamina,
    );
  }

  void regenerateStamina() {
    _currentStamina = (_currentStamina + modelConfig.staminaRegenIncrement)
        .clamp(0, modelConfig.maxStamina);
  }

  void consumeEnergy(int amount) {
    _currentEnergy = (_currentEnergy - amount).clamp(0, modelConfig.maxEnergy);
  }

  void restoreEnergy() {
    _currentEnergy = modelConfig.maxEnergy;
  }

  void updateLife(double value) {
    _currentLife = value;
  }

  void obtainKey() => _hasKeyItem = true;

  void removeKey() => _hasKeyItem = false;

  Map<String, dynamic> toJson() {
    return {
      'currentStamina': _currentStamina,
      'currentEnergy': _currentEnergy,
      'currentLife': _currentLife,
      'hasKeyItem': _hasKeyItem,
      'isObservingEnemies': _isObservingEnemies,
      'equipment': _equipment?.name,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _currentStamina =
        (json['currentStamina'] as num?)?.toDouble() ?? modelConfig.maxStamina;
    _currentEnergy = (json['currentEnergy'] as int?) ?? modelConfig.maxEnergy;
    _currentLife = (json['currentLife'] as num?)?.toDouble();
    _hasKeyItem = (json['hasKeyItem'] as bool?) ?? false;
    _isObservingEnemies = (json['isObservingEnemies'] as bool?) ?? false;
    _equipment = (json['equipment'] as String?) == 'null'
        ? null
        : EquippedHandType.values.byName(json['equipment']);
  }
}
