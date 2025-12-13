import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';

abstract class DDBasePlayerModel {
  double _currentStamina;
  int _currentEnergy;
  double? _currentLife;
  bool _hasKeyItem;
  bool _isObservingEnemies;
  EquippedHandType? _equipment;

  DDBasePlayerModel({
    required double maxStamina,
    required int maxEnergy,
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : _currentStamina = initialStamina ?? maxStamina,
       _currentEnergy = initialEnergy ?? maxEnergy,
       _currentLife = initialLife,
       _hasKeyItem = initialHasKey ?? false,
       _isObservingEnemies = false;

  double get maxStamina;

  int get maxEnergy;

  int get staminaRegenIncrement;

  double get longVisionRadius;

  double get currentStamina => _currentStamina;

  int get energy => _currentEnergy;

  double? get life => _currentLife;

  bool get hasKey => _hasKeyItem;

  bool get isObservingEnemy => _isObservingEnemies;

  set isObservingEnemy(bool value) => _isObservingEnemies = value;

  bool get hasStamina => _currentStamina > 0;

  EquippedHandType? get equipment => _equipment;
  void setEquipment(EquippedHandType value) => _equipment = value;

  int get shovelStaminaCost;
  bool get canExecuteShovel =>
      (_currentStamina >= shovelStaminaCost) &&
      (_equipment == EquippedHandType.shovel);

  int get wateringCanStaminaCost;
  bool get canExecuteWateringCan =>
      (_currentStamina >= wateringCanStaminaCost) &&
      (_equipment == EquippedHandType.wateringCan);

  int get seedStaminaCost;
  bool get canExecuteSeed =>
      (_currentStamina >= seedStaminaCost) &&
      (_equipment == EquippedHandType.strawberry);

  int get harvestBasketStaminaCost;
  bool get canExecuteHarvestBasket =>
      (_currentStamina >= harvestBasketStaminaCost) &&
      (_equipment == EquippedHandType.harvestBasket);

  void consumeStamina(int amount) {
    _currentStamina = (_currentStamina - amount).clamp(0, maxStamina);
  }

  void regenerateStamina() {
    _currentStamina = (_currentStamina + staminaRegenIncrement).clamp(
      0,
      maxStamina,
    );
  }

  void consumeEnergy(int amount) {
    _currentEnergy = (_currentEnergy - amount).clamp(0, maxEnergy);
  }

  void restoreEnergy() {
    _currentEnergy = maxEnergy;
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
        (json['currentStamina'] as num?)?.toDouble() ?? maxStamina;
    _currentEnergy = (json['currentEnergy'] as int?) ?? maxEnergy;
    _currentLife = (json['currentLife'] as num?)?.toDouble();
    _hasKeyItem = (json['hasKeyItem'] as bool?) ?? false;
    _isObservingEnemies = (json['isObservingEnemies'] as bool?) ?? false;
    _equipment = (json['equipment'] as String?) == 'null'
        ? null
        : EquippedHandType.values.byName(json['equipment']);
  }
}
