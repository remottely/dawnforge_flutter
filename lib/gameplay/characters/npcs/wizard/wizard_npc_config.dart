import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';

abstract class WizardNpcConfig {
  static final Vector2 spriteSize = Vector2(
    GameplayConstants.kTileDimensionStandard * 0.8,
    GameplayConstants.kTileDimensionStandard * 1.0,
  );

  static const double kVisionRadius = GameplayConstants.kVisionRadiusSmall;

  static final SimpleDirectionAnimation buildDirectionalAnimation =
      SimpleDirectionAnimation(
        idleRight: NpcSpriteAnimations.wizardIdleLeft(),
        runRight: NpcSpriteAnimations.wizardIdleLeft(),
      );

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.wizardRightDialog('talk_wizard_1'),
      GameplayDialogConstants.playerLeftDialog('talk_player_1'),
      GameplayDialogConstants.wizardRightDialog('talk_wizard_2'),
      GameplayDialogConstants.playerLeftDialog('talk_player_2'),
      GameplayDialogConstants.wizardRightDialog('talk_wizard_3'),
    ];
  }
}
