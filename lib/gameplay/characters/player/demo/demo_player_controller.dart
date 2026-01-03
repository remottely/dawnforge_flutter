import 'package:darkness_dungeon/gameplay/characters/player/demo/demo_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_controller.dart';

class DemoPlayerController<M extends DemoPlayerModel>
    extends DDFarmPlayerController<M> {
  DemoPlayerController({
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
