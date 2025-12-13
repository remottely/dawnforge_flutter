import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class SunnyPlayerModel extends DDFarmPlayerModel {
  SunnyPlayerModel({
    double? initialStamina,
    int? initialEnergy,
    double? initialLife,
    bool? initialHasKey,
  }) : super(
         maxStamina: SunnyPlayerConfig.kMaxStamina,
         maxEnergy: SunnyPlayerConfig.kMaxEnergy,
         initialStamina: initialStamina,
         initialEnergy: initialEnergy,
         initialLife: initialLife,
         initialHasKey: initialHasKey,
       );

  @override
  double get maxStamina => SunnyPlayerConfig.kMaxStamina;

  @override
  int get maxEnergy => SunnyPlayerConfig.kMaxEnergy;

  @override
  int get staminaRegenIncrement => SunnyPlayerConfig.kStaminaIncrement;

  @override
  double get longVisionRadius => SunnyPlayerConfig.kLongVisionRadius;

  @override
  int get primaryAttackStaminaCost =>
      SunnyPlayerConfig.kPrimaryAttackStaminaCost;

  @override
  int get rangedAttackStaminaCost =>
      SunnyPlayerConfig.kFireballAttackStaminaCost;

  @override
  int get shovelStaminaCost => SunnyPlayerConfig.kShovelStaminaCost;

  @override
  int get wateringCanStaminaCost => SunnyPlayerConfig.kWateringCanStaminaCost;

  @override
  int get seedStaminaCost => SunnyPlayerConfig.kSeedStaminaCost;

  @override
  int get harvestBasketStaminaCost =>
      SunnyPlayerConfig.kHarvestBasketStaminaCost;

  @override
  double get primaryAttackDamage => SunnyPlayerConfig.kPrimaryAttackDamage;

  @override
  double get rangedAttackDamage => SunnyPlayerConfig.kFireballAttackDamage;

  @override
  double get runSpeedMultiplier => SunnyPlayerConfig.kRunSpeedMultiplier;

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
