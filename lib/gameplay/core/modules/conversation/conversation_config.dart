import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/darkness_dungeon.dart';

class ConversationConfig {
  static Say createKnightLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadKnightPlayerIdleRight6(),
  );

  static Say createSunnyLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadSunnyPlayerIdleRight6(),
  );

  static Say createWizardRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadWizardNpcIdleLeft4(),
  );

  static Say createKidRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadKidNpcIdleLeft4(),
  );

  static Say createBossLeft(String phraseKey) => _createLeft(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadBossEnemyIdleRight4(),
  );

  static Say createBossRight(String phraseKey) => _createRight(
    phraseKey: phraseKey,
    animation: UISpriteAnimationsConfig.loadBossEnemyIdleLeft4(),
  );

  /// Internal Methods
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
