import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/conversation_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class KidNpcConfig {
  KidNpcConfig._();

  static final Vector2 textureSize = Vector2(
    16,
    22,
  ); // TODO(Kevin): change this size
  static final Vector2 componentSize = Vector2(
    8,
    11,
  ); // TODO(Kevin): change this size

  static final SimpleDirectionAnimation
  animationWalkDirectional = SimpleDirectionAnimation(
    idleRight:
        UISpriteAnimationsConfig.loadAnimationKidNpcIdleLeft(), // TODO(Kevin): create right animation
    runRight: UISpriteAnimationsConfig.loadAnimationKidNpcIdleLeft(),
  );

  static List<Say> createConversationSequence() {
    return [
      ConversationConfig.createKidRight('talk_kid_2'),
      ConversationConfig.createKnightLeft('talk_player_4'),
    ];
  }
}
