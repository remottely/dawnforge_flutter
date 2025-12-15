import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/shared/framework/widgets/dd_sprite_animation_widget.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_config.dart';
import 'package:flutter/painting.dart';

class ConversationConfig {
  static Say createKnightLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadAnimationKnightPlayerIdleRight(),
  );

  static Say createSunnyLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadAnimationSunnyPlayerIdleRight(),
  );

  static Say createWizardRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadAnimationWizardNpcIdleLeft(),
  );

  static Say createKidRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadAnimationKidNpcIdleLeft(),
  );

  static Say createBossLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadAnimationBossEnemyIdleRight(),
  );

  static Say createBossRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadAnimationBossEnemyIdleLeft(),
  );

  static Say _createLeft({
    required String phraseKey,
    required Future<SpriteAnimation> animation,
  }) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(animation: animation),
    personSayDirection: PersonSayDirection.LEFT,
  );

  static Say _createRight({
    required String phraseKey,
    required Future<SpriteAnimation> animation,
  }) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(animation: animation),
    personSayDirection: PersonSayDirection.RIGHT,
  );
}
