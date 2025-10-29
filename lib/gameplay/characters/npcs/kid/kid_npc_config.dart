import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_dialog_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class KidNpcConfig {
  static final fTextureSize = Vector2(16, 22);
  static final fComponentSize = Vector2(8, 11);

  static final fDirectionalAnimation = SimpleDirectionAnimation(
    idleRight: UISpriteAnimations.kidNpcIdleLeft4(),
    runRight: UISpriteAnimations.kidNpcIdleLeft4(),
  );

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConfig.kidRightDialog('talk_kid_2'),
      GameplayDialogConfig.knightLeftDialog('talk_player_4'),
    ];
  }
}
