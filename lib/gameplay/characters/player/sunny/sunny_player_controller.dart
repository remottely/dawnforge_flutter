
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class SunnyPlayerController<M extends DDFarmPlayerModel>
    extends DDFarmPlayerController<M> {
  SunnyPlayerController({
    required super.model,
    required super.onChangeRunState,
    required super.onExecuteDig,
    required super.onExecuteWateringCan,
    required super.onExecuteSeed,
    required super.onExecuteHarvest,
    required super.onExecutePrimaryAttack,
    required super.onExecuteRangedAttack,
    required super.onDisplayExclamationEmote,
    required super.onDetectEnemyInLongVisionRadius,
  });
}
