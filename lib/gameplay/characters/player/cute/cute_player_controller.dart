import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';

class CutePlayerController<M extends CutePlayerModel>
    extends DDFarmPlayerController<M> {
  CutePlayerController({
    required super.model,
    required super.onChangeRunState,
    required super.onExecuteShovel,
    required super.onExecuteWateringCan,
    required super.onExecuteSeed,
    required super.onExecuteHarvest,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });
}
