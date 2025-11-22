import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_model.dart';

/// Data model for the Sunny player character.
///
/// Extends the mobile player model to provide Sunny-specific configuration
/// values while inheriting all base player functionality including combat
/// resources, mobility state, and inventory management.
class SunnyPlayerModel extends DDFarmPlayerModel {
  SunnyPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : super(
         maxStamina: SunnyPlayerConfig.kMaxStamina,
         maxEnergy: SunnyPlayerConfig.kMaxEnergy,
         initialStamina: initialStamina,
         initialEnergy: initialEnergy,
         initialLife: initialLife,
         initialHasKey: initialHasKey,
       );

  // ============================================================================
  // Configuration Overrides
  // ============================================================================

  @override
  double get maxStamina => SunnyPlayerConfig.kMaxStamina;

  @override
  int get maxEnergy => SunnyPlayerConfig.kMaxEnergy;

  @override
  int get staminaRegenIncrement => SunnyPlayerConfig.kStaminaIncrement;

  @override
  double get longVisionRadius => SunnyPlayerConfig.kLongVisionRadius;

  @override
  int get primaryAttackStaminaCost =>
      SunnyPlayerConfig.kPrimaryAttackStaminaCost;

  @override
  int get rangedAttackStaminaCost =>
      SunnyPlayerConfig.kFireballAttackStaminaCost;

  @override
  int get diggerStaminaCost => SunnyPlayerConfig.kDiggerStaminaCost;

  @override
  double get primaryAttackDamage => SunnyPlayerConfig.kPrimaryAttackDamage;

  @override
  double get rangedAttackDamage => SunnyPlayerConfig.kFireballAttackDamage;

  @override
  double get runSpeedMultiplier => SunnyPlayerConfig.kRunSpeedMultiplier;

  // ============================================================================
  // Serialization
  // ============================================================================

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'sunny'; // Identifier for deserialization
    return json;
  }

  /// Creates a SunnyPlayerModel from JSON data.
  ///
  /// [json] The JSON map containing saved player state.
  factory SunnyPlayerModel.fromJson(Map<String, dynamic> json) {
    final model = SunnyPlayerModel(
      initialStamina: (json['currentStamina'] as num?)?.toDouble(),
      initialEnergy: (json['currentEnergy'] as int?),
      initialLife: (json['currentLife'] as num?)?.toDouble(),
      initialHasKey: (json['hasKeyItem'] as bool?),
    );
    model.fromJson(json);
    return model;
  }
}
