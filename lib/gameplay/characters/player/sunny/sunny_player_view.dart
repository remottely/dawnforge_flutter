import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_view.dart';

class SunnyPlayerView<
  C extends SunnyPlayerController<M>,
  M extends SunnyPlayerModel
>
    extends DDFarmPlayerView<C, M> {
  SunnyPlayerView({required super.position, required super.model})
    : super(
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

  @override
  SimpleDirectionAnimation getAnimationWalkDirectional() =>
      SunnyPlayerConfig.animationWalkDirectional;

  @override
  SimpleDirectionAnimation getAnimationRunDirectional() =>
      SunnyPlayerConfig.animationRunDirectional;

  @override
  Future<SpriteAnimation> getAnimationAttackRight() =>
      SunnyPlayerConfig.loadAnimationAttackRight();

  @override
  Future<SpriteAnimation> getAnimationAttackLeft() =>
      SunnyPlayerConfig.loadAnimationAttackLeft();

  @override
  Future<SpriteAnimation>? getAnimationAttackUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationAttackDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationAttackRightUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationAttackRightDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationAttackLeftUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationAttackLeftDown() => null;

  @override
  Future<SpriteAnimation> getAnimationShovelRight() =>
      SunnyPlayerConfig.loadAnimationShovelRight();

  @override
  Future<SpriteAnimation> getAnimationShovelLeft() =>
      SunnyPlayerConfig.loadAnimationShovelLeft();

  @override
  Future<SpriteAnimation>? getAnimationShovelUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationShovelDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationShovelRightUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationShovelRightDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationShovelLeftUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationShovelLeftDown() => null;

  @override
  Future<SpriteAnimation> getAnimationWateringCanRight() =>
      SunnyPlayerConfig.loadAnimationWateringCanRight();

  @override
  Future<SpriteAnimation> getAnimationWateringCanLeft() =>
      SunnyPlayerConfig.loadAnimationWateringCanLeft();

  @override
  Future<SpriteAnimation>? getAnimationWateringCanUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationWateringCanDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationWateringCanRightUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationWateringCanRightDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationWateringCanLeftUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationWateringCanLeftDown() => null;

  @override
  Future<SpriteAnimation> getAnimationPlaceSeedRight() =>
      SunnyPlayerConfig.loadAnimationPlaceSeedRight();

  @override
  Future<SpriteAnimation> getAnimationPlaceSeedLeft() =>
      SunnyPlayerConfig.loadAnimationPlaceSeedLeft();

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedRightUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedRightDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedLeftUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedLeftDown() => null;
}
