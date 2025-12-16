import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class FarmerPlayerModel extends DDFarmPlayerModel {
  FarmerPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : super(
         modelConfig: FarmerPlayerConfig.modelConfig,
         initialStamina: initialStamina,
         initialEnergy: initialEnergy,
         initialLife: initialLife,
         initialHasKey: initialHasKey,
       );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'farmer';
    return json;
  }

  factory FarmerPlayerModel.fromJson(Map<String, dynamic> json) {
    final model = FarmerPlayerModel(
      initialStamina: (json['currentStamina'] as num?)?.toDouble(),
      initialEnergy: (json['currentEnergy'] as int?),
      initialLife: (json['currentLife'] as num?)?.toDouble(),
      initialHasKey: (json['hasKeyItem'] as bool?),
    );
    model.fromJson(json);
    return model;
  }
}
