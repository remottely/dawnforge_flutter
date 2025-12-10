import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_controller.dart';

class CutePlayerController<M extends CutePlayerModel>
    extends DDFarmPlayerController<M> {
  CutePlayerController({
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
  Duration get staminaRegenDebounce => CutePlayerConfig.kStaminaRegenDebounce;
}
