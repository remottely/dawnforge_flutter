import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_dialog_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class WizardNpcConfig {
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
    GameplayConversationConfig.wizardRightDialog('talk_wizard_1'),
    GameplayConversationConfig.knightLeftDialog('talk_player_1'),
    GameplayConversationConfig.wizardRightDialog('talk_wizard_2'),
    GameplayConversationConfig.knightLeftDialog('talk_player_2'),
    GameplayConversationConfig.wizardRightDialog('talk_wizard_3'),
  ];
}
