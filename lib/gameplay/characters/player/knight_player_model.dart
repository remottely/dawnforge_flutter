import 'package:darkness_dungeon/gameplay/characters/player/knight_player_config.dart';

enum FarmTool { hand, hoe, wateringCan }

/// Armazena todo o estado e a lógica de negócios do jogador.
/// Não tem conhecimento da View (Bonfire/Flutter).
class KnightPlayerModel {
  // Estado
  double _stamina;
  int _energy;
  double attackDamage;
  FarmTool currentTool;
  bool hasKey;

  // Getters
  double get currentStamina => _stamina;
  int get currentEnergy => _energy;
  bool get hasStamina => _stamina > 0;

  KnightPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialAttackDamage,
    FarmTool? initialTool,
    bool? initialHasKey,
  })  : _stamina = initialStamina ?? KnightPlayerConfig.kMaxStamina,
        _energy = initialEnergy ?? KnightPlayerConfig.kMaxEnergy,
        attackDamage =
            initialAttackDamage ?? KnightPlayerConfig.kDefaultAttackDamage,
        currentTool = initialTool ?? FarmTool.hand,
        hasKey = initialHasKey ?? false;

  // --- Lógica de Stamina ---
  bool canDoMeleeAttack() =>
      _stamina >= KnightPlayerConfig.kMeleeAttackStaminaCost;

  void executeMeleeAttackStaminaCost() {
    _decrementStamina(KnightPlayerConfig.kMeleeAttackStaminaCost);
  }

  bool canDoFireballAttack() =>
      _stamina >= KnightPlayerConfig.kCharacterFireballAttackStaminaCost;

  void executeFireballAttackStaminaCost() {
    _decrementStamina(KnightPlayerConfig.kCharacterFireballAttackStaminaCost);
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

  // --- Lógica de Ferramenta/Energia ---
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
}
