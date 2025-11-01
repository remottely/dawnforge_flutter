import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/gameplay_conversation_factory.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

final class WizardNpcConfig {
  WizardNpcConfig._();

  static const double kVisionRadius = CharacterConfig.kVisionRadiusSmall;

  static final Vector2 fTextureSize = Vector2(16, 22);
  static final Vector2 fComponentSize = Vector2(
    GameplayTileConfig.kTileDimensionStandard * 0.8,
    GameplayTileConfig.kTileDimensionStandard * 1.0,
  );

  static final SimpleDirectionAnimation fDirectionalSpriteAnimation =
      SimpleDirectionAnimation(
        idleRight: UISpriteAnimations.wizardNpcIdleLeft4(),
        runRight: UISpriteAnimations.wizardNpcIdleLeft4(),
      );

  static List<Say> createConversationSequence() => [
    GameplayConversationFactory.wizardRightDialog('talk_wizard_1'),
    GameplayConversationFactory.knightLeftDialog('talk_player_1'),
    GameplayConversationFactory.wizardRightDialog('talk_wizard_2'),
    GameplayConversationFactory.knightLeftDialog('talk_player_2'),
    GameplayConversationFactory.wizardRightDialog('talk_wizard_3'),
  ];
}
