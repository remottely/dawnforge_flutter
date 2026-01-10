import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/demo/demo_player_def.dart';
import 'package:darkness_dungeon/gameplay/characters/player/demo/demo_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_view.dart';

class DemoPlayerView<
  C extends DemoPlayerController<M>,
  M extends DDFarmPlayerModel
>
    extends DDFarmPlayerView<C, M> {
  DemoPlayerView({required super.position, required super.model})
    : super(config: DemoPlayerDef.viewConfig);

  @override
  C createFarmController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
    required void Function(bool isRunning) onChangeRunState,
    required bool Function(double damage) onExecutePrimaryAttack,
    required bool Function(double damage) onExecuteRangedAttack,
    required bool Function() onExecuteDig,
    required bool Function() onExecuteWateringCan,
    required bool Function() onExecuteSeed,
    required bool Function() onExecuteHarvest,
  }) {
    return DemoPlayerController<DDFarmPlayerModel>(
          model: model,
          onDisplayExclamationEmote: onDisplayExclamationEmote,
          onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
          onChangeRunState: onChangeRunState,
          onExecutePrimaryAttack: onExecutePrimaryAttack,
          onExecuteRangedAttack: onExecuteRangedAttack,
          onExecuteDig: onExecuteDig,
          onExecuteWateringCan: onExecuteWateringCan,
          onExecuteSeed: onExecuteSeed,
          onExecuteHarvest: onExecuteHarvest,
        )
        as C;
  }
}
