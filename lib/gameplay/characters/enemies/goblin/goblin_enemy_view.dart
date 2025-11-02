import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

class GoblinEnemyView
    extends DDBaseEnemy<GoblinEnemyController, GoblinEnemyModel> {
  GoblinEnemyView(Vector2 position)
    : super(
        animation: GoblinEnemyConfig.fLoadDirectionalSpriteAnimation,
        position: position,
        size: GoblinEnemyConfig.fComponentSize,
        speed: GoblinEnemyConfig.kSpeed,
        life: GoblinEnemyConfig.kLife,
      );

  @override
  GoblinEnemyModel createModel() => GoblinEnemyModel();

  @override
  GoblinEnemyController createController(GoblinEnemyModel model) {
    return GoblinEnemyController(
      model: model,
      onSeeAndMoveToPlayer: _onSeeAndMoveToPlayer,
    );
  }

  @override
  RectangleHitbox createHitbox() => GoblinEnemyConfig.createHitbox();

  /// Controller callback implementations
  void _onSeeAndMoveToPlayer({
    required double radiusVision,
    required void Function(Player) closePlayer,
  }) {
    seeAndMoveToPlayer(
      radiusVision: radiusVision,
      closePlayer: (player) {
        simpleAttackMelee(
          size: GoblinEnemyConfig.kPrimaryAttackFxSize,
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
