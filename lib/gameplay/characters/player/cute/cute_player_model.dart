import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class CutePlayerModel extends DDFarmPlayerModel {
  CutePlayerModel({required DDBasePlayerModelState modelState})
    : super(modelConfig: CutePlayerConfig.modelConfig, modelState: modelState);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'cute';
    return json;
  }

  factory CutePlayerModel.fromJson(Map<String, dynamic> json) {
    final model = CutePlayerModel(
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
