import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/conversation_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class WizardNpcConfig {
  WizardNpcConfig._();

  static const double kVisionRadius =
      CharacterConstants.kVisionRadiusExtraSmall;

  static final Vector2 textureSize = Vector2(
    16,
    22,
  ); // TODO(Kevin): change this size
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleRight: UISpriteAnimationsConfig.loadWizardNpcIdleLeft4(),
    runRight: UISpriteAnimationsConfig.loadWizardNpcIdleLeft4(),
  );

  static List<Say> createConversationSequence() => [
    ConversationConfig.createWizardRightDialog('talk_wizard_1'),
    ConversationConfig.createKnightLeftDialog('talk_player_1'),
    ConversationConfig.createWizardRightDialog('talk_wizard_2'),
    ConversationConfig.createKnightLeftDialog('talk_player_2'),
    ConversationConfig.createWizardRightDialog('talk_wizard_3'),
  ];
}
