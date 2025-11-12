import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_model.dart';

/// Model for players with hybrid combat capabilities (melee + ranged).
///
/// Extends the base player model to add validation and cost management
/// for both melee and ranged attack types. This is suitable for characters
/// like Knight and Sunny who have access to multiple combat options.
abstract class DDHybridCombatPlayerModel extends DDBasePlayerModel {
  DDHybridCombatPlayerModel({
    required super.maxStamina,
    required super.maxEnergy,
    super.initialStamina,
    super.initialEnergy,
    super.initialHasKey,
  });

  // ============================================================================
  // Abstract Combat Configuration
  // ============================================================================

  /// Stamina cost to execute the primary melee attack.
  int get primaryAttackStaminaCost;

  /// Stamina cost to execute the ranged attack.
  int get rangedAttackStaminaCost;

  /// Damage dealt by the primary melee attack.
  double get primaryAttackDamage;

  /// Damage dealt by the ranged attack.
  double get rangedAttackDamage;

  // ============================================================================
  // Combat Validations
  // ============================================================================

  /// Determines if the player can execute the primary melee attack.
  bool get canExecutePrimaryAttack => stamina >= primaryAttackStaminaCost;

  /// Determines if the player can execute the ranged attack.
  bool get canExecuteRangedAttack => stamina >= rangedAttackStaminaCost;
}
