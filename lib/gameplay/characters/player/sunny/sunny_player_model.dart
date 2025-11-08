import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_profile.dart';

enum FarmTool { hand, hoe, wateringCan }

class SunnyPlayerModel {
  double _stamina;
  int _energy;
  FarmTool currentTool;
  bool hasKey;
  bool isObservingEnemy;

  SunnyPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    FarmTool? initialTool,
    bool? initialHasKey,
  }) : _stamina = initialStamina ?? SunnyPlayerProfile.kMaxStamina,
       _energy = initialEnergy ?? SunnyPlayerProfile.kMaxEnergy,
       currentTool = initialTool ?? FarmTool.hand,
       hasKey = initialHasKey ?? false,
       isObservingEnemy = false;

  // Getters
  double get stamina => _stamina;
  int get energy => _energy;

  // Validations
  bool get hasStamina => _stamina > 0;

  bool get canExecutePrimaryAttack =>
      _stamina >= SunnyPlayerProfile.kPrimaryAttackStaminaCost;

  bool get canExecuteFireballAttack =>
      _stamina >= SunnyPlayerProfile.kFireballAttackStaminaCost;

  bool get canExecuteToolAction =>
      _energy >= SunnyPlayerProfile.kToolActionEnergyCost;

  // State mutations
  void consumeStamina(int amount) {
    _stamina = (_stamina - amount).clamp(0, SunnyPlayerProfile.kMaxStamina);
  }

  void regenerateStamina() {
    _stamina = (_stamina + SunnyPlayerProfile.kStaminaIncrement).clamp(
      0,
      SunnyPlayerProfile.kMaxStamina,
    );
  }

  void consumeEnergy(int amount) {
    _energy = (_energy - amount).clamp(0, SunnyPlayerProfile.kMaxEnergy);
  }

  void restoreEnergy() {
    _energy = SunnyPlayerProfile.kMaxEnergy;
  }

  void switchTool(FarmTool newTool) => currentTool = newTool;

  void obtainKey() => hasKey = true;
  void removeKey() => hasKey = false;
}
