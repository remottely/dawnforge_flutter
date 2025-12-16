import 'package:darkness_dungeon/gameplay/inventory/models/equipped_hand_type.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_defense_player/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';

class DDFarmPlayerModel extends DDCombatPlayerModel {
  final DDFarmPlayerModelConfig modelConfig;

  DDFarmPlayerModel({required this.modelConfig, required super.modelState})
    : super(modelConfig: modelConfig);

  bool get canExecuteWateringCan =>
      (stamina >= modelConfig.wateringCanStaminaCost) &&
      (equipment == EquippedHandType.wateringCan);

  bool get canExecuteShovel =>
      (stamina >= modelConfig.shovelStaminaCost) &&
      (equipment == EquippedHandType.shovel);

  bool get canExecuteSeed =>
      (stamina >= modelConfig.seedStaminaCost) &&
      (equipment == EquippedHandType.strawberry);

  bool get canExecuteHarvestBasket =>
      (stamina >= modelConfig.harvestBasketStaminaCost) &&
      (equipment == EquippedHandType.harvestBasket);

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
