import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_config.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_view.dart';

class SunnyPlayerView<
  C extends SunnyPlayerController<M>,
  M extends SunnyPlayerModel
>
    extends DDFarmPlayerView<C, M> {
  SunnyPlayerView({required super.position, required super.model})
    : super(
        config: DDFarmPlayerConfig(
          animationWalkDirectional: SunnyPlayerConfig.animationWalkDirectional,
          animationRunDirectional: SunnyPlayerConfig.animationRunDirectional,
          animationAttackDirectionalFactory: DDAnimationDirectionalFactory(
            loadRight: SunnyPlayerConfig.loadAnimationAttackRight,
            loadLeft: SunnyPlayerConfig.loadAnimationAttackLeft,
            loadUp: null,
            loadDown: null,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationShovelFactory: DDAnimationDirectionalFactory(
            loadRight: SunnyPlayerConfig.loadAnimationShovelRight,
            loadLeft: SunnyPlayerConfig.loadAnimationShovelLeft,
            loadUp: null,
            loadDown: null,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationWateringCanFactory: DDAnimationDirectionalFactory(
            loadRight: SunnyPlayerConfig.loadAnimationWateringCanRight,
            loadLeft: SunnyPlayerConfig.loadAnimationWateringCanLeft,
            loadUp: null,
            loadDown: null,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationPlaceSeedFactory: DDAnimationDirectionalFactory(
            loadRight: SunnyPlayerConfig.loadAnimationPlaceSeedRight,
            loadLeft: SunnyPlayerConfig.loadAnimationPlaceSeedLeft,
            loadUp: null,
            loadDown: null,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
          animationHarvestBasketFactory: DDAnimationDirectionalFactory(
            loadRight: SunnyPlayerConfig.loadAnimationHarvestBasketRight,
            loadLeft: SunnyPlayerConfig.loadAnimationHarvestBasketLeft,
            loadUp: null,
            loadDown: null,
            loadRightUp: null,
            loadRightDown: null,
            loadLeftUp: null,
            loadLeftDown: null,
          ),
        ),
        size: SunnyPlayerConfig.componentSize,
        life: SunnyPlayerConfig.kLife,
        speed: SunnyPlayerConfig.kSpeed,
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
    return SunnyPlayerController<SunnyPlayerModel>(
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

  @override
  RectangleHitbox getHitbox() => SunnyPlayerConfig.hitbox;

  @override
  LightingConfig getLightingConfig() => SunnyPlayerConfig.lightingConfig;

  @override
  DDDecoration getDeathMarker(Vector2 position) =>
      SunnyPlayerConfig.createDeathMarker(position);
}
