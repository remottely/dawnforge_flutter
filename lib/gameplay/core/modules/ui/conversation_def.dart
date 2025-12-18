import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/player_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/shared/framework/widgets/dd_sprite_animation_widget.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';
import 'package:flutter/painting.dart';

final class ConversationDef {
  ConversationDef._();

  static Say createPlayerLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: PlayerStateManager.instance.currentPlayerAnimation!,
  );

  // static Say createKnightLeft(String phraseKey) => _createLeft(
  //   phraseKey: phraseKey,
  //   animation: UISpriteAnimationsDef.loadAnimationKnightPlayerIdleRight(),
  // );

  // static Say createCuteLeft(String phraseKey) => _createLeft(
  //   phraseKey: phraseKey,
  //   animation: UISpriteAnimationsDef.loadAnimationCutePlayerIdleRight(),
  // );

  // static Say createSunnyLeft(String phraseKey) => _createLeft(
  //   phraseKey: phraseKey,
  //   animation: UISpriteAnimationsDef.loadAnimationSunnyPlayerIdleRight(),
  // );

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
  );

  static Say createBossRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsDef.loadAnimationBossEnemyIdleLeft(),
  );

  static Say _createLeft({
    required String phraseKey,
    required Future<SpriteAnimation> animation,
  }) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget.large(animation: animation),
    personSayDirection: PersonSayDirection.LEFT,
  );

  static Say _createRight({
    required String phraseKey,
    required Future<SpriteAnimation> animation,
  }) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget.large(animation: animation),
    personSayDirection: PersonSayDirection.RIGHT,
  );
}
