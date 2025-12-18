import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/conversation_def.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

final class KidNpcDef {
  KidNpcDef._();

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
        UISpriteAnimationsDef.loadAnimationKidNpcIdleLeft(), // TODO(Kevin): create right animation
    runRight: UISpriteAnimationsDef.loadAnimationKidNpcIdleLeft(),
  );

  static List<Say> createConversationSequence() {
    return [
      ConversationDef.createKidRight('talk_kid_2'),
      ConversationDef.createPlayerLeft('talk_player_4'),
    ];
  }
}
