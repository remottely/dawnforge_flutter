import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';

/// KidNpcConfig
/// ---------------------------------------------------------------------------
/// Holds all static data, constants, and utility methods for KidNpcView configuration.
/// No business logic here. Use this pattern for other configs.
abstract class KidNpcConfig {
  //////////////////////////////////////////////////////////////////////////////
  // SPRITE & DIMENSIONS
  //////////////////////////////////////////////////////////////////////////////
  /// Default sprite size for the kid NPC
  static const double sizeMultiplierX = 8.0;
  static const double sizeMultiplierY = 11.0;
  static final Vector2 spriteSize = Vector2(sizeMultiplierX, sizeMultiplierY);

  //////////////////////////////////////////////////////////////////////////////
  // ANIMATION
  //////////////////////////////////////////////////////////////////////////////
  /// Directional animation for kid NPC
  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      SimpleDirectionAnimation(
        idleRight: NpcSpriteAnimations.kidIdleLeft(),
        runRight: NpcSpriteAnimations.kidIdleLeft(),
      );

  /// Creates the sequence of Say objects for the conversation
  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.kidRightDialog('talk_kid_2'),
      GameplayDialogConstants.playerLeftDialog('talk_player_4'),
    ];
  }
}
