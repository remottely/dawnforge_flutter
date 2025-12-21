import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/conversation_def.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

final class WizardNpcDef {
  WizardNpcDef._();

  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusSmall;

  static final Vector2 textureSize = Vector2(
    16,
    22,
  ); // TODO(Kevin): change this size
  static final Vector2 componentSize = textureSize;

  static Future<SpriteAnimation> loadAnimationIdleLeft() =>
      SpriteAnimation.load(
        'gameplay/characters/npcs/wizard_npc_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: WizardNpcDef.textureSize,
        ),
      );

  static final SimpleDirectionAnimation
  animationWalkDirectional = SimpleDirectionAnimation(
    idleRight:
        loadAnimationIdleLeft(), // TODO(Kevin): create right animation
    runRight: loadAnimationIdleLeft(),
  );

  static List<Say> createConversationSequence() => [
    ConversationDef.createWizardRight('talk_wizard_1'),
    ConversationDef.createPlayerLeft('talk_player_1'),
    ConversationDef.createWizardRight('talk_wizard_2'),
    ConversationDef.createPlayerLeft('talk_player_2'),
    ConversationDef.createWizardRight('talk_wizard_3'),
  ];
}
