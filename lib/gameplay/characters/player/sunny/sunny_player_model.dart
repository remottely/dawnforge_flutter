import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';

/// Represents the available farming tools in the game.
///
/// Each tool has distinct gameplay mechanics and energy costs associated
/// with their usage.
enum FarmTool {
  /// Default tool - no special abilities, used for basic interactions.
  hand,

  /// Tilling tool - used for preparing soil for planting.
  hoe,

  /// Irrigation tool - used for watering crops.
  wateringCan,
}

/// Data model for the Sunny player character.
///
/// This model encapsulates all player state including combat resources (stamina),
/// farming resources (energy), equipment, and environmental awareness. It follows
/// the MVC pattern as the Model layer, containing pure data and business logic
/// validations without any presentation concerns.
///
/// Key responsibilities:
/// - Managing stamina for combat actions
/// - Managing energy for farming actions
/// - Tracking equipped tool and inventory items
/// - Validating action feasibility based on resources
class SunnyPlayerModel {
  double _currentStamina;
  int _currentEnergy;
  FarmTool _equippedTool;
  bool _hasKeyItem;
  bool _isObservingEnemies;

  /// Creates a player model with optional initial state values.
  ///
  /// All parameters default to safe initial values if not provided:
  /// - Stamina defaults to maximum
  /// - Energy defaults to maximum
  /// - Tool defaults to hand
  /// - Key possession defaults to false
  ///
  /// [initialStamina] Starting stamina value.
  /// [initialEnergy] Starting energy value.
  /// [initialTool] Initially equipped tool.
  /// [initialHasKey] Whether the player starts with the key.
  SunnyPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    FarmTool? initialTool,
    bool? initialHasKey,
  }) : _currentStamina = initialStamina ?? SunnyPlayerConfig.kMaxStamina,
       _currentEnergy = initialEnergy ?? SunnyPlayerConfig.kMaxEnergy,
       _equippedTool = initialTool ?? FarmTool.hand,
       _hasKeyItem = initialHasKey ?? false,
       _isObservingEnemies = false;

  // ============================================================================
  // Public Accessors
  // ============================================================================

  /// Current stamina value used for combat actions.
  ///
  /// Stamina is consumed by attacks and regenerates over time.
  double get stamina => _currentStamina;

  /// Current energy value used for farming and tool actions.
  ///
  /// Energy is consumed by tool usage and typically restored at rest points.
  int get energy => _currentEnergy;

  /// The currently equipped farming tool.
  FarmTool get currentTool => _equippedTool;

  /// Whether the player possesses the key item.
  ///
  /// Used for accessing locked areas or triggering story progression.
  bool get hasKey => _hasKeyItem;

  /// Whether the player is currently observing enemy entities.
  ///
  /// Used for triggering alert states and UI indicators.
  bool get isObservingEnemy => _isObservingEnemies;

  // ============================================================================
  // Business Logic Validations
  // ============================================================================

  /// Indicates whether the player has any stamina remaining.
  ///
  /// Returns `true` if stamina is greater than zero.
  bool get hasStamina => _currentStamina > 0;

  /// Determines if the player can execute the primary melee attack.
  ///
  /// Validates that sufficient stamina is available for the action cost.
  ///
  /// Returns `true` if the attack can be performed.
  bool get canExecutePrimaryAttack =>
      _currentStamina >= SunnyPlayerConfig.kPrimaryAttackStaminaCost;

  /// Determines if the player can execute the fireball ranged attack.
  ///
  /// Validates that sufficient stamina is available for the action cost.
  ///
  /// Returns `true` if the attack can be performed.
  bool get canExecuteFireballAttack =>
      _currentStamina >= SunnyPlayerConfig.kFireballAttackStaminaCost;

  /// Determines if the player can execute a tool action.
  ///
  /// Validates that sufficient energy is available for the action cost.
  ///
  /// Returns `true` if the tool can be used.
  bool get canExecuteToolAction =>
      _currentEnergy >= SunnyPlayerConfig.kToolActionEnergyCost;

  // ============================================================================
  // State Mutations - Resource Management
  // ============================================================================

  /// Consumes stamina for action execution.
  ///
  /// The resulting stamina value is clamped between 0 and maximum to prevent
  /// invalid states from arithmetic overflow or underflow.
  ///
  /// [amount] The amount of stamina to consume.
  void consumeStamina(int amount) {
    _currentStamina = (_currentStamina - amount).clamp(
      0,
      SunnyPlayerConfig.kMaxStamina,
    );
  }

  /// Regenerates stamina by the configured increment amount.
  ///
  /// Called periodically to restore stamina over time. The resulting value
  /// is clamped to prevent exceeding maximum stamina.
  void regenerateStamina() {
    _currentStamina = (_currentStamina + SunnyPlayerConfig.kStaminaIncrement)
        .clamp(0, SunnyPlayerConfig.kMaxStamina);
  }

  /// Consumes energy for tool action execution.
  ///
  /// The resulting energy value is clamped between 0 and maximum to prevent
  /// invalid states.
  ///
  /// [amount] The amount of energy to consume.
  void consumeEnergy(int amount) {
    _currentEnergy = (_currentEnergy - amount).clamp(
      0,
      SunnyPlayerConfig.kMaxEnergy,
    );
  }

  /// Restores energy to maximum value.
  ///
  /// Typically called when resting at designated recovery points or
  /// consuming energy restoration items.
  void restoreEnergy() {
    _currentEnergy = SunnyPlayerConfig.kMaxEnergy;
  }

  // ============================================================================
  // State Mutations - Equipment & Inventory
  // ============================================================================

  /// Switches the currently equipped tool.
  ///
  /// This does not validate tool availability or ownership - such checks
  /// should be performed at the controller or inventory system level.
  ///
  /// [newTool] The tool to equip.
  void switchTool(FarmTool newTool) => _equippedTool = newTool;

  /// Adds the key item to the player's inventory.
  ///
  /// Idempotent operation - safe to call multiple times.
  void obtainKey() => _hasKeyItem = true;

  /// Removes the key item from the player's inventory.
  ///
  /// Typically used when the key is consumed by unlocking a door or chest.
  void removeKey() => _hasKeyItem = false;

  // ============================================================================
  // State Mutations - Environmental Awareness
  // ============================================================================

  /// Updates the enemy observation state.
  ///
  /// [value] The new observation state.
  set isObservingEnemy(bool value) => _isObservingEnemies = value;
}
