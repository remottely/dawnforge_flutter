/// Abstract base model for all player characters.
///
/// Defines the core data structure and resource management system shared
/// across all player character types. This model encapsulates combat resources,
/// utility resources, inventory state, and environmental awareness.
///
/// Subclasses should extend this to add character-specific state while
/// maintaining compatibility with the base player system.
abstract class DDBasePlayerModel {
  double _currentStamina;
  int _currentEnergy;
  bool _hasKeyItem;
  bool _isObservingEnemies;

  /// Creates a base player model with configurable initial state.
  ///
  /// [maxStamina] The maximum stamina capacity for this character.
  /// [maxEnergy] The maximum energy capacity for this character.
  /// [initialStamina] Starting stamina value. Defaults to maximum if not provided.
  /// [initialEnergy] Starting energy value. Defaults to maximum if not provided.
  /// [initialHasKey] Whether the player starts with the key item.
  DDBasePlayerModel({
    required double maxStamina,
    required int maxEnergy,
    double? initialStamina,
    int? initialEnergy,
    bool? initialHasKey,
  }) : _currentStamina = initialStamina ?? maxStamina,
       _currentEnergy = initialEnergy ?? maxEnergy,
       _hasKeyItem = initialHasKey ?? false,
       _isObservingEnemies = false;

  // ============================================================================
  // Abstract Configuration Properties
  // ============================================================================

  /// Maximum stamina capacity for this character type.
  double get maxStamina;

  /// Maximum energy capacity for this character type.
  int get maxEnergy;

  /// Stamina regeneration amount per tick.
  int get staminaRegenIncrement;

  /// Vision radius for enemy detection.
  double get visionRadius;

  // ============================================================================
  // Resource Accessors
  // ============================================================================

  /// Current stamina value used for combat actions.
  double get stamina => _currentStamina;

  /// Current energy value used for utility actions.
  int get energy => _currentEnergy;

  /// Whether the player possesses the key item.
  bool get hasKey => _hasKeyItem;

  /// Whether the player is currently observing enemy entities.
  bool get isObservingEnemy => _isObservingEnemies;

  /// Updates the enemy observation state.
  set isObservingEnemy(bool value) => _isObservingEnemies = value;

  // ============================================================================
  // Resource Validations
  // ============================================================================

  /// Indicates whether the player has any stamina remaining.
  bool get hasStamina => _currentStamina > 0;

  // ============================================================================
  // Resource Management
  // ============================================================================

  /// Consumes stamina for action execution.
  ///
  /// [amount] The amount of stamina to consume.
  void consumeStamina(int amount) {
    _currentStamina = (_currentStamina - amount).clamp(0, maxStamina);
  }

  /// Regenerates stamina by the configured increment amount.
  void regenerateStamina() {
    _currentStamina = (_currentStamina + staminaRegenIncrement).clamp(
      0,
      maxStamina,
    );
  }

  /// Consumes energy for utility action execution.
  ///
  /// [amount] The amount of energy to consume.
  void consumeEnergy(int amount) {
    _currentEnergy = (_currentEnergy - amount).clamp(0, maxEnergy);
  }

  /// Restores energy to maximum value.
  void restoreEnergy() {
    _currentEnergy = maxEnergy;
  }

  // ============================================================================
  // Inventory Management
  // ============================================================================

  /// Adds the key item to the player's inventory.
  void obtainKey() => _hasKeyItem = true;

  /// Removes the key item from the player's inventory.
  void removeKey() => _hasKeyItem = false;
}
