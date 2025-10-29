import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_dialog_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class KidNpcConfig {
  static final fTextureSize = Vector2(16, 22);
  static final fComponentSize = Vector2(8, 11);

  static final fDirectionalSpriteAnimation = SimpleDirectionAnimation(
    idleRight: UISpriteAnimations.kidNpcIdleLeft4(),
    runRight: UISpriteAnimations.kidNpcIdleLeft4(),
  );

  static List<Say> createConversationSequence() {
    return [
      GameplayConversationConfig.kidRightDialog('talk_kid_2'),
      GameplayConversationConfig.knightLeftDialog('talk_player_4'),
    ];
  }
}
