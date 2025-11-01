import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';

enum FarmTool { hand, hoe, wateringCan }

/// Model: Contém apenas dados e validações simples
class KnightPlayerModel {
  double _stamina;
  int _energy;
  double attackDamage;
  FarmTool currentTool;
  bool hasKey;
  bool isObservingEnemy;

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
       hasKey = initialHasKey ?? false,
       isObservingEnemy = false;

  // Getters
  double get stamina => _stamina;
  int get energy => _energy;
  double get maxStamina => KnightPlayerConfig.kMaxStamina;
  int get maxEnergy => KnightPlayerConfig.kMaxEnergy;

  // Validações simples
  bool get hasStamina => _stamina > 0;
  bool get canPrimaryAttack =>
      _stamina >= KnightPlayerConfig.kPrimaryAttackStaminaCost;
  bool get canFireballAttack =>
      _stamina >= KnightPlayerConfig.kFireballAttackStaminaCost;
  bool get canUseTool => _energy >= KnightPlayerConfig.kToolUsageEnergyCost;

  // Mutações de estado
  void consumeStamina(int amount) {
    _stamina = (_stamina - amount).clamp(0, KnightPlayerConfig.kMaxStamina);
  }

  void regenerateStamina() {
    _stamina = (_stamina + KnightPlayerConfig.kStaminaIncrement).clamp(
      0,
      KnightPlayerConfig.kMaxStamina,
    );
  }

  void consumeEnergy(int amount) {
    _energy = (_energy - amount).clamp(0, KnightPlayerConfig.kMaxEnergy);
  }

  void restoreEnergy() {
    _energy = KnightPlayerConfig.kMaxEnergy;
  }

  void switchTool(FarmTool newTool) => currentTool = newTool;

  void obtainKey() => hasKey = true;
  void removeKey() => hasKey = false;
}
