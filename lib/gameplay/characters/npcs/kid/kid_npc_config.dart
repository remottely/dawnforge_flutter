import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/gameplay_conversation_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class KidNpcConfig {
  KidNpcConfig._();

  static final Vector2 fTextureSize = Vector2(16, 22);
  static final Vector2 fComponentSize = Vector2(8, 11);

  static final SimpleDirectionAnimation fLoadDirectionalSpriteAnimation =
      SimpleDirectionAnimation(
        idleRight: UISpriteAnimationsConfig.loadKidNpcIdleLeft4(),
        runRight: UISpriteAnimationsConfig.loadKidNpcIdleLeft4(),
      );

  static List<Say> createConversationSequence() {
    return [
      GameplayConversationConfig.createKidRightDialog('talk_kid_2'),
      GameplayConversationConfig.createKnightLeftDialog('talk_player_4'),
    ];
  }
}
