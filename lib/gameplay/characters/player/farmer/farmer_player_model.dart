import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class FarmerPlayerModel extends DDFarmPlayerModel {
  FarmerPlayerModel({required DDBasePlayerModelState modelState})
    : super(
        modelConfig: FarmerPlayerConfig.modelConfig,
        modelState: modelState,
      );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'farmer';
    return json;
  }

  factory FarmerPlayerModel.fromJson(Map<String, dynamic> json) {
    final model = FarmerPlayerModel(
      modelState: DDBasePlayerModelState(
        stamina: (json['currentStamina'] as num?)?.toDouble(),
        energy: (json['currentEnergy'] as int?),
        life: (json['currentLife'] as num?)?.toDouble(),
        hasKey: (json['hasKeyItem'] as bool?),
      ),
    );
    model.fromJson(json);
    return model;
  }
}
