import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/gameplay_conversation_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class WizardNpcConfig {
  WizardNpcConfig._();

  static const double kVisionRadius = CharacterConfig.kVisionRadiusExtraSmall;

  static final Vector2 textureSize = Vector2(16, 22);
  static final Vector2 componentSize = Vector2(
    GameplayTileConfig.kTileDimensionStandard * 0.8,
    GameplayTileConfig.kTileDimensionStandard * 1.0,
  );

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleRight: UISpriteAnimationsConfig.loadWizardNpcIdleLeft4(),
    runRight: UISpriteAnimationsConfig.loadWizardNpcIdleLeft4(),
  );

  static List<Say> createConversationSequence() => [
    GameplayConversationConfig.createWizardRightDialog('talk_wizard_1'),
    GameplayConversationConfig.createKnightLeftDialog('talk_player_1'),
    GameplayConversationConfig.createWizardRightDialog('talk_wizard_2'),
    GameplayConversationConfig.createKnightLeftDialog('talk_player_2'),
    GameplayConversationConfig.createWizardRightDialog('talk_wizard_3'),
  ];
}
