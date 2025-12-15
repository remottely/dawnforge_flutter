import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/conversation_config.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_config.dart';

final class WizardNpcConfig {
  WizardNpcConfig._();

  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusSmall;

  static final Vector2 textureSize = Vector2(
    16,
    22,
  ); // TODO(Kevin): change this size
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation
  animationWalkDirectional = SimpleDirectionAnimation(
    idleRight:
        UISpriteAnimationsConfig.loadAnimationWizardNpcIdleLeft(), // TODO(Kevin): create right animation
    runRight: UISpriteAnimationsConfig.loadAnimationWizardNpcIdleLeft(),
  );

  static List<Say> createConversationSequence() => [
    ConversationConfig.createWizardRight('talk_wizard_1'),
    ConversationConfig.createPlayerLeft('talk_player_1'),
    ConversationConfig.createWizardRight('talk_wizard_2'),
    ConversationConfig.createPlayerLeft('talk_player_2'),
    ConversationConfig.createWizardRight('talk_wizard_3'),
  ];
}
