import 'package:darkness_dungeon/darkness_dungeon.dart';

class GameplayConversationConfig {
  static Say createKnightLeftDialog(String phraseKey) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(
      animation: UISpriteAnimationsConfig.loadSunnyPlayerIdleRight6(),
    ),
    personSayDirection: PersonSayDirection.LEFT,
  );

  static Say createWizardRightDialog(String phraseKey) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(
      animation: UISpriteAnimationsConfig.loadWizardNpcIdleLeft4(),
    ),
    personSayDirection: PersonSayDirection.RIGHT,
  );

  static Say createKidRightDialog(String phraseKey) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(
      animation: UISpriteAnimationsConfig.loadKidNpcIdleLeft4(),
    ),
    personSayDirection: PersonSayDirection.RIGHT,
  );

  static Say createBossLeftDialog(String phraseKey) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString(phraseKey)),
    ],
    person: DDSpriteAnimationWidget(
      animation: UISpriteAnimationsConfig.loadBossEnemyIdleRight4(),
    ),
    personSayDirection: PersonSayDirection.LEFT,
  );

  static Say createBossRightDialog(String phraseKey) => Say(
    text: [
      TextSpan(text: GameplayStringsLocation.instance.getString('talk_boss_2')),
    ],
    person: DDSpriteAnimationWidget(
      animation: UISpriteAnimationsConfig.loadBossEnemyIdleLeft4(),
    ),
    personSayDirection: PersonSayDirection.RIGHT,
  );
}
