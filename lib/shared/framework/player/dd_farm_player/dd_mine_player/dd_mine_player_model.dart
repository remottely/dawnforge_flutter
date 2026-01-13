import 'package:dawnforge/gameplay/inventory/entities/enums/hand_item_id.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_consumable_player/dd_defense_player/dd_combat_player/dd_mobile_player/dd_base_player/dd_base_player_config.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_mine_player/dd_mine_player_config.dart';
import 'package:flutter/foundation.dart';

class DDMinePlayerModel extends DDFarmPlayerModel {
  @override
  final DDMinePlayerModelConfig config;

  @protected
  DDMinePlayerModel.internal({required this.config, required super.saveData})
    : super.internal(config: config);

  bool get canExecuteMine =>
      (stamina >= config.mineStaminaCost) && _isPickaxeEquipped;

  bool get _isPickaxeEquipped =>
      equipment == HandItemId.iron_pickaxe ||
      equipment == HandItemId.steel_pickaxe;

  @override
  Map<String, dynamic> toJson() => super.toJson();

  @protected
  factory DDMinePlayerModel.fromJson(
    Map<String, dynamic> json,
    DDMinePlayerModelConfig config,
  ) {
    final baseData = DDBasePlayerSaveData.fromJson(json, config);

    return DDMinePlayerModel.internal(config: config, saveData: baseData);
  }
}
