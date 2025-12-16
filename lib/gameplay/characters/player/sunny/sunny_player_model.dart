import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class SunnyPlayerModel extends DDFarmPlayerModel {
  SunnyPlayerModel({required DDBasePlayerModelState modelState})
    : super(modelConfig: SunnyPlayerConfig.modelConfig, modelState: modelState);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'sunny';
    return json;
  }

  factory SunnyPlayerModel.fromJson(Map<String, dynamic> json) {
    final model = SunnyPlayerModel(
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
