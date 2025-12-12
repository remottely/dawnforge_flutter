import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_model.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_farm_player/dd_farm_player_view.dart';

class CutePlayerView<
  C extends CutePlayerController<M>,
  M extends CutePlayerModel
>
    extends DDFarmPlayerView<C, M> {
  CutePlayerView({required super.position, required super.model})
    : super(
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

  @override
  RectangleHitbox getHitbox() => CutePlayerConfig.hitbox;

  @override
  LightingConfig getLightingConfig() => CutePlayerConfig.lightingConfig;

  @override
  DDDecoration getDeathMarker(Vector2 position) =>
      CutePlayerConfig.createDeathMarker(position);

  @override
  SimpleDirectionAnimation getAnimationWalkDirectional() =>
      CutePlayerConfig.animationWalkDirectional;

  @override
  SimpleDirectionAnimation getAnimationRunDirectional() =>
      CutePlayerConfig.animationRunDirectional;

  @override
  Future<SpriteAnimation> getAnimationAttackRight() =>
      CutePlayerConfig.loadAnimationAttackRight();

  @override
  Future<SpriteAnimation> getAnimationAttackLeft() =>
      CutePlayerConfig.loadAnimationAttackLeft();

  @override
  Future<SpriteAnimation>? getAnimationAttackUp() =>
      CutePlayerConfig.loadAnimationAttackUp();

  @override
  Future<SpriteAnimation>? getAnimationAttackDown() =>
      CutePlayerConfig.loadAnimationAttackDown();

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
      CutePlayerConfig.loadAnimationShovelRight();

  @override
  Future<SpriteAnimation> getAnimationShovelLeft() =>
      CutePlayerConfig.loadAnimationShovelLeft();

  @override
  Future<SpriteAnimation>? getAnimationShovelUp() =>
      CutePlayerConfig.loadAnimationShovelUp();

  @override
  Future<SpriteAnimation>? getAnimationShovelDown() =>
      CutePlayerConfig.loadAnimationShovelDown();
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
      CutePlayerConfig.loadAnimationWateringCanRight();

  @override
  Future<SpriteAnimation> getAnimationWateringCanLeft() =>
      CutePlayerConfig.loadAnimationWateringCanLeft();

  @override
  Future<SpriteAnimation>? getAnimationWateringCanUp() =>
      CutePlayerConfig.loadAnimationWateringCanUp();

  @override
  Future<SpriteAnimation>? getAnimationWateringCanDown() =>
      CutePlayerConfig.loadAnimationWateringCanDown();

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
      CutePlayerConfig.loadAnimationPlaceSeedRight();

  @override
  Future<SpriteAnimation> getAnimationPlaceSeedLeft() =>
      CutePlayerConfig.loadAnimationPlaceSeedLeft();

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedUp() =>
      CutePlayerConfig.loadAnimationPlaceSeedUp();

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedDown() =>
      CutePlayerConfig.loadAnimationPlaceSeedDown();

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedRightUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedRightDown() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedLeftUp() => null;

  @override
  Future<SpriteAnimation>? getAnimationPlaceSeedLeftDown() => null;
}
