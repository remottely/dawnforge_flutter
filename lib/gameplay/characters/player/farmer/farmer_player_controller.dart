import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';

class FarmerPlayerController<M extends FarmerPlayerModel>
    extends DDFarmPlayerController<M> {
  FarmerPlayerController({
    required super.model,
    required super.onChangeRunState,
    required super.onExecuteShovel,
    required super.onExecuteWateringCan,
    required super.onExecuteSeed,
    required super.onExecuteHarvestBasket,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });

  @override
  Duration get staminaRegenDebounce => FarmerPlayerConfig.kStaminaRegenDebounce; // TODO(Kevin): now
}
