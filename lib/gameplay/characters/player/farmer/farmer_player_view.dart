import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/farmer/farmer_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_view.dart';

class FarmerPlayerView<
  C extends FarmerPlayerController<M>,
  M extends FarmerPlayerModel
>
    extends DDFarmPlayerView<C, M> {
  FarmerPlayerView({required super.position, required super.model})
    : super(
        viewConfig: FarmerPlayerConfig.viewConfig,
        size: FarmerPlayerConfig.componentSize,
        life: FarmerPlayerConfig.kLife,
        baseSpeed: FarmerPlayerConfig.kSpeed,
      );

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
    required bool Function() onExecuteShovel,
    required bool Function() onExecuteWateringCan,
    required bool Function() onExecuteSeed,
    required bool Function() onExecuteHarvestBasket,
  }) {
    return FarmerPlayerController<FarmerPlayerModel>(
          model: model,
          onDisplayExclamationEmote: onDisplayExclamationEmote,
          onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
          onChangeRunState: onChangeRunState,
          onExecutePrimaryAttack: onExecutePrimaryAttack,
          onExecuteRangedAttack: onExecuteRangedAttack,
          onExecuteShovel: onExecuteShovel,
          onExecuteWateringCan: onExecuteWateringCan,
          onExecuteSeed: onExecuteSeed,
          onExecuteHarvestBasket: onExecuteHarvestBasket,
        )
        as C;
  }
}
