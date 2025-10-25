import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/npc_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';

abstract class KidNpcConfig {
  static const double sizeMultiplierX = 8.0;
  static const double sizeMultiplierY = 11.0;
  static final Vector2 spriteSize = Vector2(sizeMultiplierX, sizeMultiplierY);

  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      SimpleDirectionAnimation(
        idleRight: NpcSpriteAnimations.kidIdleLeft(),
        runRight: NpcSpriteAnimations.kidIdleLeft(),
      );

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.kidRightDialog('talk_kid_2'),
      GameplayDialogConstants.playerLeftDialog('talk_player_4'),
    ];
  }
}
