import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/characters/enemies/boss/boss_enemy_def.dart';
import 'package:dawnforge/gameplay/characters/enemies/goblin/goblin_enemy_def.dart';
import 'package:dawnforge/gameplay/characters/enemies/imp/imp_enemy_Def.dart';
import 'package:dawnforge/gameplay/characters/enemies/mini_boss/mini_boss_enemy_def.dart';
import 'package:dawnforge/gameplay/characters/npcs/kid/kid_npc_def.dart';
import 'package:dawnforge/gameplay/characters/npcs/wizard/wizard_npc_def.dart';
import 'package:dawnforge/gameplay/characters/player/demo/demo_player_def.dart';

class UISpriteAnimationsDef {
  static final Future<SpriteAnimation> loadAnimationDemoPlayerIdleDown =
      DemoPlayerDef.loadAnimationIdleDown;

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
