import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class CutePlayerModel extends DDFarmPlayerModel {
  CutePlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : super(
         maxStamina: CutePlayerConfig.kMaxStamina,
         maxEnergy: CutePlayerConfig.kMaxEnergy,
         initialStamina: initialStamina,
         initialEnergy: initialEnergy,
         initialLife: initialLife,
         initialHasKey: initialHasKey,
       );

  @override
  double get maxStamina => CutePlayerConfig.kMaxStamina;

  @override
  int get maxEnergy => CutePlayerConfig.kMaxEnergy;

  @override
  int get staminaRegenIncrement => CutePlayerConfig.kStaminaIncrement;

  @override
  double get longVisionRadius => CutePlayerConfig.kLongVisionRadius;

  @override
  int get primaryAttackStaminaCost =>
      CutePlayerConfig.kPrimaryAttackStaminaCost;

  @override
  int get rangedAttackStaminaCost =>
      CutePlayerConfig.kFireballAttackStaminaCost;

  @override
  int get shovelStaminaCost => CutePlayerConfig.kShovelStaminaCost;

  @override
  int get wateringCanStaminaCost => CutePlayerConfig.kWateringCanStaminaCost;

  @override
  int get seedStaminaCost => CutePlayerConfig.kSeedStaminaCost;

  @override
  int get harvestBasketStaminaCost =>
      CutePlayerConfig.kHarvestBasketStaminaCost;

  @override
  double get primaryAttackDamage => CutePlayerConfig.kPrimaryAttackDamage;

  @override
  double get rangedAttackDamage => CutePlayerConfig.kFireballAttackDamage;

  @override
  double get runSpeedMultiplier => CutePlayerConfig.kRunSpeedMultiplier;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['playerType'] = 'cute';
    return json;
  }

  factory CutePlayerModel.fromJson(Map<String, dynamic> json) {
    final model = CutePlayerModel(
      initialStamina: (json['currentStamina'] as num?)?.toDouble(),
      initialEnergy: (json['currentEnergy'] as int?),
      initialLife: (json['currentLife'] as num?)?.toDouble(),
      initialHasKey: (json['hasKeyItem'] as bool?),
    );
    model.fromJson(json);
    return model;
  }
}
