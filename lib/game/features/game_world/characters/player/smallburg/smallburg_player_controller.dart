import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';
import 'package:dawnforge/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';

class SmallburgPlayerController<M extends DDFarmPlayerModel>
    extends DDFarmPlayerController<M> {
  SmallburgPlayerController({
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