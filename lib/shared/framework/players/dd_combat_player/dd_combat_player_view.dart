import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_action_sprite_animation_helper.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/controllers/player_combat_action_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_controller.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec_config.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_controller.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_combat_player/dd_combat_player_model.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_mobile_player/dd_mobile_player_view.dart';

abstract class DDCombatPlayerView<
  C extends DDCombatPlayerController<M>,
  M extends DDCombatPlayerModel
>
    extends DDMobilePlayerView<C, M> {
  DDCombatPlayerView({
    required super.position,
    required super.model,
    required super.size,
    required super.life,
    required super.speed,
  });

  late final SynchronizedAttackController meleeAttackController;
  late final SynchronizedAttackController rangedAttackController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeCombatSystems();
  }

  @override
  void onRemove() {
    meleeAttackController.dispose();
    rangedAttackController.dispose();
    super.onRemove();
  }

  void _initializeCombatSystems() {
    meleeAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
    rangedAttackController = SynchronizedAttackController(
      spec: SynchronizedAttackSpecConfig.standard,
    );
  }

  Future<SpriteAnimation> getRightAttackAnimation();
  Future<SpriteAnimation> getLeftAttackAnimation();
  Future<SpriteAnimation>? getUpAttackAnimation();
  Future<SpriteAnimation>? getDownAttackAnimation();
  Future<SpriteAnimation>? getRightUpAttackAnimation();
  Future<SpriteAnimation>? getRighDownAttackAnimation();
  Future<SpriteAnimation>? getLeftUpAttackAnimation();
  Future<SpriteAnimation>? getLeftDownAttackAnimation();

  @override
  C createMobileController({
    required M model,
    required void Function() onDisplayExclamationEmote,
    required void Function({
      required double longVisionRadius,
      required void Function() notObserved,
      required void Function(List<Enemy> enemies) observed,
    })
    onDetectEnemyInLongVisionRadius,
    required void Function(bool isRunning) onChangeRunState,
  }) {
    return createCombatController(
      model: model,
      onDisplayExclamationEmote: onDisplayExclamationEmote,
      onDetectEnemyInLongVisionRadius: onDetectEnemyInLongVisionRadius,
      onChangeRunState: onChangeRunState,
      onExecutePrimaryAttack: _onExecutePrimaryAttack,
      onExecuteRangedAttack: _onExecuteRangedAttack,
    );
  }

  C createCombatController({
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
  });

  bool _onExecutePrimaryAttack(double damage) {
    final AttackExecutionInfo? executionInfo = meleeAttackController.execute(
      AttackType.melee,
      () {
        CharacterActionSpriteAnimationHelper.playOnceExecutionEquipment(
          animationRight: getRightAttackAnimation(),
          animationLeft: getLeftAttackAnimation(),
          animationUp: getUpAttackAnimation(),
          animationDown: getDownAttackAnimation(),
          animationRightUp: getRightUpAttackAnimation(),
          animationRightDown: getRighDownAttackAnimation(),
          animationLeftUp: getLeftUpAttackAnimation(),
          animationLeftDown: getLeftDownAttackAnimation(),
          currentAnimation: animation,
          target: this,
          executionStartFrame: 1,
          onActionStart: lockAction,
          onActionEnd: unlockAction,
          onExecutionFrames: () {
            PlayerCombatActionController.executePrimaryAttack(
              player: this,
              damage: damage,
            );
          },
        );
      },
    );

    return executionInfo != null;
  }

  bool _onExecuteRangedAttack(double damage) {
    final AttackExecutionInfo? executionInfo = rangedAttackController.execute(
      AttackType.ranged,
      () => PlayerCombatActionController.executeFireballAttack(
        player: this,
        damage: damage,
      ),
    );

    return executionInfo != null;
  }
}
