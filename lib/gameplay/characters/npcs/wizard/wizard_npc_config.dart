import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class WizardNpcConfig {
  static final Vector2 spriteSize = Vector2(
    GameplayConstants.kTileDimensionStandard * 0.8,
    GameplayConstants.kTileDimensionStandard * 1.0,
  );

  static const double kVisionRadius = GameplayConstants.kVisionRadiusSmall;

  static final SimpleDirectionAnimation buildDirectionalAnimation =
      SimpleDirectionAnimation(
        idleRight: UISpriteAnimations.wizardIdleLeft(),
        runRight: UISpriteAnimations.wizardIdleLeft(),
      );

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.wizardRightDialog('talk_wizard_1'),
      GameplayDialogConstants.knightLeftDialog('talk_player_1'),
      GameplayDialogConstants.wizardRightDialog('talk_wizard_2'),
      GameplayDialogConstants.knightLeftDialog('talk_player_2'),
      GameplayDialogConstants.wizardRightDialog('talk_wizard_3'),
    ];
  }
}
