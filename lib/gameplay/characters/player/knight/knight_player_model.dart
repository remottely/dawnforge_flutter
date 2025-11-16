import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_hybrid_combat_player/dd_hybrid_combat_player_model.dart';

/// Data model for the Knight player character.
///
/// Extends the hybrid combat player model (without mobility enhancements)
/// to provide Knight-specific configuration values while inheriting all
/// base player functionality including combat resources and inventory management.
///
/// Note: Knight does not have run mechanics, so uses the base hybrid combat
/// model rather than the mobile player model.
class KnightPlayerModel extends DDHybridCombatPlayerModel {
  KnightPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : super(
         maxStamina: KnightPlayerConfig.kMaxStamina,
         maxEnergy: KnightPlayerConfig.kMaxEnergy,
         initialStamina: initialStamina,
         initialEnergy: initialEnergy,
         initialLife: initialLife,
         initialHasKey: initialHasKey,
       );

  // ============================================================================
  // Configuration Overrides
  // ============================================================================

  @override
  double get maxStamina => KnightPlayerConfig.kMaxStamina;

  @override
  int get maxEnergy => KnightPlayerConfig.kMaxEnergy;

  @override
  int get staminaRegenIncrement => KnightPlayerConfig.kStaminaIncrement;

  @override
  double get visionRadius => KnightPlayerConfig.kVisionRadius;

  @override
  int get primaryAttackStaminaCost =>
      KnightPlayerConfig.kPrimaryAttackStaminaCost;

  @override
  int get rangedAttackStaminaCost =>
      KnightPlayerConfig.kFireballAttackStaminaCost;

  @override
  double get primaryAttackDamage => KnightPlayerConfig.kPrimaryAttackDamage;

  @override
  double get rangedAttackDamage => KnightPlayerConfig.kFireballAttackDamage;

  // ============================================================================
  // Serialization
  // ============================================================================

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'knight'; // Identifier for deserialization
    return json;
  }

  /// Creates a KnightPlayerModel from JSON data.
  ///
  /// [json] The JSON map containing saved player state.
  factory KnightPlayerModel.fromJson(Map<String, dynamic> json) {
    final model = KnightPlayerModel(
      initialStamina: (json['currentStamina'] as num?)?.toDouble(),
      initialEnergy: (json['currentEnergy'] as int?),
      initialLife: (json['currentLife'] as num?)?.toDouble(),
      initialHasKey: (json['hasKeyItem'] as bool?),
    );
    model.fromJson(json);
    return model;
  }
}
