import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fireball_attack_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_primary_attack_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/audio/gameplay_audio_manager.dart';

class DungeonMiniBossEnemyView
    extends
        DDBaseEnemy<DungeonMiniBossEnemyController, DungeonMiniBossEnemyModel> {
  DungeonMiniBossEnemyView(Vector2 position)
    : super(
        animation: DungeonMiniBossEnemyConfig.fLoadDirectionalSpriteAnimation,
        position: position,
        size: DungeonMiniBossEnemyConfig.fComponentSize,
        speed: DungeonMiniBossEnemyConfig.kSpeed,
        life: DungeonMiniBossEnemyConfig.kLife,
      );

  @override
  DungeonMiniBossEnemyModel createModel() => DungeonMiniBossEnemyModel();

  @override
  DungeonMiniBossEnemyController createController(
    DungeonMiniBossEnemyModel model,
  ) {
    return DungeonMiniBossEnemyController(
      model: model,
      onSeeAndMoveToPlayer: _onSeeAndMoveToPlayer,
      onSeeAndMoveToAttackRange: _onSeeAndMoveToAttackRange,
    );
  }

  @override
  RectangleHitbox createHitbox() => DungeonMiniBossEnemyConfig.createHitbox();

  /// Controller callback implementations
  void _onSeeAndMoveToPlayer({
    required double radiusVision,
    required void Function(Player) closePlayer,
  }) {
    seeAndMoveToPlayer(
      radiusVision: radiusVision,
      closePlayer: (player) {
        simpleAttackMelee(
          size: DungeonMiniBossEnemyConfig.kPrimaryAttackFxSize,
          damage: controller.model.meleeAttackDamage,
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

  void _onSeeAndMoveToAttackRange({
    required double radiusVision,
    required void Function(Player) positioned,
  }) {
    seeAndMoveToAttackRange(
      radiusVision: radiusVision,
      positioned: (player) {
        simpleAttackRange(
          animation: CharacterFireballAttackConfig.createExecutionAnimation(),
          animationDestroy:
              CharacterFireballAttackConfig.createDestroyAnimation(),
          size: CharacterFireballAttackConfig.fComponentSize,
          damage: controller.model.rangedAttackDamage,
          speed: speed * CharacterFireballAttackConfig.kSpeedMultiplier,
          execute: CharacterFireballAttackConfig.playExecutionAudio,
          onDestroy: CharacterFireballAttackConfig.playDestroyAudio,
          collision: CharacterFireballAttackConfig.createHitbox(),
          lightingConfig: CharacterFireballAttackConfig.fLightingConfig,
        );
      },
    );
  }
}
