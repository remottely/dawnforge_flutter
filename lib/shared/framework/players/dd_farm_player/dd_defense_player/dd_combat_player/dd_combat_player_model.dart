import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_mobile_player_model.dart';

abstract class DDCombatPlayerModel extends DDMobilePlayerModel {
  DDCombatPlayerModel({
    required super.maxStamina,
    required super.maxEnergy,
    super.initialStamina,
    super.initialEnergy,
    super.initialLife,
    super.initialHasKey,
  });

  int get primaryAttackStaminaCost;

  int get rangedAttackStaminaCost;

  double get primaryAttackDamage;

  double get rangedAttackDamage;

  bool get canExecutePrimaryAttack =>
      (stamina >= primaryAttackStaminaCost) &&
      (equipment == EquippedHandType.ironSword);

  bool get canExecuteRangedAttack =>
      (stamina >= rangedAttackStaminaCost) &&
      (equipment == EquippedHandType.staff);

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }
}
