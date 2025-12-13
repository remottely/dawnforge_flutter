import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class SunnyPlayerModel extends DDFarmPlayerModel {
  SunnyPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : super(
         modelConfig: SunnyPlayerConfig.modelConfig,
         initialStamina: initialStamina,
         initialEnergy: initialEnergy,
         initialLife: initialLife,
         initialHasKey: initialHasKey,
       );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'sunny';
    return json;
  }

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
