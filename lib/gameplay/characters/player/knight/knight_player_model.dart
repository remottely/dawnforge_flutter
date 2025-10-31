import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';

enum FarmTool { hand, hoe, wateringCan }

class KnightPlayerModel {
  double _stamina;
  int _energy;
  double attackDamage;
  FarmTool currentTool;
  bool hasKey;

  KnightPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialAttackDamage,
    FarmTool? initialTool,
    bool? initialHasKey,
  }) : _stamina = initialStamina ?? KnightPlayerConfig.kMaxStamina,
       _energy = initialEnergy ?? KnightPlayerConfig.kMaxEnergy,
       attackDamage =
           initialAttackDamage ?? KnightPlayerConfig.kStandardAttackDamage,
       currentTool = initialTool ?? FarmTool.hand,
       hasKey = initialHasKey ?? false;

  double get currentStamina => _stamina;
  int get currentEnergy => _energy;
  bool get hasStamina => _stamina > 0;

  bool canDoPrimaryAttack() =>
      _stamina >= KnightPlayerConfig.kPrimaryAttackStaminaCost;

  void executePrimaryAttackStaminaCost() {
    _decrementStamina(KnightPlayerConfig.kPrimaryAttackStaminaCost);
  }

  bool canDoFireballAttack() =>
      _stamina >= KnightPlayerConfig.kFireballAttackStaminaCost;

  void executeFireballAttackStaminaCost() {
    _decrementStamina(KnightPlayerConfig.kFireballAttackStaminaCost);
  }

  void regenerateStamina() {
    _stamina += KnightPlayerConfig.kStaminaIncrement;
    if (_stamina > KnightPlayerConfig.kMaxStamina) {
      _stamina = KnightPlayerConfig.kMaxStamina;
    }
  }

  void _decrementStamina(int amount) {
    _stamina -= amount;
    if (_stamina < 0) {
      _stamina = 0;
    }
  }

  bool canUseTool() => _energy >= KnightPlayerConfig.kToolUsageEnergyCost;

  void useTool() {
    if (canUseTool()) {
      _energy -= KnightPlayerConfig.kToolUsageEnergyCost;
      if (_energy < 0) _energy = 0;
    }
  }

  void restoreEnergy() {
    _energy = KnightPlayerConfig.kMaxEnergy;
  }

  void switchTool(FarmTool newTool) {
    currentTool = newTool;
  }

  void obtainKey() {
    hasKey = true;
  }

  void removeKey() {
    hasKey = false;
  }
}
