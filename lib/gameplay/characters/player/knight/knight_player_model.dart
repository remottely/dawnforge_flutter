import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';

/// Ferramentas disponíveis para o Knight
enum FarmTool { hand, hoe, wateringCan }

/// Model: Armazena todo o estado e regras de negócio do Knight.
/// Não tem conhecimento da View ou Controller.
class KnightPlayerModel {
  //////////////////////////////////////////////////////////////////////////////
  // ESTADO PRINCIPAL
  //////////////////////////////////////////////////////////////////////////////
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

  //////////////////////////////////////////////////////////////////////////////
  // GETTERS
  //////////////////////////////////////////////////////////////////////////////
  double get currentStamina => _stamina;
  int get currentEnergy => _energy;
  bool get hasStamina => _stamina > 0;

  //////////////////////////////////////////////////////////////////////////////
  // STAMINA
  //////////////////////////////////////////////////////////////////////////////

  /// Verifica se pode realizar ataque melee
  bool canDoMeleeAttack() =>
      _stamina >= KnightPlayerConfig.kMeleeAttackStaminaCost;

  /// Consome stamina ao atacar melee
  void executeMeleeAttackStaminaCost() {
    _decrementStamina(KnightPlayerConfig.kMeleeAttackStaminaCost);
  }

  /// Verifica se pode realizar ataque fireball
  bool canDoFireballAttack() =>
      _stamina >= KnightPlayerConfig.kFireballAttackStaminaCost;

  /// Consome stamina ao atacar fireball
  void executeFireballAttackStaminaCost() {
    _decrementStamina(KnightPlayerConfig.kFireballAttackStaminaCost);
  }

  /// Regenera stamina gradualmente
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

  //////////////////////////////////////////////////////////////////////////////
  // ENERGIA & FERRAMENTAS
  //////////////////////////////////////////////////////////////////////////////

  /// Verifica se pode usar ferramenta
  bool canUseTool() => _energy >= KnightPlayerConfig.kToolUsageEnergyCost;

  /// Consome energia ao usar ferramenta
  void useTool() {
    if (canUseTool()) {
      _energy -= KnightPlayerConfig.kToolUsageEnergyCost;
      if (_energy < 0) _energy = 0;
    }
  }

  /// Restaura energia ao máximo
  void restoreEnergy() {
    _energy = KnightPlayerConfig.kMaxEnergy;
  }

  /// Troca a ferramenta atual
  void switchTool(FarmTool newTool) {
    currentTool = newTool;
  }

  //////////////////////////////////////////////////////////////////////////////
  // INVENTÁRIO & OUTROS ESTADOS
  //////////////////////////////////////////////////////////////////////////////

  /// Exemplo: Adiciona chave ao inventário
  void obtainKey() {
    hasKey = true;
  }

  /// Exemplo: Remove chave do inventário
  void removeKey() {
    hasKey = false;
  }
}
