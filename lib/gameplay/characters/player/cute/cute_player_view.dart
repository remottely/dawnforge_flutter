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
  SimpleDirectionAnimation getWalkAnimation() => CutePlayerConfig.walkAnimation;

  @override
  SimpleDirectionAnimation getRunAnimation() => CutePlayerConfig.runAnimation;

  @override
  Future<SpriteAnimation> getRightAttackAnimation() =>
      CutePlayerConfig.loadRightAttackAnimation();

  @override
  Future<SpriteAnimation> getLeftAttackAnimation() =>
      CutePlayerConfig.loadLeftAttackAnimation();

  @override
  Future<SpriteAnimation>? getUpAttackAnimation() =>
      CutePlayerConfig.loadUpAttackAnimation();

  @override
  Future<SpriteAnimation>? getDownAttackAnimation() =>
      CutePlayerConfig.loadDownAttackAnimation();

  @override
  Future<SpriteAnimation>? getRightUpAttackAnimation() => null;

  @override
  Future<SpriteAnimation>? getRighDownAttackAnimation() => null;

  @override
  Future<SpriteAnimation>? getLeftUpAttackAnimation() => null;

  @override
  Future<SpriteAnimation>? getLeftDownAttackAnimation() => null;

  @override
  Future<SpriteAnimation> getRightShovelAnimation() =>
      CutePlayerConfig.loadRightShovelAnimation();

  @override
  Future<SpriteAnimation> getLeftShovelAnimation() =>
      CutePlayerConfig.loadLeftShovelAnimation();

  @override
  Future<SpriteAnimation>? getUpShovelAnimation() =>
      CutePlayerConfig.loadUpShovelAnimation();

  @override
  Future<SpriteAnimation>? getDownShovelAnimation() =>
      CutePlayerConfig.loadDownShovelAnimation();

  @override
  Future<SpriteAnimation>? getRightUpShovelAnimation() => null;

  @override
  Future<SpriteAnimation>? getRighDownShovelAnimation() => null;

  @override
  Future<SpriteAnimation>? getLeftUpShovelAnimation() => null;

  @override
  Future<SpriteAnimation>? getLeftDownShovelAnimation() => null;
}
