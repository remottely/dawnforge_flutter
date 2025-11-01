import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/gameplay_conversation_factory.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

final class KidNpcConfig {
  KidNpcConfig._();

  static final Vector2 fTextureSize = Vector2(16, 22);
  static final Vector2 fComponentSize = Vector2(8, 11);

  static final SimpleDirectionAnimation fDirectionalSpriteAnimation =
      SimpleDirectionAnimation(
        idleRight: UISpriteAnimations.kidNpcIdleLeft4(),
        runRight: UISpriteAnimations.kidNpcIdleLeft4(),
      );

  static List<Say> createConversationSequence() {
    return [
      GameplayConversationFactory.kidRightDialog('talk_kid_2'),
      GameplayConversationFactory.knightLeftDialog('talk_player_4'),
    ];
  }
}
