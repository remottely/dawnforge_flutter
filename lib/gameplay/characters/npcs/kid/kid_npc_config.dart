import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class KidNpcConfig {
  static final fTextureSize = Vector2(16, 22);
  static final fComponentSize = Vector2(8, 11);

  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      SimpleDirectionAnimation(
        idleRight: UISpriteAnimations.kidNpcIdleLeft4(),
        runRight: UISpriteAnimations.kidNpcIdleLeft4(),
      );

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.kidRightDialog('talk_kid_2'),
      GameplayDialogConstants.knightLeftDialog('talk_player_4'),
    ];
  }
}
