import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_model.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/player/dd_farm_player/dd_farm_player_view.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';

class CutePlayerView<
  C extends CutePlayerController<M>,
  M extends CutePlayerModel
>
    extends DDFarmPlayerView<C, M> {
  CutePlayerView({required super.position, required super.model})
    : super(
        config: DDFarmPlayerConfig(
          hitbox: CutePlayerConfig.hitbox,
          lighting: CutePlayerConfig.lighting,
          getDeathMarker: (position) =>
              CutePlayerConfig.createDeathMarker(position),
          animationWalkDirectional: CutePlayerConfig.animationWalkDirectional,
          animationRunDirectional: CutePlayerConfig.animationRunDirectional,
          animationAttackDirectionalFactory: DDAnimationDirectionalFactory(
            loadRight: CutePlayerConfig.loadAnimationAttackRight,
            loadLeft: CutePlayerConfig.loadAnimationAttackLeft,
            loadUp: CutePlayerConfig.loadAnimationAttackUp,
            loadDown: CutePlayerConfig.loadAnimationAttackDown,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationShovelFactory: DDAnimationDirectionalFactory(
            loadRight: CutePlayerConfig.loadAnimationShovelRight,
            loadLeft: CutePlayerConfig.loadAnimationShovelLeft,
            loadUp: CutePlayerConfig.loadAnimationShovelUp,
            loadDown: CutePlayerConfig.loadAnimationShovelDown,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationWateringCanFactory: DDAnimationDirectionalFactory(
            loadRight: CutePlayerConfig.loadAnimationWateringCanRight,
            loadLeft: CutePlayerConfig.loadAnimationWateringCanLeft,
            loadUp: CutePlayerConfig.loadAnimationWateringCanUp,
            loadDown: CutePlayerConfig.loadAnimationWateringCanDown,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationPlaceSeedFactory: DDAnimationDirectionalFactory(
            loadRight: CutePlayerConfig.loadAnimationPlaceSeedRight,
            loadLeft: CutePlayerConfig.loadAnimationPlaceSeedLeft,
            loadUp: CutePlayerConfig.loadAnimationPlaceSeedUp,
            loadDown: CutePlayerConfig.loadAnimationPlaceSeedDown,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationHarvestBasketFactory: DDAnimationDirectionalFactory(
            loadRight: CutePlayerConfig.loadAnimationHarvestBasketRight,
            loadLeft: CutePlayerConfig.loadAnimationHarvestBasketLeft,
            loadUp: CutePlayerConfig.loadAnimationHarvestBasketUp,
            loadDown: CutePlayerConfig.loadAnimationHarvestBasketDown,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
        ),
        size: CutePlayerConfig.componentSize,
        life: CutePlayerConfig.kLife,
        speed: CutePlayerConfig.kSpeed,
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
    return CutePlayerController<CutePlayerModel>(
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
