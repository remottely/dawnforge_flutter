import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';

/// WizardNpcConfig
/// ---------------------------------------------------------------------------
/// Holds all static data, constants, and utility methods for WizardNpcView configuration.
/// No business logic here. Use this pattern for other configs.
abstract class WizardNpcConfig {
  //////////////////////////////////////////////////////////////////////////////
  // SPRITE & DIMENSIONS
  //////////////////////////////////////////////////////////////////////////////
  /// Default sprite size for the wizard NPC
  static final Vector2 spriteSize = Vector2(
    GameplayConstants.kTileDimensionStandard * 0.8,
    GameplayConstants.kTileDimensionStandard * 1.0,
  );

  //////////////////////////////////////////////////////////////////////////////
  // VISION
  //////////////////////////////////////////////////////////////////////////////
  /// Vision radius for proximity detection
  static const double kVisionRadius = GameplayConstants.kVisionRadiusSmall;

  //////////////////////////////////////////////////////////////////////////////
  // ANIMATION
  //////////////////////////////////////////////////////////////////////////////
  /// Directional animation for wizard NPC
  static final SimpleDirectionAnimation buildDirectionalAnimation =
      SimpleDirectionAnimation(
        idleRight: NpcSpriteAnimations.wizardIdleLeft(),
        runRight: NpcSpriteAnimations.wizardIdleLeft(),
      );

  /// Creates the sequence of Say objects for the conversation
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
