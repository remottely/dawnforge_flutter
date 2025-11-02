import 'package:darkness_dungeon/gameplay/characters/enemies/dd_base_enemy_model.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';

/// Model: Contém apenas dados e validações do Imp.
class ImpEnemyModel extends DDBaseEnemyModel {
  ImpEnemyModel()
    : super(
        attackDamage: ImpEnemyConfig.kAttackDamage,
        visionRadius: CharacterConfig.kVisionRadiusExtraLarge,
        attackInterval: ImpEnemyConfig.kAttackInterval,
      );
}
