import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';

class DDBasePlayerModel {
  final DDBasePlayerModelConfig modelConfig;
  final DDBasePlayerModelState modelState;

  double _stamina;
  int _energy;
  double? _life;
  bool _hasKey;
  bool _isObservingEnemy;
  EquippedHandType? _equipment;

  DDBasePlayerModel({required this.modelConfig, required this.modelState})
    : _stamina = modelState.stamina ?? modelConfig.maxStamina,
      _energy = modelState.energy ?? modelConfig.maxEnergy,
      _life = modelState.life,
      _hasKey = modelState.hasKey ?? false,
      _isObservingEnemy = false;

  double get stamina => _stamina;
  int get energy => _energy;
  double? get life => _life;
  bool get hasKey => _hasKey;
  bool get isObservingEnemy => _isObservingEnemy;
  bool get hasStamina => _stamina > 0;
  EquippedHandType? get equipment => _equipment;

  void consumeStamina(int amount) {
    _stamina -= amount;
    if (_stamina < 0) _stamina = 0;
  }

  void regenerateStamina() {
    _stamina += modelConfig.staminaRegenIncrement;
    if (_stamina > modelConfig.maxStamina) _stamina = modelConfig.maxStamina;
  }

  void consumeEnergy(int amount) {
    _energy -= amount;
    if (_energy < 0) _energy = 0;
  }

  void restoreEnergy() => _energy = modelConfig.maxEnergy;

  void updateLife(double value) => _life = value;

  void startObservingEnemy() => _isObservingEnemy = true;
  void stopObservingEnemy() => _isObservingEnemy = false;

  void setEquipment(EquippedHandType? value) => _equipment = value;

  void obtainKey() => _hasKey = true;
  void removeKey() => _hasKey = false;

  Map<String, dynamic> toJson() => {
    'stamina': _stamina,
    'energy': _energy,
    'life': _life,
    'hasKey': _hasKey,
    'equipment': _equipment?.name,
  };

  void fromJson(Map<String, dynamic> json) {
    _stamina = (json['stamina'] as num?)?.toDouble() ?? modelConfig.maxStamina;
    _energy = (json['energy'] as int?) ?? modelConfig.maxEnergy;
    _life = (json['life'] as num?)?.toDouble();
    _hasKey = json['hasKey'] as bool? ?? false;
    final eq = json['equipment'] as String?;
    _equipment = (eq == null || eq == 'null')
        ? null
        : EquippedHandType.values.byName(eq);
  }
}
