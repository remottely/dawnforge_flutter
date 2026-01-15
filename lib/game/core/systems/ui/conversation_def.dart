import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/systems/game/player_state_manager.dart';
import 'package:dawnforge/game/core/systems/localization/gameplay_strings_location.dart';
import 'package:dawnforge/shared/framework/widgets/dd_sprite_animation_widget.dart';
import 'package:dawnforge/shared/utils/sprite_animation_constants.dart';
import 'package:dawnforge/shared/utils/ui_sprite_animations_def.dart';
import 'package:flutter/painting.dart';

final class ConversationDef {
  ConversationDef._();

  static Say createPlayerLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: PlayerStateManager.instance.currentPlayerAnimation!,
  );

  static Say createWizardRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsDef.loadAnimationWizardNpcIdleLeft(),
  );

  static Say createKidRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsDef.loadAnimationKidNpcIdleLeft(),
  );

  static Say createBossLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsDef.loadAnimationBossEnemyIdleRight(),
    width: SpriteAnimationConstants.kSizeLarge,
    height: SpriteAnimationConstants.kSizeLarge,
  );

  static Say createBossRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsDef.loadAnimationBossEnemyIdleLeft(),
    width: SpriteAnimationConstants.kSizeLarge,
    height: SpriteAnimationConstants.kSizeLarge,
  );

  static Say _createLeft({
    required String phraseKey,
    required Future<SpriteAnimation> animation,
    double width = SpriteAnimationConstants.kSizeStandard,
    double height = SpriteAnimationConstants.kSizeStandard,
  }) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(
      animation: animation,
      width: width,
      height: height,
    ),
    personSayDirection: PersonSayDirection.LEFT,
  );

  static Say _createRight({
    required String phraseKey,
    required Future<SpriteAnimation> animation,
    double width = SpriteAnimationConstants.kSizeStandard,
    double height = SpriteAnimationConstants.kSizeStandard,
  }) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(
      animation: animation,
      width: width,
      height: height,
    ),
    personSayDirection: PersonSayDirection.RIGHT,
  );
}
