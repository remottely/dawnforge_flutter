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
    bool? initialHasKey,
  }) : super(
         maxStamina: KnightPlayerConfig.kMaxStamina,
         maxEnergy: KnightPlayerConfig.kMaxEnergy,
         initialStamina: initialStamina,
         initialEnergy: initialEnergy,
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
}
