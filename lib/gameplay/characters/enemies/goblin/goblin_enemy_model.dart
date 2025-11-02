import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';

/// Model: Contém apenas dados e validações do Goblin.
class GoblinEnemyModel extends DDBaseEnemyModel {
  GoblinEnemyModel()
    : super(
        attackDamage: GoblinEnemyConfig.kAttackDamage,
        visionRadius: CharacterConfig.kVisionRadiusLarge,
        attackInterval: GoblinEnemyConfig.kAttackInterval,
      );
}
