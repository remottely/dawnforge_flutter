import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/characters/enemies/boss/boss_enemy_def.dart';
import 'package:dawnforge/game/modules/characters/enemies/goblin/goblin_enemy_def.dart';
import 'package:dawnforge/game/modules/characters/enemies/imp/imp_enemy_def.dart';
import 'package:dawnforge/game/modules/characters/enemies/mini_boss/mini_boss_enemy_def.dart';
import 'package:dawnforge/game/modules/characters/npcs/kid/kid_npc_def.dart';
import 'package:dawnforge/game/modules/characters/npcs/wizard/wizard_npc_def.dart';
import 'package:dawnforge/game/modules/characters/player/cute/cute_player_def.dart';
import 'package:dawnforge/game/modules/characters/player/demo/demo_player_def.dart';
import 'package:dawnforge/game/modules/characters/player/farmer/farmer_player_def.dart';
import 'package:dawnforge/game/modules/characters/player/knight/knight_player_def.dart';
import 'package:dawnforge/game/modules/characters/player/sunny/sunny_player_def.dart';

class UISpriteAnimationsDef {
  static final Future<SpriteAnimation> loadAnimationDemoPlayerIdleDown =
      DemoPlayerDef.loadAnimationIdleDown;

  static final Future<SpriteAnimation> loadAnimationFarmerPlayerIdleDown =
      FarmerPlayerDef.loadAnimationIdleDown;

  static final Future<SpriteAnimation> loadAnimationKnightPlayerIdleRight =
      KnightPlayerDef.loadAnimationIdleRight;

  static final Future<SpriteAnimation> loadAnimationCutePlayerIdleRight =
      CutePlayerDef.loadAnimationIdleRight;

  static final Future<SpriteAnimation> loadAnimationSunnyPlayerIdleRight =
      SunnyPlayerDef.loadAnimationIdleRight;

  static Future<SpriteAnimation> loadAnimationWizardNpcIdleLeft() =>
      WizardNpcDef.loadAnimationIdleLeft();

  static Future<SpriteAnimation> loadAnimationKidNpcIdleLeft() =>
      KidNpcDef.loadAnimationIdleLeft();

  static Future<SpriteAnimation> loadAnimationGoblinEnemyIdleRight() =>
      GoblinEnemyDef.loadAnimationIdleRight();

  static Future<SpriteAnimation> loadAnimationImpEnemyIdleRight() =>
      ImpEnemyDef.loadAnimationIdleRight();

  static Future<SpriteAnimation> loadAnimationMiniBossEnemyIdleRight() =>
      MiniBossEnemyDef.loadAnimationIdleRight();

  static Future<SpriteAnimation> loadAnimationBossEnemyIdleRight() =>
      BossEnemyDef.loadAnimationIdleRight();

  static Future<SpriteAnimation> loadAnimationBossEnemyIdleLeft() =>
      BossEnemyDef.loadAnimationIdleLeft();
}
