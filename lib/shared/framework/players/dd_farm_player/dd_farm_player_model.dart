import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_model.dart';

abstract class DDFarmPlayerModel extends DDCombatPlayerModel {
  DDFarmPlayerModel({
    required super.maxStamina,
    required super.maxEnergy,
    super.initialStamina,
    super.initialEnergy,
    super.initialLife,
    super.initialHasKey,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    return json;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
  }
}
