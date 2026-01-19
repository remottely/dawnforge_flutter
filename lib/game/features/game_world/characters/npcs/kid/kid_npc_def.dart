import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/systems/ui/conversation_def.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

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

  static Future<SpriteAnimation> loadAnimationIdleLeft() =>
      SpriteAnimation.load(
        'gameplay/characters/npcs/kid_npc_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: KidNpcDef.textureSize,
        ),
      );

  static final SimpleDirectionAnimation animationWalkDirectional =
      SimpleDirectionAnimation(
        idleRight:
            loadAnimationIdleLeft(), // TODO(Kevin): create right animation
        runRight: loadAnimationIdleLeft(),
      );

  static List<Say> createConversationSequence() {
    return [
      ConversationDef.createKidRight('talk_kid_2'),
      ConversationDef.createPlayerLeft('talk_player_4'),
    ];
  }
}
