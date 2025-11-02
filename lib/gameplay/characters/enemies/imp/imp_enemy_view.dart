import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

class ImpEnemyView extends DDBaseEnemy<ImpEnemyController, ImpEnemyModel> {
  ImpEnemyView(Vector2 position)
    : super(
        animation: ImpEnemyConfig.fLoadDirectionalSpriteAnimation,
        position: position,
        size: ImpEnemyConfig.fComponentSize,
        speed: ImpEnemyConfig.kSpeed,
        life: ImpEnemyConfig.kLife,
      );

  @override
  ImpEnemyModel createModel() => ImpEnemyModel();

  @override
  ImpEnemyController createController(ImpEnemyModel model) {
    return ImpEnemyController(
      model: model,
      onSeeAndMoveToPlayer: _onSeeAndMoveToPlayer,
    );
  }

  @override
  RectangleHitbox createHitbox() => ImpEnemyConfig.createHitbox();

  /// Controller callback implementations
  void _onSeeAndMoveToPlayer({
    required double radiusVision,
    required void Function(Player) closePlayer,
  }) {
    seeAndMoveToPlayer(
      radiusVision: radiusVision,
      closePlayer: (player) {
        simpleAttackMelee(
          size: ImpEnemyConfig.kPrimaryAttackFxSize,
          damage: controller.model.attackDamage,
          interval: controller.model.attackInterval,
          animationRight:
              CharacterPrimaryAttackConfig.createEnemyExecutionAnimation(),
          execute: () {
            GameplayAudioManager.instance.playEnemyPrimaryAttackSfx();
          },
        );
      },
    );
  }
}
