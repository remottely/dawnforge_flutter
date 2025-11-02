import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_controller.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_model.dart';

class DungeonMiniBossEnemyView
    extends
        DDBaseEnemy<DungeonMiniBossEnemyController, DungeonMiniBossEnemyModel> {
  DungeonMiniBossEnemyView(Vector2 position)
    : super(
        animation: DungeonMiniBossEnemyConfig.directionalSpriteAnimation,
        position: position,
        size: DungeonMiniBossEnemyConfig.componentSize,
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
      onSeeAndMoveToMeleeAttack: seeAndMoveToPrimaryAttack,
      onSeeAndMoveToRangeAttack: seeAndMoveToFireballAttack,
    );
  }

  @override
  RectangleHitbox createHitbox() => DungeonMiniBossEnemyConfig.createHitbox();
}
