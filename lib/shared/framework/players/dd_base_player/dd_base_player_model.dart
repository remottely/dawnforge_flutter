import 'package:darkness_dungeon/gameplay/inventory/models/weapon_type.dart';

/// Abstract base model for all player characters.
///
/// Defines the core data structure and resource management system shared
/// across all player character types. This model encapsulates combat resources,
/// utility resources, inventory state, and environmental awareness.
///
/// Subclasses should extend this to add character-specific state while
/// maintaining compatibility with the base player system.

/// Equipment types carried by players.
// enum Equipment { digger, sword, axe, staff }

abstract class DDBasePlayerModel {
  double _currentStamina;
  int _currentEnergy;
  double? _currentLife;
  bool _hasKeyItem;
  bool _isObservingEnemies;
  WeaponType _equipment = WeaponType.digger;

  /// Creates a base player model with configurable initial state.
  ///
  /// [maxStamina] The maximum stamina capacity for this character.
  /// [maxEnergy] The maximum energy capacity for this character.
  /// [initialStamina] Starting stamina value. Defaults to maximum if not provided.
  /// [initialEnergy] Starting energy value. Defaults to maximum if not provided.
  /// [initialLife] Starting life value. If null, uses default from character config.
  /// [initialHasKey] Whether the player starts with the key item.
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
  double get longVisionRadius;

  // ============================================================================
  // Resource Accessors
  // ============================================================================

  /// Current stamina value used for combat actions.
  double get stamina => _currentStamina;

  /// Current energy value used for utility actions.
  int get energy => _currentEnergy;

  /// Current life value. Returns null if not set (uses default from config).
  double? get life => _currentLife;

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

  WeaponType get equipment => _equipment;
  void setEquipment(WeaponType value) => _equipment = value;

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

  /// Updates the current life value.
  ///
  /// [value] The new life value to store.
  void updateLife(double value) {
    _currentLife = value;
  }

  // ============================================================================
  // Inventory Management
  // ============================================================================

  /// Adds the key item to the player's inventory.
  void obtainKey() => _hasKeyItem = true;

  /// Removes the key item from the player's inventory.
  void removeKey() => _hasKeyItem = false;

  // ============================================================================
  // Serialization
  // ============================================================================

  /// Serializes the player model to JSON for persistence.
  ///
  /// Returns a map containing all persistent state that should be saved.
  /// Subclasses should override this and call super.toJson() to include
  /// their own additional fields.
  Map<String, dynamic> toJson() {
    return {
      'currentStamina': _currentStamina,
      'currentEnergy': _currentEnergy,
      'currentLife': _currentLife,
      'hasKeyItem': _hasKeyItem,
      'isObservingEnemies': _isObservingEnemies,
      'equipment': _equipment.name,
    };
  }

  /// Deserializes player state from JSON.
  ///
  /// Applies saved state to this model instance. Should be called after
  /// construction to restore saved state.
  ///
  /// [json] The JSON map containing saved player state.
  void fromJson(Map<String, dynamic> json) {
    _currentStamina =
        (json['currentStamina'] as num?)?.toDouble() ?? maxStamina;
    _currentEnergy = (json['currentEnergy'] as int?) ?? maxEnergy;
    _currentLife = (json['currentLife'] as num?)?.toDouble();
    _hasKeyItem = (json['hasKeyItem'] as bool?) ?? false;
    _isObservingEnemies = (json['isObservingEnemies'] as bool?) ?? false;
    _equipment = WeaponType.values.byName(
      (json['equipment'] as String?) ?? WeaponType.digger.name,
    );
  }
}
